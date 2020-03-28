//
//  TTContext.m
//  TTPatch
//
//  Created by ty on 2019/5/17.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTContext.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "TTPatch.h"
#import <libkern/OSAtomic.h>
#import "TTPatchKit.h"


#define guard(condfion) if(condfion){}
#define TTPATCH_DERIVE_PRE @"TTPatch_Derive_"
#define TTPatchInvocationException @"TTPatchInvocationException"

typedef enum : NSUInteger {
    log_level_debug=1,
    log_level_info,
    log_level_error,
} log_level;

typedef enum {
    // Set to true on blocks that have captures (and thus are not true
    // global blocks) but are known not to escape for various other
    // reasons. For backward compatiblity with old runtimes, whenever
    // BLOCK_IS_NOESCAPE is set, BLOCK_IS_GLOBAL is set too. Copying a
    // non-escaping block returns the original block and releasing such a
    // block is a no-op, which is exactly how global blocks are handled.
    TTPATCH_BLOCK_IS_NOESCAPE      =  (1 << 23),

    TTPATCH_BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    TTPATCH_BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    TTPATCH_BLOCK_IS_GLOBAL =         (1 << 28),
    TTPATCH_BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    TTPATCH_BLOCK_HAS_SIGNATURE =     (1 << 30),
} TTPATCH_BLOCK_FLAGS;


typedef struct TTPatchBlock {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    TTPATCH_BLOCK_FLAGS flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
    unsigned long int reserved;         // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
} *TTPatchBlockRef;



@interface TTContext ()
@end

@implementation TTContext

static CGRect toOcCGReact(NSString *jsObjValue){

    if (jsObjValue) {
        return CGRectFromString(jsObjValue);
    }
    return CGRectZero;
}

static CGPoint toOcCGPoint(NSString *jsObjValue){
    if (jsObjValue){
        return CGPointFromString(jsObjValue);
    }
    return CGPointZero;
}

static CGSize toOcCGSize(NSString *jsObjValue){
    if (jsObjValue) {
        return CGSizeFromString(jsObjValue);
    }
    return CGSizeZero;
}

static NSMethodSignature *block_methodSignatureForSelector(id self, SEL _cmd, SEL aSelector) {
    
    TTPatchBlockRef blockLayout = (__bridge void *)self;
    const char * c_signature = blockLayout->descriptor->signature;

    return [NSMethodSignature signatureWithObjCTypes:c_signature];
}

static id execFuncParamsBlockWithKeyAndParams(NSString *key,NSArray *params){
    return [[TTPatch shareInstance].context execFuncParamsBlockWithBlockKey:key arguments:params];
}

static NSString *trim(NSString *string)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


/// 根据JS类型声明动态创建block 签名
/// 这段代码是copy来的 不想手写一遍拉
/// @param signatureStr block类型声明 "void, NSString*, int"
static id CreateBlockWithSignatureString(NSString *signatureStr){
    
    static NSMutableDictionary *typeSignatureDict;
    if (!typeSignatureDict) {
        typeSignatureDict  = [NSMutableDictionary new];
#define JP_DEFINE_TYPE_SIGNATURE(_type) \
[typeSignatureDict setObject:@[[NSString stringWithUTF8String:@encode(_type)], @(sizeof(_type))] forKey:@#_type];\

        JP_DEFINE_TYPE_SIGNATURE(id);
        JP_DEFINE_TYPE_SIGNATURE(BOOL);
        JP_DEFINE_TYPE_SIGNATURE(int);
        JP_DEFINE_TYPE_SIGNATURE(void);
        JP_DEFINE_TYPE_SIGNATURE(char);
        JP_DEFINE_TYPE_SIGNATURE(short);
        JP_DEFINE_TYPE_SIGNATURE(unsigned short);
        JP_DEFINE_TYPE_SIGNATURE(unsigned int);
        JP_DEFINE_TYPE_SIGNATURE(long);
        JP_DEFINE_TYPE_SIGNATURE(unsigned long);
        JP_DEFINE_TYPE_SIGNATURE(long long);
        JP_DEFINE_TYPE_SIGNATURE(unsigned long long);
        JP_DEFINE_TYPE_SIGNATURE(float);
        JP_DEFINE_TYPE_SIGNATURE(double);
        JP_DEFINE_TYPE_SIGNATURE(bool);
        JP_DEFINE_TYPE_SIGNATURE(size_t);
        JP_DEFINE_TYPE_SIGNATURE(CGFloat);
        JP_DEFINE_TYPE_SIGNATURE(CGSize);
        JP_DEFINE_TYPE_SIGNATURE(CGRect);
        JP_DEFINE_TYPE_SIGNATURE(CGPoint);
        JP_DEFINE_TYPE_SIGNATURE(CGVector);
        JP_DEFINE_TYPE_SIGNATURE(NSRange);
        JP_DEFINE_TYPE_SIGNATURE(NSInteger);
        JP_DEFINE_TYPE_SIGNATURE(Class);
        JP_DEFINE_TYPE_SIGNATURE(SEL);
        JP_DEFINE_TYPE_SIGNATURE(void*);
        JP_DEFINE_TYPE_SIGNATURE(void *);
    }
    NSArray *lt = [signatureStr componentsSeparatedByString:@","];
    NSString *funcSignature = @"@?0";
    
    NSInteger size = sizeof(void *);
    for (NSInteger i = 1; i < lt.count;) {
        NSString *t = trim(lt[i]);
        NSString *tpe = typeSignatureDict[typeSignatureDict[t] ? t : @"id"][0];
        if (i == 0) {
            if (!t || t.length ==0)
                funcSignature  =[[NSString stringWithFormat:@"%@%@",tpe, [@(size) stringValue]] stringByAppendingString:funcSignature];
            else
                funcSignature  =[[NSString stringWithFormat:@"%@%@",tpe, [@(size) stringValue]] stringByAppendingString:funcSignature];
            break;
        }else{
            
            funcSignature = [funcSignature stringByAppendingString:[NSString stringWithFormat:@"%@%@", tpe, [@(size) stringValue]]];
            size += [typeSignatureDict[typeSignatureDict[t] ? t : @"id"][1] integerValue];
        }
        i = (i == lt.count-1) ? 0 : i+1;
    }
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class cls = NSClassFromString(@"NSBlock");
        #define JP_HOOK_METHOD(selector, func) {Method method = class_getInstanceMethod([NSObject class], selector); \
        BOOL success = class_addMethod(cls, selector, (IMP)func, method_getTypeEncoding(method)); \
        if (!success) { class_replaceMethod(cls, selector, (IMP)func, method_getTypeEncoding(method));}}
        //此处在执行forwardInvocation流程时确保能拿到我们动态构造的函数签名
        JP_HOOK_METHOD(@selector(methodSignatureForSelector:), block_methodSignatureForSelector);
        JP_HOOK_METHOD(@selector(forwardInvocation:), OC_MSG_SEND_HANDLE);
    });
    
    
    void (^block)(void) = ^(void){};
    TTPatchBlockRef blockLayout = (__bridge void*)block;
    IMP msgForwardIMP = _objc_msgForward;
    blockLayout->descriptor->signature = [funcSignature cStringUsingEncoding:NSUTF8StringEncoding];
    
