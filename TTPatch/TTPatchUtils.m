//
//  TTPatchUtils.m
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTPatchUtils.h"
#include <stdio.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "TTPatch.h"
#import "TTContext.h"
#define TTPATCH_DERIVE_PRE @"TTPatch_Derive_"

#define guard(condfion) if(condfion){}
#define TTPatchInvocationException @"TTPatchInvocationException"
#define TTCheckArguments(flag,arguments)\
if (![arguments isKindOfClass:[NSNull class]] &&\
arguments != nil && \
arguments.count > 0) {  \
flag = YES;  \
}

#define CONDIF_ARGUMENT_TYPES_ENCODE(__clsTypeStr,__cls)\
else if ([clsType isEqualToString:__clsTypeStr]){\
[methodTypes appendString:[NSString stringWithUTF8String:@encode(__cls)]];}

typedef id(^TTPATCH_OC_BLOCK)(id arg0,...);

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

static void setInvocationArguments(NSInvocation *invocation,NSArray *arguments){
    for (int i = 0; i < arguments.count; i++) {
        __unsafe_unretained id argument = ([arguments objectAtIndex:i]);
        guard([argument isKindOfClass:NSDictionary.class]) else{
            [invocation setArgument:&argument atIndex:(2 + i)];
            continue;
        }
        NSString * clsType = [argument objectForKey:@"__className"];
        if (clsType) {
            NSString *str = [argument objectForKey:@"__isa"];
            if ([clsType isEqualToString:@"react"]){
                CGRect ocBaseData = toOcCGReact(str);

                [invocation setArgument:&ocBaseData atIndex:(2 + i)];
            }else if ([clsType isEqualToString:@"point"]){
                CGPoint ocBaseData = toOcCGPoint(str);
                [invocation setArgument:&ocBaseData atIndex:(2 + i)];
            }
            else if ([clsType isEqualToString:@"size"]){
                CGSize ocBaseData = toOcCGSize(str);
                [invocation setArgument:&ocBaseData atIndex:(2 + i)];
            }
        }
        else{
            [invocation setArgument:&argument atIndex:(2 + i)];
        }
        
    }
}