#if !defined(__arm64__)
    if ([funcSignature UTF8String][0] == '{') {
        //In some cases that returns struct, we should use the '_stret' API:
        //http://sealiesoftware.com/blog/archive/2008/10/30/objc_explain_objc_msgSend_stret.html
        //NSMethodSignature knows the detail but has no API to return, we can only get the info from debugDescription.
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:[funcSignature UTF8String]];
        if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
            msgForwardIMP = (IMP)_objc_msgForward_stret;
        }
    }
#endif
    
    blockLayout->invoke = (void *)msgForwardIMP;
    return block;
}

#define TT_ARG_Injection(charAbbreviation,type,func)\
case charAbbreviation:\
{\
NSNumber *jsObj = arguments[i];  \
type argument=[jsObj func]; \
[invocation setArgument:&argument atIndex:(startIndex + i)]; \
}   \
break;
static void setInvocationArgumentsMethod(NSInvocation *invocation,NSArray *arguments,BOOL isBlock){
    //默认 target->0,_cmd->1,arg->2..
    int startIndex = 2;
    //@:@ count=3 参数个数1
    int indexOffset = 2;
    if (isBlock) {
        startIndex = 1;
        indexOffset = 1;
    }
    int systemMethodArgCount = (int)invocation.methodSignature.numberOfArguments;
    if (systemMethodArgCount>indexOffset) {
        systemMethodArgCount-=indexOffset;
    }else{
        systemMethodArgCount=0;
        return;
    }
   
    guard(systemMethodArgCount == arguments.count)else{
        NSCAssert(NO, [NSString stringWithFormat:@"参数个数不匹配,请检查!"]);
    }
    
    for (int i = 0; i < systemMethodArgCount; i++) {
        const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:i+indexOffset];
        char flag = argumentType[0] == 'r' ? argumentType[1] : argumentType[0];
        id argument = ([arguments objectAtIndex:i]);
        if (argument == nil || [argument isKindOfClass:[NSNull class]]) {
            argument=nil;
            [invocation setArgument:&argument atIndex:(startIndex + i)];
            continue;
        }
        switch(flag) {
            case _C_PTR:
            case _C_ID:
            {
                if ('?' == argumentType[1]) {
                    __block NSDictionary *blockDic = ([arguments objectAtIndex:i]);
                    void(^blockImp)(void)= CreateBlockWithSignatureString([blockDic objectForKey:@"__signature"]);
                    [invocation setArgument:&blockImp atIndex:(startIndex + i)];
                    objc_setAssociatedObject(blockImp , CFBridgingRetain(@"TTPATCH_OC_BLOCK"), blockDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }else{
                    id argument = ([arguments objectAtIndex:i]);
                    [invocation setArgument:&argument atIndex:(startIndex + i)];
                }
                
            }break;
            case _C_STRUCT_B:
            {
                 id argument = ([arguments objectAtIndex:i]);
             
                NSString * clsType = [argument objectForKey:@"__className"];
                guard(clsType)else{
                   NSCAssert(NO, [NSString stringWithFormat:@"***************方法签名入参为结构体,当前JS返回params未能获取当前结构体类型,请检查************"]);
                }
                NSString *str = [argument objectForKey:@"__isa"];
                if ([clsType isEqualToString:@"react"]){
                    CGRect ocBaseData = toOcCGReact(str);
                    
                    [invocation setArgument:&ocBaseData atIndex:(startIndex + i)];
                }else if ([clsType isEqualToString:@"point"]){
                    CGPoint ocBaseData = toOcCGPoint(str);
                    [invocation setArgument:&ocBaseData atIndex:(startIndex + i)];
                }
                else if ([clsType isEqualToString:@"size"]){
                    CGSize ocBaseData = toOcCGSize(str);
                    [invocation setArgument:&ocBaseData atIndex:(startIndex + i)];
                }
                
            }break;
            case 'c':{
                JSValue *jsObj = arguments[i];
                char argument[1000];
                strcpy(argument,(char *)[[jsObj toString] UTF8String]);
                [invocation setArgument:&argument atIndex:(startIndex + i)];
            }break;
            case _C_SEL:{
                 SEL argument = NSSelectorFromString([arguments objectAtIndex:i]);
                [invocation setArgument:&argument atIndex:(startIndex + i)];
            }break;
                TT_ARG_Injection(_C_SHT, short, shortValue);
                TT_ARG_Injection(_C_USHT, unsigned short, unsignedShortValue);
                TT_ARG_Injection(_C_INT, int, intValue);
                TT_ARG_Injection(_C_UINT, unsigned int, unsignedIntValue);
                TT_ARG_Injection(_C_LNG, long, longValue);
                TT_ARG_Injection(_C_ULNG, unsigned long, unsignedLongValue);
                TT_ARG_Injection(_C_LNG_LNG, long long, longLongValue);
                TT_ARG_Injection(_C_ULNG_LNG, unsigned long long, unsignedLongLongValue);
                TT_ARG_Injection(_C_FLT, float, floatValue);
                TT_ARG_Injection(_C_DBL, double, doubleValue);
                TT_ARG_Injection(_C_BOOL, BOOL, boolValue);
                
                
            default:
                break;
        }
    
    }
}



static NSString * MethodFormatterToOcFunc(NSString *method){
    if ([method rangeOfString:@"_"].length > 0) {
        method = [method stringByReplacingOccurrencesOfString:@"_" withString:@":"];
    }
    return method;
}

static NSString * MethodFormatterToJSFunc(NSString *method){
    if ([method rangeOfString:@":"].length > 0) {
        method = [method stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    }
    return method;
}

static Method GetInstanceOrClassMethodInfo(Class aClass,SEL aSel){
    Method instanceMethodInfo = class_getInstanceMethod(aClass, aSel);
    Method classMethodInfo    = class_getClassMethod(aClass, aSel);
    return instanceMethodInfo?instanceMethodInfo:classMethodInfo;
}






static NSString * ttpatch_get_derive_class_originalName(NSString *curName){
    if ([curName hasPrefix:TTPATCH_DERIVE_PRE]) {
        return [curName stringByReplacingOccurrencesOfString:TTPATCH_DERIVE_PRE withString:@""];
    }
    return curName;
}

static NSString * ttpatch_create_derive_class_name(NSString *curName){
    if ([curName hasPrefix:TTPATCH_DERIVE_PRE]) {
        return curName;
    }
    return [NSString stringWithFormat:@"%@%@",TTPATCH_DERIVE_PRE,curName];
}

static void ttpatch_exchange_method(Class self_class, Class super_class, SEL selector, BOOL isInstance) {
    NSCParameterAssert(selector);
    //获取父类方法实现
    Method targetMethodSuper = isInstance
    ? class_getInstanceMethod(super_class, selector) : class_getClassMethod(super_class, selector);
    Method targetMethodSelf = isInstance
    ? class_getInstanceMethod(self_class, selector) : class_getClassMethod(self_class, selector);
    
    {
        IMP targetMethodIMP = method_getImplementation(targetMethodSuper);
        const char *typeEncoding = method_getTypeEncoding(targetMethodSuper)?:"v@:";
        class_replaceMethod(self_class, selector, targetMethodIMP, typeEncoding);
    }
    {
        IMP targetMethodIMP = method_getImplementation(targetMethodSelf);
        const char *typeEncoding = method_getTypeEncoding(targetMethodSelf)?:"v@:";
        class_replaceMethod(super_class, selector, targetMethodIMP, typeEncoding);
    }
}

static void ttpatch_clean_derive_history(id classOrInstance,Class self_class, Class super_class, SEL selector,BOOL isInstance){
    ttpatch_exchange_method(super_class, self_class, selector, isInstance);
    Class originalClass = NSClassFromString(ttpatch_get_derive_class_originalName(NSStringFromClass([classOrInstance class])));
    object_setClass(classOrInstance, originalClass);
    objc_disposeClassPair(self_class);
}

static Class ttpatch_create_derive_class(id classOrInstance){
    Class aClass = objc_allocateClassPair([classOrInstance class], [ttpatch_create_derive_class_name(NSStringFromClass([classOrInstance class])) UTF8String], 0);
    objc_registerClassPair(aClass);
    object_setClass(classOrInstance, aClass);
    return aClass;
}

#define TT_RETURN_WRAP(typeChar,type)\
case typeChar:{   \
type instance; \
[invocation getReturnValue:&instance];  \
return @(instance); \
}break;
static id WrapInvocationResult(NSInvocation *invocation,NSMethodSignature *signature){
    NSString * method;
    if (invocation.selector) {
        method = NSStringFromSelector(invocation.selector);
    }
   const char *argumentType = signature.methodReturnType;
    char flag = argumentType[0] == 'r' ? argumentType[1] : argumentType[0];

    switch (flag) {
        case _C_ID:{
            id returnValue;
            void *result;
            [invocation getReturnValue:&result];
            if ([method isEqualToString:@"alloc"] || [method isEqualToString:@"new"]) {
                returnValue = (__bridge_transfer id)result;
//                        TTLog(@"Alloc Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)returnValue));
            } else {
                returnValue = (__bridge id)result;
            }
            return returnValue?ToJsObject(returnValue,NSStringFromClass([returnValue class])):[NSNull null];
        }break;
        case _C_CLASS:{
            __unsafe_unretained Class instance = nil;
            [invocation getReturnValue:&instance];
            return ToJsObject(nil,NSStringFromClass(instance));
        }break;
        case _C_STRUCT_B:{
            NSString * returnStypeStr = [NSString stringWithUTF8String:signature.methodReturnType];
            if ([returnStypeStr hasPrefix:@"{CGRect"]){
                CGRect instance;
                [invocation getReturnValue:&instance];
                return ToJsObject(CGReactToJSObject(instance),@"react");
            }
            else if ([returnStypeStr hasPrefix:@"{CGPoint"]){
                CGPoint instance;
                [invocation getReturnValue:&instance];
                return ToJsObject(CGPointToJSObject(instance),@"point");
            }
            else if ([returnStypeStr hasPrefix:@"{CGSize"]){
                CGSize instance;
                [invocation getReturnValue:&instance];
                return ToJsObject(CGSizeToJSObject(instance),@"size");
            }
            else if ([returnStypeStr hasPrefix:@"{UIEdgeInsets"]){
                UIEdgeInsets instance;
                [invocation getReturnValue:&instance];
                return ToJsObject(UIEdgeInsetsToJSObject(instance),@"edge");
            }
            NSCAssert(NO, @"*******%@---当前结构体暂不支持",returnStypeStr);
        }break;
            TT_RETURN_WRAP(_C_SHT, short);
            TT_RETURN_WRAP(_C_USHT, unsigned short);
            TT_RETURN_WRAP(_C_INT, int);
            TT_RETURN_WRAP(_C_UINT, unsigned int);
            TT_RETURN_WRAP(_C_LNG, long);
            TT_RETURN_WRAP(_C_ULNG, unsigned long);
            TT_RETURN_WRAP(_C_LNG_LNG, long long);
            TT_RETURN_WRAP(_C_ULNG_LNG, unsigned long long);
            TT_RETURN_WRAP(_C_FLT, float);
            TT_RETURN_WRAP(_C_DBL, double);
            TT_RETURN_WRAP(_C_BOOL, BOOL);
        default:
            break;
    }
    return nil;
}



#define TT_ARG_WRAP(typeChar,type,index)\
case typeChar:{   \
type instance; \
[invocation getArgument:&instance atIndex:index];  \
[params addObject:@(instance)];\
}break;
static NSArray* WrapInvocationArgs(NSInvocation *invocation,bool isBlock){
    NSString * method;
    if (!isBlock) {
        method = NSStringFromSelector(invocation.selector);
    }
    
    //默认 target->0,_cmd->1,arg->2..
     int startIndex = 2;
     //@:@ count=3 参数个数1
     int indexOffset = 2;
     if (isBlock ) {
         startIndex = 1;
         indexOffset = 1;
     }
     int systemMethodArgCount = (int)invocation.methodSignature.numberOfArguments;
     if (systemMethodArgCount>indexOffset) {
         systemMethodArgCount-=indexOffset;
     }else{
         systemMethodArgCount=0;
         return nil;
     }
    
    NSMutableArray *params = [NSMutableArray arrayWithCapacity:systemMethodArgCount];
//     guard(systemMethodArgCount == arguments.count)else{
//         NSCAssert(NO, [NSString stringWithFormat:@"参数个数不匹配,请检查!"]);
//     }
     
     for (int i = indexOffset; i <= systemMethodArgCount; i++) {
         const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:i];
         char flag = argumentType[0] == 'r' ? argumentType[1] : argumentType[0];
         
             switch (flag) {
                 case _C_ID:{
                     id returnValue;
                     void *result;
                     [invocation getArgument:&result atIndex:i];
                     if ([method isEqualToString:@"alloc"] || [method isEqualToString:@"new"]) {
                         returnValue = (__bridge_transfer id)result;
         //                        TTLog(@"Alloc Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)returnValue));
                     } else {
                         returnValue = (__bridge id)result;
                     }
                     if ([returnValue isKindOfClass:NSString.class] ||
                         [returnValue isKindOfClass:NSNumber.class] ||
                         [returnValue isKindOfClass:NSNull.class]) {
                         [params addObject:returnValue];
                     }else{
                        [params addObject:returnValue?ToJsObject(returnValue,NSStringFromClass([returnValue class])):[NSNull null]];
                     }
                 }break;
                 case _C_CLASS:{
                     __unsafe_unretained Class instance = nil;
                     [invocation getArgument:&instance atIndex:i];
                     [params addObject:ToJsObject(nil,NSStringFromClass(instance))];
                 }break;
                 case _C_STRUCT_B:{
                     NSString * returnStypeStr = [NSString stringWithUTF8String:argumentType];
                     if ([returnStypeStr hasPrefix:@"{CGRect"]){
                         CGRect instance;
                         [invocation getArgument:&instance atIndex:i];
                         [params addObject:ToJsObject(CGReactToJSObject(instance),@"react")];
                     }
                     else if ([returnStypeStr hasPrefix:@"{CGPoint"]){
                         CGPoint instance;
                         [invocation getArgument:&instance atIndex:i];
                         [params addObject:ToJsObject(CGPointToJSObject(instance),@"point")];
                     }
                     else if ([returnStypeStr hasPrefix:@"{CGSize"]){
                         CGSize instance;
                         [invocation getArgument:&instance atIndex:i];
                         [params addObject:ToJsObject(CGSizeToJSObject(instance),@"size")];
                     }
                     else if ([returnStypeStr hasPrefix:@"{UIEdgeInsets"]){
                         UIEdgeInsets instance;
                         [invocation getArgument:&instance atIndex:i];
                         [params addObject:ToJsObject(UIEdgeInsetsToJSObject(instance),@"edge")];
                     }
                     NSCAssert(NO, @"*******%@---当前结构体暂不支持",returnStypeStr);
                 }break;
                     TT_ARG_WRAP(_C_SHT, short,i);
                     TT_ARG_WRAP(_C_USHT, unsigned short,i);
                     TT_ARG_WRAP(_C_INT, int,i);
                     TT_ARG_WRAP(_C_UINT, unsigned int,i);
                     TT_ARG_WRAP(_C_LNG, long,i);
                     TT_ARG_WRAP(_C_ULNG, unsigned long,i);
                     TT_ARG_WRAP(_C_LNG_LNG, long long,i);
                     TT_ARG_WRAP(_C_ULNG_LNG, unsigned long long,i);
                     TT_ARG_WRAP(_C_FLT, float,i);
                     TT_ARG_WRAP(_C_DBL, double,i);
                     TT_ARG_WRAP(_C_BOOL, BOOL,i);
                 default:
                     break;
             }
     }
    
    
    
//   const char *argumentType = signature.methodReturnType;
//    char flag = argumentType[0] == 'r' ? argumentType[1] : argumentType[0];


    return [params copy];
}