static id execFuncParamsBlockWithKeyAndParams(NSString *key,NSArray *params){
    return [[TTPatch shareInstance].context execFuncParamsBlockWithBlockKey:key arguments:params];
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
        switch(flag) {
            case _C_PTR:
            case _C_ID:
            {
                if ('?' == argumentType[1]) {
                    __block NSDictionary *blockDic = ([arguments objectAtIndex:i]);
                    TTPATCH_OC_BLOCK block;
                    if ([[blockDic objectForKey:@"__isHasParams"] boolValue]) {
                    block = (id)^(id arg0,...){
                         NSMutableArray *tempArguments = [NSMutableArray array];
                         [tempArguments addObject:arg0];
                            va_list argList;
                            va_start(argList, arg0);
                            for (int i = 0; i < systemMethodArgCount; i++) {
                                id tempArg = va_arg(argList, id);
                                [tempArguments addObject:tempArg];
                            }
                            va_end(argList);
                         return execFuncParamsBlockWithKeyAndParams([blockDic objectForKey:@"__key"], tempArguments);
                    };
                    }else{
                        block = (id)^(void){
                            return execFuncParamsBlockWithKeyAndParams([blockDic objectForKey:@"__key"], @[]);
                        };
                    }
          
                    
                    [invocation setArgument:&block atIndex:(startIndex + i)];
                    objc_setAssociatedObject(invocation , CFBridgingRetain([NSString stringWithFormat:@"TTPATCH_OC_BLOCK%@",[blockDic objectForKey:@"__key"]]), block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

static void setInvocationArgumentsBlock(NSInvocation *invocation,NSArray *arguments){
    //默认 target->0,arg->1..
    int startIndex = 1;
    //    //如果block调用,selector则为nil,所以 index从 1 开始
    //    if (!invocation.selector) {
    //        int systemMethodArgCount = (int)invocation.methodSignature.numberOfArguments;
    //        startIndex = 1;
    //        indexOffset = 1;
    //    }
    int indexOffset = 1;
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
        switch(flag) {
            case _C_ID:
            {
                 id argument = ([arguments objectAtIndex:i]);
                [invocation setArgument:&argument atIndex:(startIndex + i)];
                
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


static char * GetMethodTypes(NSString *method,NSArray *arguments){
    BOOL hasReturnValue = NO;
    NSMutableString *methodTypes = [NSMutableString string];
    if ([method hasPrefix:@"$"]) {
        hasReturnValue = YES;
        method = [method stringByReplacingOccurrencesOfString:@"$" withString:@""];
        [methodTypes appendString:@"@"];
    }
    [methodTypes appendString:@"@:"];
    //如果有参数
    if ([method rangeOfString:@"_"].length > 0) {
        method = [method stringByReplacingOccurrencesOfString:@"_" withString:@":"];
    }
    for (int i = 0; i < arguments.count; i++) {
        __unsafe_unretained id argument = ([arguments objectAtIndex:i]);
        if ([argument isKindOfClass:NSDictionary.class]) {
            NSString * clsType = [argument objectForKey:@"__className"];
            guard(clsType==nil || [clsType isKindOfClass:[NSNull class]])
            CONDIF_ARGUMENT_TYPES_ENCODE(@"int", int)
            CONDIF_ARGUMENT_TYPES_ENCODE(@"long", long)
            CONDIF_ARGUMENT_TYPES_ENCODE(@"float", float)
            CONDIF_ARGUMENT_TYPES_ENCODE(@"char", char)
            CONDIF_ARGUMENT_TYPES_ENCODE(@"bool", BOOL)
            CONDIF_ARGUMENT_TYPES_ENCODE(@"void", void)
            CONDIF_ARGUMENT_TYPES_ENCODE(@"obj", NSString *)
            CONDIF_ARGUMENT_TYPES_ENCODE(@"class", typeof([NSObject class]))
            
        }
    }
 
    return "a";
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
//                        NSLog(@"Alloc Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)returnValue));
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
            NSLog(@"\n -----------------Message Queue Call Native ---------------\n | %@ \n | 参数个数:%ld \n | %s \n | %@ \n -----------------------------------" ,method,signature.numberOfArguments,method_getTypeEncoding(methodInfo),arguments);
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



static id DynamicBlockWithInvocation(id block, NSInvocation *invocation){
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
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
//    [invocation setTarget:block];
////    setInvocationArgumentsMethod(invocation, arguments,YES);
//    [invocation invoke];
    NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:signature];
    NSInvocation *originalInvocation = invocation;
    NSUInteger numberOfArguments = signature.numberOfArguments;
    NSUInteger originalNumberOfArguments = originalInvocation.methodSignature.numberOfArguments;
//    if (numberOfArguments > 1) {
//         [blockInvocation setArgument:&info atIndex:1];
//     }
    id argBuf = NULL;
    for (NSUInteger idx = 1; idx < numberOfArguments; idx++) {
        const char *type = [blockInvocation.methodSignature getArgumentTypeAtIndex:idx];
        NSUInteger argSize;
        NSGetSizeAndAlignment(type, &argSize, NULL);
        
//        if (!(argBuf = reallocf(argBuf, argSize))) {
//            AspectLogError(@"Failed to allocate memory for block invocation.");
//            return NO;
//        }
        
        [originalInvocation getArgument:&argBuf atIndex:idx+1];
        [blockInvocation setArgument:&argBuf atIndex:idx];
    }
    [blockInvocation invokeWithTarget:block];
    
//    if (argBuf != NULL) {
//          free(argBuf);
//    }
    guard(strcmp(signature.methodReturnType,"v") == 0)else{
        return WrapInvocationResult(invocation, signature);
    }
    return nil;
}





const struct TTPatchUtils TTPatchUtils = {
    .TTPatchDynamicMethodInvocation               = DynamicMethodInvocation,
    .TTPatchDynamicBlock                          = DynamicBlock,
    .TTDynamicBlockWithInvocation                 = DynamicBlockWithInvocation,
    .TTPatchGetMethodTypes                        = GetMethodTypes,
    .TTPatchMethodFormatterToOcFunc               = MethodFormatterToOcFunc,
    .TTPatchMethodFormatterToJSFunc               = MethodFormatterToJSFunc,
    .TTPatchGetInstanceOrClassMethodInfo          = GetInstanceOrClassMethodInfo,
//    .TTPatchToJsObject                            = ToJsObject
};