static id DynamicBlock(id block, NSArray *arguments){
    TTPatchBlockRef blockLayout = (__bridge void *)block;
    void *desc = blockLayout->descriptor;
    desc += 2 * sizeof(unsigned long int);
    guard((blockLayout->flags & TTPATCH_BLOCK_HAS_SIGNATURE)) else{
        @throw [NSException exceptionWithName:TTPatchInvocationException reason:[NSString stringWithFormat:@"block 结构体中无法获取 signature"] userInfo:nil];
        return nil;
    }
    if (blockLayout->flags & TTPATCH_BLOCK_HAS_COPY_DISPOSE) {
        desc += 2 *sizeof(void *);
    }
    const char * c_signature = (*(const char **)desc);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:c_signature];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:block];
    setInvocationArgumentsMethod(invocation, arguments,YES);
    [invocation invoke];

    guard(strcmp(signature.methodReturnType,"v") == 0)else{
        return WrapInvocationResult(invocation, signature);
    }
    return nil;
}

#define TTCheckArguments(flag,arguments)\
if (![arguments isKindOfClass:[NSNull class]] &&\
arguments != nil && \
arguments.count > 0) {  \
flag = YES;  \
}
static id DynamicMethodInvocation(id classOrInstance,BOOL isSuper,BOOL isBlock, NSString *method, NSArray *arguments){
    Class ttpatch_cur_class = [classOrInstance class];
//    Class ttpatch_drive_class;
//    Class ttpatch_drive_super_class;
    if (isSuper) {
        //通过创建派生类的方式实现super
//        ttpatch_drive_super_class = [classOrInstance superclass];
//        ttpatch_drive_class = ttpatch_create_derive_class(classOrInstance);
//        ttpatch_exchange_method(ttpatch_drive_class, ttpatch_drive_super_class, NSSelectorFromString(method), isInstance);
        //通过直接替换当前isa为父类isa,实现super语法
        object_setClass(classOrInstance, [classOrInstance superclass]);
    }
    BOOL hasArgument = NO;
    TTCheckArguments(hasArgument,arguments);
    if([classOrInstance isKindOfClass:NSString.class]){
        classOrInstance = NSClassFromString(classOrInstance);
    }
    SEL sel_method = NSSelectorFromString(method);
    NSMethodSignature *signature = [classOrInstance methodSignatureForSelector:sel_method];
//    Method classMethod = class_getClassMethod([classOrInstance class], sel_method);
//    Method instanceMethod = class_getInstanceMethod([classOrInstance class], sel_method);
//    Method methodInfo = classMethod?classMethod:instanceMethod;
    guard(signature) else{
        @throw [NSException exceptionWithName:TTPatchInvocationException reason:[NSString stringWithFormat:@"没有找到 '%@' 中的 %@ 方法", classOrInstance,  method] userInfo:nil];
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    if ([classOrInstance respondsToSelector:sel_method]) {
#if TTPATCH_LOG
//            TTLog(@"\n -----------------Message Queue Call Native ---------------\n | %@ \n | 参数个数:%ld \n | %s \n | %@ \n -----------------------------------" ,method,signature.numberOfArguments,method_getTypeEncoding(methodInfo),arguments);
#endif
        [invocation setTarget:classOrInstance];
        [invocation setSelector:sel_method];
        if (hasArgument) {
            setInvocationArgumentsMethod(invocation, arguments,NO);
        }
        
        [invocation invoke];
        guard(strcmp(signature.methodReturnType,"v") == 0)else{
            return WrapInvocationResult(invocation, signature);
        }
    }else{
        
    }

    if (isSuper) {
//        ttpatch_clean_derive_history(classOrInstance,ttpatch_drive_class, ttpatch_drive_super_class, NSSelectorFromString(method),isInstance);
        object_setClass(classOrInstance, ttpatch_cur_class);
    }
    return nil;
    
}


/**
 *  TTPatch 动态方法前缀
 */
NSString *const TTPatchChangeMethodPrefix = @"tt";
static dispatch_semaphore_t ttpatch_lock=nil;
static NSMutableDictionary *__replaceMethodMap;

static void ttpatch_performLocked(dispatch_block_t block) {
    if (!ttpatch_lock) {
        ttpatch_lock=dispatch_semaphore_create(1);
    }
    dispatch_semaphore_wait(ttpatch_lock, DISPATCH_TIME_FOREVER);
    block();
    dispatch_semaphore_signal(ttpatch_lock);
}


void registerMethod(NSString *method,NSString *class,BOOL isClass){
    if (!__replaceMethodMap) {
        __replaceMethodMap = [NSMutableDictionary dictionary];
    }
    TTMethodList_Node *node = [TTMethodList_Node createNodeCls:class methodName:method isClass:isClass];
    [__replaceMethodMap setObject:node forKey:node.key];
}

BOOL checkRegistedMethod(NSString *method, NSString *class, BOOL isClass){
    TTMethodList_Node *node = [TTMethodList_Node createNodeCls:class methodName:method isClass:isClass];
    if ([__replaceMethodMap objectForKey:node.key]) {
        return YES;
    }
    return NO;
}
    

static BOOL aspect_isMsgForwardIMP(IMP impl) {
    return impl == _objc_msgForward
#if !defined(__arm64__)
    || impl == (IMP)_objc_msgForward_stret
#endif
    ;
}

static IMP aspect_getMsgForwardIMP(Class aclass, SEL selector,BOOL isInstanceMethod) {
    IMP msgForwardIMP = _objc_msgForward;
    //在非 arm64 下都会存在 Special Struct
#if !defined(__arm64__)
    // As an ugly internal runtime implementation detail in the 32bit runtime, we need to determine of the method we hook returns a struct or anything larger than id.
    // https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/LowLevelABI/000-Introduction/introduction.html
    // https://github.com/ReactiveCocoa/ReactiveCocoa/issues/783
    // http://infocenter.arm.com/help/topic/com.arm.doc.ihi0042e/IHI0042E_aapcs.pdf (Section 5.4)
    Method method;
    if (isInstanceMethod) {
        method = class_getInstanceMethod(aclass, selector);
    }else{
        method = class_getClassMethod(aclass, selector);
    }
    
    const char *encoding = method_getTypeEncoding(method)?:"v@:";
    BOOL methodReturnsStructValue = encoding[0] == _C_STRUCT_B;
    if (methodReturnsStructValue) {
        @try {
            NSUInteger valueSize = 0;
            NSGetSizeAndAlignment(encoding, &valueSize, NULL);
            
            if (valueSize == 1 || valueSize == 2 || valueSize == 4 || valueSize == 8) {
                methodReturnsStructValue = NO;
            }
        } @catch (__unused NSException *e) {}
    }
    if (methodReturnsStructValue) {
        msgForwardIMP = (IMP)_objc_msgForward_stret;
    }
#endif
    return msgForwardIMP;
}

static NSMutableDictionary * __dic;
static NSMutableDictionary * propertyMap(){
    if (!__dic) {
        __dic = [NSMutableDictionary dictionary];
    }
    return __dic;
}

static void TT_Patch_Property_Setter(id self,SEL _cmd,id obj){
    NSString *key = NSStringFromSelector(_cmd);
    key = [[key substringWithRange:NSMakeRange(3, key.length-4)] lowercaseString];
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(key), obj, OBJC_ASSOCIATION_RETAIN);
    [propertyMap() setObject:key forKey:key];
}
static id TT_Patch_Property_getter(id self,SEL _cmd){
    NSString *key = [NSStringFromSelector(_cmd) lowercaseString];
    key = [propertyMap() objectForKey:key];
    return objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(key));
}

static void AddPropertys(NSString *className,NSString *superClassName,NSArray *propertys){
    
        
        Class aClass = NSClassFromString(className);
        
        BOOL needRegistClass=NO;
        if (!aClass) {
            aClass = objc_allocateClassPair(NSClassFromString(superClassName), [className UTF8String], 0);
            needRegistClass = YES;
        }
        
        for (NSDictionary * property in propertys) {
            NSString *propertyName = [property objectForKey:@"__name"];
            /**
             targetClass:   表示要添加的属性的类
             propertyName:  表示要添加的属性名
             attrs：        类特性列表
             attrsCount:    类特性个数
             */
            NSString *propertyForSetter = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[propertyName substringToIndex:1] capitalizedString]];
            
            if (class_addMethod(aClass, NSSelectorFromString(propertyName), (IMP)TT_Patch_Property_getter, "@@:")) {
#if TTPATCH_LOG
                TTLog(@"Get添加成功:%@",propertyForSetter);
#endif
            }
            if (class_addMethod(aClass, NSSelectorFromString([NSString stringWithFormat:@"set%@:",propertyForSetter]), (IMP)TT_Patch_Property_Setter, "v@:@")) {
#if TTPATCH_LOG
                TTLog(@"Set添加成功:set%@",propertyForSetter);
#endif
            }
        }
        
        if (needRegistClass) {
            objc_registerClassPair(aClass);
        }
        
}

#define WRAP_INVOCATION_AND_RETURN(argType,vauleType)\
case argType:{  \
vauleType tempArg; \
[invocation getArgument:&tempArg atIndex:(i)];    \
[tempArguments addObject:@(tempArg)];  \
}break

#define WRAP_INVOCATION_ID_AND_RETURN(argType,vauleType)\
case argType:{  \
__unsafe_unretained vauleType tempArg; \
[invocation getArgument:&tempArg atIndex:(i)];    \
[tempArguments addObject:tempArg];  \
}break

#define WRAP_INVOCATION_RETURN_VALUE(argType,valueType,toValueFunc) \
case argType:{  \
valueType result = [[jsValue toNumber] toValueFunc];    \
[invocation setReturnValue:&result];    \
}break;

#define WRAP_INVOCATION_ID_RETURN_VALUE(argType,valueType,toValueFunc) \
case argType:{  \
__unsafe_unretained valueType result = [jsValue toValueFunc];    \
[invocation setReturnValue:&result];    \
}break;

#pragma mark- native call JS
static void OC_MSG_SEND_HANDLE(__unsafe_unretained NSObject *self, SEL invocation_selector, NSInvocation *invocation) {
    @synchronized (self) {
        
        NSDictionary* block_info_js = objc_getAssociatedObject(self, CFBridgingRetain(@"TTPATCH_OC_BLOCK"));
        JSValue * func = [TTPatch shareInstance].context[@"js_msgSend"];
        Method methodInfo = NULL;
      
        const char * returnValueType=[invocation.methodSignature methodReturnType];
        unsigned int indexOffset = 0;
        unsigned int systemMethodArgCount = (unsigned int)invocation.methodSignature.numberOfArguments;
        BOOL isBlock = block_info_js ? YES:NO;

        if (systemMethodArgCount>2) {
            indexOffset = 2;
        }
        //block invocation不包含sel所以 offset=1
        if (isBlock) {
            indexOffset = 1;
        }else{
            methodInfo= GetInstanceOrClassMethodInfo([self class],invocation.selector);
        }
        
        #if TTPATCH_LOG
        NSString * selectNameStr = isBlock?@"block":NSStringFromSelector(invocation.selector);
        TTLog(@"\n--------------------------- Message Queue Call JS ----------------%s \n| func: %@      \n| instance: %@  \n| arg: %d",isBlock?"block": method_getTypeEncoding(methodInfo),selectNameStr,self,isBlock?0:systemMethodArgCount-2);
        #endif
        NSMutableArray *tempArguments = [NSMutableArray arrayWithCapacity:systemMethodArgCount];
        
        for (unsigned i = indexOffset; i < systemMethodArgCount; i++) {
            const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:i];
            switch(argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
                    WRAP_INVOCATION_AND_RETURN(_C_INT, int);
                    WRAP_INVOCATION_AND_RETURN(_C_SHT, short);
                    WRAP_INVOCATION_AND_RETURN(_C_USHT, unsigned short);
                    WRAP_INVOCATION_AND_RETURN(_C_UINT, unsigned int);
                    WRAP_INVOCATION_AND_RETURN(_C_LNG, long);
                    WRAP_INVOCATION_AND_RETURN(_C_ULNG, unsigned long);
                    WRAP_INVOCATION_AND_RETURN(_C_LNG_LNG, long long);
                    WRAP_INVOCATION_AND_RETURN(_C_ULNG_LNG, unsigned long long);
                    WRAP_INVOCATION_AND_RETURN(_C_FLT, float);
                    WRAP_INVOCATION_AND_RETURN(_C_DBL, double);
                    WRAP_INVOCATION_AND_RETURN(_C_BOOL, BOOL);
                case _C_ID:{
                    if ('?' == argumentType[1]) {
                        __unsafe_unretained id tempArg;
                        [invocation getArgument:&tempArg atIndex:(i)];
                        TTPatchBlockModel *block = [TTPatchBlockModel new];
                        block.__isa = tempArg;
                        [tempArguments addObject:ToJsObject(block, @"block")];

                    }else{
                        __unsafe_unretained id tempArg;
                        [invocation getArgument:&tempArg atIndex:(i)];
                        [tempArguments addObject:tempArg];
                    }
                }break;
                  case _C_STRUCT_B:{
                    NSString * returnStypeStr = [NSString stringWithUTF8String:argumentType];
                    if ([returnStypeStr hasPrefix:@"{CGRect"]){
                        CGRect instance;
                        [invocation getArgument:&instance atIndex:(i)];
                        [tempArguments addObject:ToJsObject(CGReactToJSObject(instance),@"react")];
                    }
                    else if ([returnStypeStr hasPrefix:@"{CGPoint"]){
                        CGPoint instance;
                        [invocation getArgument:&instance atIndex:(i)];
                        [tempArguments addObject:ToJsObject(CGPointToJSObject(instance),@"point")];
                    }
                    else if ([returnStypeStr hasPrefix:@"{CGSize"]){
                        CGSize instance;
                        [invocation getArgument:&instance atIndex:(i)];
                        [tempArguments addObject:ToJsObject(CGSizeToJSObject(instance),@"size")];
                    }
                    else if ([returnStypeStr hasPrefix:@"{UIEdgeInsets"]){
                        UIEdgeInsets instance;
                        [invocation getArgument:&instance atIndex:(i)];
                        [tempArguments addObject:ToJsObject(UIEdgeInsetsToJSObject(instance),@"edge")];
                    }else{
                        NSCAssert(NO, @"*******%@---当前结构体暂不支持",returnStypeStr);
                    }
                }break;
            }
        }
        
   
        BOOL isInstance = YES;
        if (![self isMemberOfClass:[self class]]) {
            isInstance=NO;
        }
        
        NSMutableArray * params;
        __unsafe_unretained JSValue *jsValue;
        if (block_info_js) {
            func = block_info_js[@"__isa"];
            params  =  [NSMutableArray arrayWithArray:WrapInvocationArgs(invocation, YES)];
            jsValue = execFuncParamsBlockWithKeyAndParams(block_info_js[@"__key"], params);
        }else{
            params  = [@[[JSValue valueWithObject:self inContext:[TTPatch shareInstance].context],
                                         NSStringFromClass([self class]),
                                         MethodFormatterToJSFunc(NSStringFromSelector(invocation.selector)),
                                         @(isInstance)] mutableCopy];
            [params addObjectsFromArray:tempArguments];;
            jsValue = [func callWithArguments:params];
        }
        
        
        guard(strcmp(returnValueType, "v")==0) else{
            switch(returnValueType[0] == 'r' ? returnValueType[1] : returnValueType[0]) {
                    WRAP_INVOCATION_ID_RETURN_VALUE(_C_ID, id, toObject);
                    WRAP_INVOCATION_RETURN_VALUE(_C_INT, int, intValue);
                    WRAP_INVOCATION_RETURN_VALUE(_C_SHT, short, shortValue);
                    WRAP_INVOCATION_RETURN_VALUE(_C_USHT, unsigned short, unsignedShortValue);
                    WRAP_INVOCATION_RETURN_VALUE(_C_UINT, unsigned int, unsignedIntValue);
                    WRAP_INVOCATION_RETURN_VALUE(_C_LNG, long, longValue);
                    WRAP_INVOCATION_RETURN_VALUE(_C_ULNG, unsigned long, unsignedLongValue);
                    WRAP_INVOCATION_RETURN_VALUE(_C_LNG_LNG, long long, longLongValue);
                    WRAP_INVOCATION_RETURN_VALUE(_C_ULNG_LNG, unsigned long long, unsignedLongLongValue);
                    WRAP_INVOCATION_RETURN_VALUE(_C_FLT, float, floatValue);
                    WRAP_INVOCATION_RETURN_VALUE(_C_DBL, double, doubleValue);
                    WRAP_INVOCATION_RETURN_VALUE(_C_BOOL, BOOL, boolValue);
                    
            }
        }
    }
}


static NSString *const ForwardInvocationSelectorName = @"__ttpatch_forwardInvocation:";
static void aspect_swizzleForwardInvocation(Class klass) {
    NSCParameterAssert(klass);
    IMP originalImplementation = class_replaceMethod(klass, @selector(forwardInvocation:), (IMP)OC_MSG_SEND_HANDLE, "v@:");
    if (originalImplementation) {
        class_addMethod(klass, NSSelectorFromString(ForwardInvocationSelectorName), originalImplementation, "v@:");
    }

}

static void aspect_prepareClassAndHookSelector(Class cls, SEL selector, BOOL isInstanceMethod) {
    NSCParameterAssert(selector);
    Method targetMethod = isInstanceMethod?class_getInstanceMethod(cls, selector):class_getClassMethod(cls, selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    /**
     *这里将native不存在的方法,默认签名为 入参 @, return @,防止因签名原因无法获取参数列表.
     */
    const char *typeEncoding = method_getTypeEncoding(targetMethod)?:"@@:@";
    guard(aspect_isMsgForwardIMP(targetMethodIMP))else{
        
        SEL new_SEL = NSSelectorFromString([NSString stringWithFormat:@"%@%@", TTPatchChangeMethodPrefix, NSStringFromSelector(selector)]);
        class_addMethod(cls, new_SEL, method_getImplementation(targetMethod), typeEncoding);

    }
    class_replaceMethod(cls, selector, aspect_getMsgForwardIMP(cls, selector, isInstanceMethod), typeEncoding);

}

static void HookClassMethod(NSString *className,NSString *superClassName,NSString *method,BOOL isInstanceMethod,NSArray *propertys){
    ttpatch_performLocked(^{
        
        if(checkRegistedMethod(method, className, !isInstanceMethod)){
            return;
        }
        static NSSet *disallowedSelectorList;
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            disallowedSelectorList = [NSSet setWithObjects:@"retain", @"release", @"autorelease", @"forwardInvocation:", nil];
        });
        
        
        if ([disallowedSelectorList containsObject:method]) {
            NSString *errorDescription = [NSString stringWithFormat:@"Selector %@ is blacklisted.", method];
            NSCAssert(NO, errorDescription);
        }
        
        #if TTPATCH_LOG
        TTLog(@"%@替换 %@ %@", className, isInstanceMethod?@"-":@"+", method);
        #endif
        Class aClass = NSClassFromString(className);
        SEL original_SEL = NSSelectorFromString(method);
        Method originalMethodInfo = class_getInstanceMethod(aClass, original_SEL);
        
        
        //    tt_addPropertys(className, superClassName, propertys);
        
        //如果是静态方法,要取 MetaClass
        guard(isInstanceMethod) else{
            originalMethodInfo = class_getClassMethod(aClass, original_SEL);
            aClass = object_getClass(aClass);
        }
        
        /**
         *  这里为什么要替换 `ForwardInvocation` 而不是替换对应方法要解释一下
         *  因为添加的 `IMP` 是固定的函数,而函数的返回值类型,以及返回值有无,在写的时候就已经固定了.所以我们会面临两个问题
         *  1.要根据当前被替换方法返回值类型,提前注册好对应的`IMP`函数,使得函数能拿到正确的数据类型.
         *  2.要如何知道当前方法是否有返回值,以及返回值的类型是什么?
         *
         *  因为这两个原因很麻烦,当然是用 穷举+方法返回值加标识 可以解决这个问题,但是我感觉这么做是一个坑.最后找到根据 `aspect` 和 `JSPatch`的作者blog,为什么他们都要hook `ForwardInvocation` 这个方法.其实原因很简单,在这个时候我们能够拿到当前系统调用中方法的 `invocation` 对象,也就意味着能够拿到当前方法的全部信息,而且我们此时也能去根据`js`替换后方法的返回值去`set`当前`invocation`对象的返回值,使当前无论返回值使什么类型,我们都可以根据当前的方法签名来对应为其转换为相应类型.
         */
        aspect_swizzleForwardInvocation(aClass);
        /**
         *  将要我换的方法IMP替换成`_objc_msgForward`,这么做的原因其实是为了优化方法调用时间.
         *  假如我们不做方法替换,系统在执行`objc_msgSend`函数,这样会根据当前的对象的继承链去查找方法然后执行,这里就涉及到一个查找的过程
         *  如果查找不到方法,会走消息转发也就是`_objc_msgForward`函数做的事情,所以那我们为什么不直接将方法的`IMP`替换为`_objc_msgForward`直接走消息转发呢
         */
        aspect_prepareClassAndHookSelector(aClass, original_SEL, isInstanceMethod);
        
        //将已经替换的class做记录
        registerMethod(method, className, !isInstanceMethod);
        
        
    });
  
}



#pragma makr- Native API
- (void)configJSBrigeActions{
    self[@"Utils_Log"] = ^(log_level level,id msg){
        switch (level) {
            case log_level_debug:
                TTLog(@"%@",msg);
                break;
            case log_level_info:
                TTLog_Info(@"%@",msg);
                break;
            case log_level_error:
                TTLog_Error(@"%@",msg);
                break;
            default:
                TTLog(@"%@",msg);
                break;
        }
//        TTLog(@"🍎🍎🍎🍎🍎🍎🍎-------------->%@",msg);
    };
    self[@"MessageQueue_oc_define"] = ^(NSString * interface){
        NSArray * classAndSuper = [interface componentsSeparatedByString:@":"];
        return @{@"self":[classAndSuper firstObject],
                 @"super":[classAndSuper lastObject]
                 };
    };
    
    self[@"MessageQueue_oc_sendMsg"] = ^(id obj,BOOL isSuper,BOOL isBlock,NSString* method,id arguments){
        return DynamicMethodInvocation(obj, isSuper,isBlock,MethodFormatterToOcFunc(method),arguments);
    };
    
    self[@"MessageQueue_oc_block"] = ^(id obj, id arguments){
        TTPatchBlockModel *blockModel = (TTPatchBlockModel *)obj;
     
        return DynamicBlock(blockModel.__isa, arguments);
    };
    
    self[@"MessageQueue_oc_replaceMethod"] = ^(NSString *className,NSString *superClassName,NSString *method,BOOL isInstanceMethod,NSArray*propertys){
        HookClassMethod(className, superClassName, MethodFormatterToOcFunc(method), isInstanceMethod, propertys);
    };
    self[@"MessageQueue_oc_addPropertys"] = ^(NSString *className,NSString *superClassName,NSArray*propertys){
        AddPropertys(className, superClassName,propertys);
    };
    self[@"MessageQueue_oc_setBlock"] = ^(id jsFunc){
//        TTLog(@"jsfunc-----%p",jsFunc);
    };
    self[@"APP_IsDebug"] = ^(NSString *className,NSString *superClassName,NSArray*propertys){
#if DEBUG
        return YES;
#else
        return NO;
#endif
        
    };
    
}

- (JSValue *)getBlockFunc{
    return self[@"jsBlock"];
}

- (id)execFuncParamsBlockWithBlockKey:(NSString *)key
                            arguments:(NSArray *)arguments{
    JSValue *func = [self getBlockFunc];
    NSMutableArray *tempArguments = [NSMutableArray arrayWithObject:key];
    [tempArguments addObjectsFromArray:arguments];
    return [func callWithArguments:tempArguments];
}

-(NSMutableDictionary *)replaceMethodMap{
    return __replaceMethodMap;
}
@end





@implementation TTMethodList_Node


+ (TTMethodList_Node *)createNodeCls:(NSString *)clsName
                          methodName:(NSString *)methodName
                             isClass:(BOOL)isClass{
    TTMethodList_Node * node = [TTMethodList_Node new];
    node.clsName        = clsName;
    node.methodName     = methodName;
    node.key            = [NSString stringWithFormat:@"%@-%@%@",clsName,methodName,isClass?@"+":@"-"];
    node.isClass        = isClass;
    return node;
}

@end


