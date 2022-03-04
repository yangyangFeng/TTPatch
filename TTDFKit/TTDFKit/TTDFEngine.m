//
//  TTDFEngine.m
//  Pods-Example
//
//  Created by tianyubing on 2020/7/29.
//

#import "TTDFEngine.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>

#import "TTDFKit.h"
#import "ffi.h"

NSString *const TTDFKitChangeMethodPrefix = @"tt";
NSString *const kMessageQueue_oc_define = @"MessageQueue_oc_define";
NSString *const kMessageQueue_oc_sendMsg = @"MessageQueue_oc_sendMsg";
NSString *const kMessageQueue_oc_block = @"MessageQueue_oc_block";
NSString *const kMessageQueue_oc_replaceMethod = @"MessageQueue_oc_replaceMethod";
NSString *const kMessageQueue_oc_replaceDynamicMethod = @"MessageQueue_oc_replaceDynamicMethod";
NSString *const kMessageQueue_oc_addPropertys = @"MessageQueue_oc_addPropertys";
NSString *const kMessageQueue_oc_genBlock = @"MessageQueue_oc_genBlock";
NSString *const kAPP_IsDebug = @"APP_IsDebug";
NSString *const kUtils_Log = @"Utils_Log";
NSString *const kIsOpenJSLog = @"IsOpenJSLog";
NSString *const TTDFKitInvocationException = @"TTDFKitInvocationException";

@implementation TTDFEngine

static void TTDFKit_performLocked(dispatch_block_t block) {
    if (!TTDFKit_lock) {
        TTDFKit_lock = [NSRecursiveLock new];
    }
    [TTDFKit_lock lock];
    block();
    [TTDFKit_lock unlock];
}

static NSString *trim(NSString *string) {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/// 根据 Class 字符串拼接的方法签名, 构造真实方法签名
/// @param signatureStr 字符串参数类型 例'void,NSString*'
/// @param isBlock 是否构造block签名
static NSString *CreateSignatureWithString(NSString *signatureStr, bool isBlock) {
    static NSMutableDictionary *typeSignatureDict;
    if (!typeSignatureDict) {
        typeSignatureDict =
            [NSMutableDictionary dictionaryWithObject:@[[NSString stringWithUTF8String:@encode(dispatch_block_t)], @(sizeof(dispatch_block_t))]
                                               forKey:@"?"];
#define JP_DEFINE_TYPE_SIGNATURE(_type) \
    [typeSignatureDict setObject:@[[NSString stringWithUTF8String:@encode(_type)], @(sizeof(_type))] forKey:@ #_type];

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
        JP_DEFINE_TYPE_SIGNATURE(void *);
        JP_DEFINE_TYPE_SIGNATURE(NSString *);
        JP_DEFINE_TYPE_SIGNATURE(NSNumber *);
    }
    NSArray *lt = [signatureStr componentsSeparatedByString:@","];
    /**
     * 这里注意下block与func签名要区分下,block中没有_cmd, 并且要用@?便是target
     */
    NSString *funcSignature = isBlock ? @"@?0" : @"@0:8";
    NSInteger size = isBlock ? sizeof(void *) : sizeof(void *) + sizeof(SEL);
    for (NSInteger i = 1; i < lt.count;) {
        NSString *t = trim(lt[i]);
        NSString *tpe = typeSignatureDict[typeSignatureDict[t] ? t : @"id"][0];
        if (i == 0) {
            if (!t || t.length == 0)
                funcSignature = [[NSString stringWithFormat:@"%@%@", tpe, [@(size) stringValue]] stringByAppendingString:funcSignature];
            else
                funcSignature = [[NSString stringWithFormat:@"%@%@", tpe, [@(size) stringValue]] stringByAppendingString:funcSignature];
            break;
        } else {
            funcSignature = [funcSignature stringByAppendingString:[NSString stringWithFormat:@"%@%@", tpe, [@(size) stringValue]]];
            size += [typeSignatureDict[typeSignatureDict[t] ? t : @"id"][1] integerValue];
        }
        i = (i == lt.count - 1) ? 0 : i + 1;
    }

    return funcSignature;
}

#define TT_ARG_Injection(charAbbreviation, type, func)               \
    case charAbbreviation: {                                         \
        NSNumber *jsObj = arguments[i];                              \
        type argument = [jsObj func];                                \
        [invocation setArgument:&argument atIndex:(startIndex + i)]; \
    } break;
static void setInvocationArgumentsMethod(NSInvocation *invocation, NSArray *arguments, BOOL isBlock) {
    //默认 target->0,_cmd->1,arg->2..
    int startIndex = 2;
    //@:@ count=3 参数个数1
    int indexOffset = 2;
    if (isBlock) {
        startIndex = 1;
        indexOffset = 1;
    }
    int systemMethodArgCount = (int)invocation.methodSignature.numberOfArguments;
    if (systemMethodArgCount > indexOffset) {
        systemMethodArgCount -= indexOffset;
    } else {
        systemMethodArgCount = 0;
        return;
    }

    guard(systemMethodArgCount == arguments.count) else {
        NSCAssert(NO, [NSString stringWithFormat:@"参数个数不匹配,请检查!"]);
    }

    for (int i = 0; i < systemMethodArgCount; i++) {
        const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:i + indexOffset];
        char flag = argumentType[0] == 'r' ? argumentType[1] : argumentType[0];
        id argument = ([arguments objectAtIndex:i]);
        if (argument == nil || [argument isKindOfClass:[NSNull class]]) {
            argument = nil;
            [invocation setArgument:&argument atIndex:(startIndex + i)];
            continue;
        }
        switch (flag) {
            case _C_PTR:
            case _C_ID: {
                if ('?' == argumentType[1]) {
                    TTDFBlockHelper *blockHelper = [arguments objectAtIndex:i];
                    void (^blockImp)(void) = blockHelper.blockPtr;
                    [invocation setArgument:&blockImp atIndex:(startIndex + i)];
                } else {
                    id argument = [arguments objectAtIndex:i];
                    argument = ToOcObject(argument);
                    [invocation setArgument:&argument atIndex:(startIndex + i)];
                }
            } break;
            case _C_STRUCT_B: {
                id argument = ([arguments objectAtIndex:i]);
                NSString *clsType = [argument objectForKey:@"__className"];
                guard(clsType) else {
                    NSCAssert(NO,
                        [NSString stringWithFormat:@"***************方法签名入参为结构体,当前JS返回params未能获取当前结构体类型,请检查************"]);
                }
                NSString *str = [argument objectForKey:@"__isa"];
                if ([clsType isEqualToString:@"react"]) {
                    CGRect ocBaseData = toOcCGReact(str);

                    [invocation setArgument:&ocBaseData atIndex:(startIndex + i)];
                } else if ([clsType isEqualToString:@"point"]) {
                    CGPoint ocBaseData = toOcCGPoint(str);
                    [invocation setArgument:&ocBaseData atIndex:(startIndex + i)];
                } else if ([clsType isEqualToString:@"size"]) {
                    CGSize ocBaseData = toOcCGSize(str);
                    [invocation setArgument:&ocBaseData atIndex:(startIndex + i)];
                } else if ([clsType isEqualToString:@"edge"]) {
                    UIEdgeInsets ocBaseData = toOcEdgeInsets(str);
                    [invocation setArgument:&ocBaseData atIndex:(startIndex + i)];
                }
            } break;
            case 'c': {
                JSValue *jsObj = arguments[i];
                char argument[1000];
                strcpy(argument, (char *)[[jsObj toString] UTF8String]);
                [invocation setArgument:&argument atIndex:(startIndex + i)];
            } break;
            case _C_SEL: {
                SEL argument = NSSelectorFromString([arguments objectAtIndex:i]);
                [invocation setArgument:&argument atIndex:(startIndex + i)];
            } break;
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

#pragma mark - wrap Oc data To JS
#define TT_RETURN_WRAP(typeChar, type)         \
    case typeChar: {                           \
        type instance;                         \
        [invocation getReturnValue:&instance]; \
        return @(instance);                    \
    } break;
static id WrapOcToJsInvocationResult(NSInvocation *invocation, NSMethodSignature *signature) {
    // TODO:block返回值 jsObjToOcObj
    NSString *method;
    if (invocation.selector) {
        method = NSStringFromSelector(invocation.selector);
    }
    const char *argumentType = signature.methodReturnType;
    char flag = argumentType[0] == 'r' ? argumentType[1] : argumentType[0];

    switch (flag) {
        case _C_ID: {
            id returnValue;
            void *result;
            [invocation getReturnValue:&result];
            if ([method isEqualToString:@"alloc"] || [method isEqualToString:@"new"]) {
                returnValue = (__bridge_transfer id)result;
                TTLog_Debug(@"Alloc Retain count is %ld", CFGetRetainCount((__bridge CFTypeRef)returnValue));
            } else {
                returnValue = (__bridge id)result;
            }
            return returnValue ? ToJsObject(returnValue, nil) : [NSNull null];
        } break;
        case _C_CLASS: {
            __unsafe_unretained Class instance = nil;
            [invocation getReturnValue:&instance];
            return ToJsObject(nil, NSStringFromClass(instance));
        } break;
        case _C_STRUCT_B: {
            NSString *returnStypeStr = [NSString stringWithUTF8String:signature.methodReturnType];
            if ([returnStypeStr hasPrefix:@"{CGRect"]) {
                CGRect instance;
                [invocation getReturnValue:&instance];
                return ToJsObject(CGReactToJSObject(instance), @"react");
            } else if ([returnStypeStr hasPrefix:@"{CGPoint"]) {
                CGPoint instance;
                [invocation getReturnValue:&instance];
                return ToJsObject(CGPointToJSObject(instance), @"point");
            } else if ([returnStypeStr hasPrefix:@"{CGSize"]) {
                CGSize instance;
                [invocation getReturnValue:&instance];
                return ToJsObject(CGSizeToJSObject(instance), @"size");
            } else if ([returnStypeStr hasPrefix:@"{UIEdgeInsets"]) {
                UIEdgeInsets instance;
                [invocation getReturnValue:&instance];
                return ToJsObject(UIEdgeInsetsToJSObject(instance), @"edge");
            }
            NSCAssert(NO, @"*******%@---当前结构体暂不支持", returnStypeStr);
        } break;
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

#pragma mark - js 动态调用Oc函数
static id DynamicBlock(TTDFKitBlockModel *blockModel, NSArray *arguments, NSString *custom_signature) {
    struct TTDFKitBlock *blockLayout = (__bridge void *)blockModel.__isa;
    void *desc = blockLayout->descriptor;
    desc += 2 * sizeof(unsigned long int);

    // iOS 13有些系统block没有签名,导致无法动态调用.所以这里支持手动创建签名
    if (!(blockLayout->flags & TTDFKit_BLOCK_HAS_SIGNATURE) && (custom_signature && custom_signature.length)) {
        const char *c_custome_signature = [CreateSignatureWithString(custom_signature, YES) cStringUsingEncoding:NSUTF8StringEncoding];
        size_t size = sizeof(&c_custome_signature);
        memcpy(&blockLayout->descriptor->signature, &c_custome_signature, size);
    }
    guard((blockLayout->descriptor->signature != nil)) else {
        @throw [NSException exceptionWithName:TTDFKitInvocationException
                                       reason:[NSString stringWithFormat:@"block 结构体中无法获取 signature"]
                                     userInfo:nil];
        return nil;
    }
    if (blockLayout->flags & TTDFKit_BLOCK_HAS_COPY_DISPOSE) {
        desc += 2 * sizeof(void *);
    }
    const char *c_signature = (*(const char **)desc);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:c_signature];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    //防止临时变量被释放(js传入对象没有问题)
    [invocation retainArguments];
    [invocation setTarget:blockModel.__isa];
    setInvocationArgumentsMethod(invocation, arguments, YES);

    [invocation invoke];

    guard(strcmp(signature.methodReturnType, "v") == 0) else {
        return WrapOcToJsInvocationResult(invocation, signature);
    }
    return nil;
}

#define TTCheckArguments(flag, arguments)                                                       \
    if (![arguments isKindOfClass:[NSNull class]] && arguments != nil && arguments.count > 0) { \
        flag = YES;                                                                             \
    }
static id DynamicMethodInvocation(id classOrInstance, NSString *className, BOOL isSuper, BOOL isBlock, NSString *method, NSArray *arguments) {
    Class TTDFKit_cur_class = [classOrInstance class];
    if (isSuper) {
        //通过直接替换当前isa为父类isa,实现super语法
        //        object_setClass(classOrInstance, [classOrInstance superclass]);
        object_setClass(classOrInstance, NSClassFromString(className));
        Class curSuperClass = [classOrInstance superclass];
        object_setClass(classOrInstance, curSuperClass);
    }
    BOOL hasArgument = NO;
    TTCheckArguments(hasArgument, arguments);
    if ([classOrInstance isKindOfClass:NSNull.class]) {
        Class classOrInstanceTmp = NSClassFromString(className);
        classOrInstance = classOrInstanceTmp ?: classOrInstance;
    }
    SEL sel_method = NSSelectorFromString(method);

    NSMethodSignature *signature = [classOrInstance methodSignatureForSelector:sel_method];
    guard(signature) else {
        @throw [NSException exceptionWithName:TTDFKitInvocationException
                                       reason:[NSString stringWithFormat:@"没有找到 '%@' 中的 %@ 方法", classOrInstance, method]
                                     userInfo:nil];
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    if ([classOrInstance respondsToSelector:sel_method]) {
        TTLog_Debug(@"\n -----------------Message Queue Call Native ---------------\n | %@ \n | 参数个数:%ld \n | %@ \n "
                    @"-----------------------------------",
            method, signature.numberOfArguments, arguments);

        [invocation retainArguments];
        [invocation setTarget:classOrInstance];
        [invocation setSelector:sel_method];
        if (hasArgument) {
            setInvocationArgumentsMethod(invocation, arguments, NO);
        }

        [invocation invoke];
        guard(strcmp(signature.methodReturnType, "v") == 0) else {
            return WrapOcToJsInvocationResult(invocation, signature);
        }
    }

    if (isSuper) {
        object_setClass(classOrInstance, TTDFKit_cur_class);
    }
    return nil;
}

/**
 *  TTDFKit 动态方法前缀
 */
static NSRecursiveLock *TTDFKit_lock = nil;
static NSMutableDictionary *__replaceMethodMap;

void __registerMethod(NSString *method, NSString *class, BOOL isClass) {
    if (!__replaceMethodMap) {
        __replaceMethodMap = [NSMutableDictionary dictionary];
    }
    TTMethodList_Node *node = [TTMethodList_Node createNodeCls:class methodName:method isClass:isClass];
    [__replaceMethodMap setObject:node forKey:node.key];
}

BOOL __checkRegistedMethod(NSString *method, NSString *class, BOOL isClass) {
    TTMethodList_Node *node = [TTMethodList_Node createNodeCls:class methodName:method isClass:isClass];
    if ([__replaceMethodMap objectForKey:node.key]) {
        return YES;
    }
    return NO;
}

#pragma mark - add propertys
static NSMutableDictionary *__dic;
static NSMutableDictionary *propertyMap() {
    if (!__dic) {
        __dic = [NSMutableDictionary dictionary];
    }
    return __dic;
}

static void TT_Patch_Property_Setter(id self, SEL _cmd, id obj) {
    NSString *key = NSStringFromSelector(_cmd);
    key = [[key substringWithRange:NSMakeRange(3, key.length - 4)] lowercaseString];
    objc_setAssociatedObject(self, (__bridge const void *_Nonnull)(key), obj, OBJC_ASSOCIATION_RETAIN);
    [propertyMap() setObject:key forKey:key];
}
static id TT_Patch_Property_getter(id self, SEL _cmd) {
    NSString *key = [NSStringFromSelector(_cmd) lowercaseString];
    key = [propertyMap() objectForKey:key];
    return objc_getAssociatedObject(self, (__bridge const void *_Nonnull)(key));
}

static void AddPropertys(NSString *className, NSString *superClassName, NSArray *propertys) {
    Class aClass = NSClassFromString(className);

    BOOL needRegistClass = NO;
    if (!aClass) {
        aClass = objc_allocateClassPair(NSClassFromString(superClassName), [className UTF8String], 0);
        needRegistClass = YES;
    }

    for (NSDictionary *property in propertys) {
        NSString *propertyName = [property objectForKey:@"__name"];
        /**
         targetClass:   表示要添加的属性的类
         propertyName:  表示要添加的属性名
         attrs：        类特性列表
         attrsCount:    类特性个数
         */
        NSString *propertyForSetter = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                                            withString:[[propertyName substringToIndex:1] capitalizedString]];

        if (class_addMethod(aClass, NSSelectorFromString(propertyName), (IMP)TT_Patch_Property_getter, "@@:")) {
            TTLog_Info(@"[Getter]%@.%@ add success!!!", NSStringFromClass(aClass), propertyForSetter);
        }
        if (class_addMethod(
                aClass, NSSelectorFromString([NSString stringWithFormat:@"set%@:", propertyForSetter]), (IMP)TT_Patch_Property_Setter, "v@:@")) {
            TTLog_Info(@"[Setter]%@.%@ add success!!!", NSStringFromClass(aClass), propertyForSetter);
        }
    }

    if (needRegistClass) {
        objc_registerClassPair(aClass);
    }
}

#pragma mark - hook method
static void replaceMethod(Class cls, SEL selector, BOOL isInstanceMethod, NSString *signature) {
    NSString *selName = NSStringFromSelector(selector);
    NSString *clsName = NSStringFromClass(cls);
    if (__checkRegistedMethod(selName, clsName, !isInstanceMethod)) {
        return;
    }

    Method targetMethod = isInstanceMethod ? class_getInstanceMethod(cls, selector) : class_getClassMethod(cls, selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);

    NSString *signatureStr;
    if (!signature || !signature.length) {
        signatureStr = @"@@:@";
    } else {
        signatureStr = CreateSignatureWithString(signature, NO);
    }

    /**
     *这里将native不存在的方法,默认签名为 入参 @, return @,防止因签名原因无法获取参数列表.
     */
    const char *typeEncoding = method_getTypeEncoding(targetMethod) ?: [signatureStr cStringUsingEncoding:NSUTF8StringEncoding];

    // libffi版本实现
    NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:typeEncoding];
    unsigned int argCount = (unsigned int)[sig numberOfArguments];
    void *imp = NULL;
    ffi_cif *cif = malloc(sizeof(ffi_cif));  //不可以free
    ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&imp);
    ffi_type *returnType = (ffi_type *)typeEncodingToFfiType(sig.methodReturnType);
    ffi_type **args = malloc(sizeof(ffi_type *) * argCount);
    for (int i = 0; i < argCount; i++) {
        args[i] = (ffi_type *)typeEncodingToFfiType([sig getArgumentTypeAtIndex:(NSUInteger)i]);
    }
    if (ffi_prep_cif(cif, FFI_DEFAULT_ABI, argCount, returnType, args) == FFI_OK) {
        NSDictionary *userInfo = @{@"class": NSStringFromClass(cls), @"typeEncoding": @(typeEncoding)};
        CFTypeRef cfuserInfo = (__bridge_retained CFTypeRef)userInfo;
        ffi_prep_closure_loc(closure, cif, OnCallJavaScriptMessageHandlerIMP, (void *)cfuserInfo, imp);
    }

    // 保存原方法为origin+原方法名
    NSString *originalSelectorName = [NSString stringWithFormat:@"%@%@", TTDFKitChangeMethodPrefix, selName];
    SEL originalSelector = NSSelectorFromString(originalSelectorName);
    if (!class_respondsToSelector(cls, originalSelector)) {
        class_addMethod(cls, originalSelector, targetMethodIMP, typeEncoding);
        __registerMethod(selName, clsName, isInstanceMethod);
    }

    class_replaceMethod(cls, selector, imp, typeEncoding);
}
#pragma mark - Oc invocation js
/*
 * 消息转发IMP以及参数转换
 */
static void OnCallJavaScriptMessageHandlerIMP(ffi_cif *cif, void *ret, void **args, void *userdata) {
    TTDFKit_performLocked(^{
        NSDictionary *userInfo = (__bridge id)userdata;  // 不可以进行释放
        NSString *typeEncoding = userInfo[@"typeEncoding"];
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:typeEncoding.UTF8String];
        NSMutableArray *params = [[NSMutableArray alloc] init];
        JSValue *func;
        __unsafe_unretained JSValue *jsValue;

        [params addObjectsFromArray:GetParamFromArgs(args, typeEncoding.UTF8String)];
        func = [TTDFEntry shareInstance].context.messageQueue;
        jsValue = [func callWithArguments:params];

        ConvertReturnValue([methodSignature methodReturnType], jsValue, ret);
    });
}

#define TT_WARP_JS_ARGS(caseId, type) \
    case caseId: {                    \
        type argValue = *(type *)arg; \
        return @(argValue);           \
    } break;
static NSArray *GetParamFromArgs(void **args, const char *typeEncoding) {
    NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:typeEncoding];
    NSUInteger systemMethodArgCount = methodSignature.numberOfArguments;
    NSMutableArray *tempArguments = [NSMutableArray arrayWithCapacity:systemMethodArgCount];
    id assignSlf = (__bridge id)(*(void **)args[0]);
    SEL sel = *(void **)args[1];
    [tempArguments addObject:assignSlf ? [JSValue valueWithObject:assignSlf inContext:[TTDFEntry shareInstance].context] : [NSNull null]];
    [tempArguments addObject:GetSuperClass(assignSlf)];
    [tempArguments addObject:MethodFormatterToJSFunc(NSStringFromSelector(sel))];
    BOOL isInstance = YES;
    if (![assignSlf isMemberOfClass:[assignSlf class]]) {
        isInstance = NO;
    }
    [tempArguments addObject:@(isInstance)];
    for (unsigned i = 2; i < systemMethodArgCount; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        [tempArguments addObject:WrapParamsWithTypeChar(args, argumentType, i)];
    }
    return tempArguments.copy;
}

/// 查找当前转发对象父类是否被替换
/// @param target   当前实例
static NSString *GetSuperClass(id target) {
    NSMutableDictionary *dictionary = [TTDFEngine getReplaceMethodMap];
    NSString *className = NSStringFromClass([target class]);
    NSArray *keys = dictionary.allKeys;
    for (NSString *key in keys) {
        NSArray *classKeys = [key componentsSeparatedByString:@"-"];
        NSString *targetClassName = classKeys.firstObject;
        if ([target isKindOfClass:NSClassFromString(targetClassName)]) {
            className = targetClassName;
            break;
        }
    }
    return className;
}

static id WrapParamsWithTypeChar(void **args, const char *argumentType, int index) {
    void *arg = args[index];
    id value = [NSNull null];
    switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
        TT_WARP_JS_ARGS(_C_INT, int);
        TT_WARP_JS_ARGS(_C_SHT, short);
        TT_WARP_JS_ARGS(_C_USHT, unsigned short);
        TT_WARP_JS_ARGS(_C_UINT, unsigned int);
        TT_WARP_JS_ARGS(_C_LNG, long);
        TT_WARP_JS_ARGS(_C_ULNG, unsigned long);
        TT_WARP_JS_ARGS(_C_LNG_LNG, long long);
        TT_WARP_JS_ARGS(_C_ULNG_LNG, unsigned long long);
        TT_WARP_JS_ARGS(_C_FLT, float);
        TT_WARP_JS_ARGS(_C_DBL, double);
        TT_WARP_JS_ARGS(_C_BOOL, BOOL);
        case _C_ID: {
            if ('?' == argumentType[1]) {
                __unsafe_unretained id tempArg;
                tempArg = (__bridge id)(*(void **)arg);
                TTDFKitBlockModel *block = [TTDFKitBlockModel new];
                block.__isa = tempArg;
                value = ToJsObject(block, @"block");
            } else {
                __unsafe_unretained id tempArg;
                tempArg = (__bridge id)(*(void **)arg);
                value = tempArg == nil ? [NSNull null] : ToJsObject(tempArg, nil);
            }
        } break;
        case _C_STRUCT_B: {
            NSString *returnStypeStr = [NSString stringWithUTF8String:argumentType];
            if ([returnStypeStr hasPrefix:@"{CGRect"]) {
                __unsafe_unretained id tempArg;
                tempArg = (__bridge id)(*(void **)arg);
                return ToJsObject(CGReactToJSObject([tempArg CGRectValue]), @"react");
            } else if ([returnStypeStr hasPrefix:@"{CGPoint"]) {
                __unsafe_unretained id tempArg;
                tempArg = (__bridge id)(*(void **)arg);
                return ToJsObject(CGPointToJSObject([tempArg CGPointValue]), @"CGPoint");
            } else if ([returnStypeStr hasPrefix:@"{CGSize"]) {
                __unsafe_unretained id tempArg;
                tempArg = (__bridge id)(*(void **)arg);
                return ToJsObject(CGSizeToJSObject([tempArg CGSizeValue]), @"size");
            } else if ([returnStypeStr hasPrefix:@"{UIEdgeInsets"]) {
                __unsafe_unretained id tempArg;
                tempArg = (__bridge id)(*(void **)arg);
                return ToJsObject(UIEdgeInsetsToJSObject([tempArg UIEdgeInsetsValue]), @"edge");
            } else {
                NSCAssert(NO, @"*******%@---当前结构体暂不支持", returnStypeStr);
            }
        } break;
    }

    return value;
}

#define TT_RETURN_PTR_WRAP(typeChar, type, func) \
    case typeChar: {                             \
        type *ptr = (type *)retPointer;          \
        *ptr = (type)[jsValue func];             \
    } break;
static void ConvertReturnValue(const char *argumentType, JSValue *jsValue, void *retPointer) {
    char flag = argumentType[0] == 'r' ? argumentType[1] : argumentType[0];
    switch (flag) {
        case _C_ID: {
            void **ptr = retPointer;
            id retObj = [jsValue toObject];

            *ptr = (__bridge void *)ToOcObject(retObj);
            if ([retObj isKindOfClass:[TTDFBlockHelper class]]) {
                *ptr = [((TTDFBlockHelper *)retObj) blockPtr];
            }
        } break;
        case _C_CLASS: {
            void **ptr = retPointer;
            id retObj = [jsValue toObject];
            *ptr = (__bridge void *)retObj;
            if ([retObj isKindOfClass:[TTDFBlockHelper class]]) {
                *ptr = [((TTDFBlockHelper *)retObj) blockPtr];
            }
        } break;
        case _C_STRUCT_B: {
            id retObj = [jsValue toObject];
            NSString *clsType = [retObj objectForKey:@"__className"];
            guard(clsType) else {
                NSCAssert(
                    NO, [NSString stringWithFormat:@"***************方法签名入参为结构体,当前JS返回params未能获取当前结构体类型,请检查************"]);
            }
            NSString *str = [retObj objectForKey:@"__isa"];
            if ([clsType isEqualToString:@"react"]) {
                CGRect ocBaseData = toOcCGReact(str);
                void **ptr = retPointer;
                *ptr = &ocBaseData;
            } else if ([clsType isEqualToString:@"point"]) {
                CGPoint ocBaseData = toOcCGPoint(str);
                void **ptr = retPointer;
                *ptr = &ocBaseData;
            } else if ([clsType isEqualToString:@"size"]) {
                CGSize ocBaseData = toOcCGSize(str);
                void **ptr = retPointer;
                *ptr = &ocBaseData;
            } else if ([clsType isEqualToString:@"edge"]) {
                UIEdgeInsets ocBaseData = toOcEdgeInsets(str);
                void **ptr = retPointer;
                *ptr = &ocBaseData;
            }
            break;
        } break;
            TT_RETURN_PTR_WRAP(_C_SHT, short, toInt32);
            TT_RETURN_PTR_WRAP(_C_USHT, unsigned short, toUInt32);
            TT_RETURN_PTR_WRAP(_C_INT, int, toInt32);
            TT_RETURN_PTR_WRAP(_C_UINT, unsigned int, toUInt32);
            TT_RETURN_PTR_WRAP(_C_LNG, long, toInt32);
            TT_RETURN_PTR_WRAP(_C_ULNG, unsigned long, toUInt32);
            TT_RETURN_PTR_WRAP(_C_LNG_LNG, long long, toInt32);
            TT_RETURN_PTR_WRAP(_C_ULNG_LNG, unsigned long long, toUInt32);
            TT_RETURN_PTR_WRAP(_C_FLT, float, toDouble);
            TT_RETURN_PTR_WRAP(_C_DBL, double, toDouble);
            TT_RETURN_PTR_WRAP(_C_BFLD, BOOL, toBool);
            TT_RETURN_PTR_WRAP(_C_BOOL, BOOL, toBool);

        default:
            break;
    }
    return;
}

static ffi_type *typeEncodingToFfiType(const char *typeEncoding) {
    NSString *typeString = [NSString stringWithUTF8String:typeEncoding];
    switch (typeEncoding[0]) {
        case 'v':
            return &ffi_type_void;
        case 'c':
            return &ffi_type_schar;
        case 'C':
            return &ffi_type_uchar;
        case 's':
            return &ffi_type_sshort;
        case 'S':
            return &ffi_type_ushort;
        case 'i':
            return &ffi_type_sint;
        case 'I':
            return &ffi_type_uint;
        case 'l':
            return &ffi_type_slong;
        case 'L':
            return &ffi_type_ulong;
        case 'q':
            return &ffi_type_sint64;
        case 'Q':
            return &ffi_type_uint64;
        case 'f':
            return &ffi_type_float;
        case 'd':
            return &ffi_type_double;
        case 'D':
            return &ffi_type_longdouble;
        case 'B':
            return &ffi_type_uint8;
        case '^':
            return &ffi_type_pointer;
        case '@':
            return &ffi_type_pointer;
        case '#':
            return &ffi_type_pointer;
        case ':':
            return &ffi_type_pointer;
        case '{': {
            ffi_type *type = malloc(sizeof(ffi_type));
            type->size = 0;
            type->alignment = 0;
            type->elements = NULL;
            type->type = FFI_TYPE_STRUCT;

            NSString *types = [typeString substringToIndex:typeString.length - 1];
            NSUInteger location = [types rangeOfString:@"="].location + 1;
            types = [types substringFromIndex:location];
            char *typesCode = (char *)[types UTF8String];

            size_t index = 0;
            size_t subCount = 0;
            NSString *subTypeEncoding;

            while (typesCode[index]) {
                if (typesCode[index] == '{') {
                    size_t stackSize = 1;
                    size_t end = index + 1;
                    for (char c = typesCode[end]; c; end++, c = typesCode[end]) {
                        if (c == '{') {
                            stackSize++;
                        } else if (c == '}') {
                            stackSize--;
                            if (stackSize == 0) {
                                break;
                            }
                        }
                    }
                    subTypeEncoding = [types substringWithRange:NSMakeRange(index, end - index + 1)];
                    index = end + 1;
                } else {
                    subTypeEncoding = [types substringWithRange:NSMakeRange(index, 1)];
                    index++;
                }

                ffi_type *subFfiType = (ffi_type *)typeEncodingToFfiType((char *)subTypeEncoding.UTF8String);
                type->size += subFfiType->size;
                type->elements = realloc((void *)(type->elements), sizeof(ffi_type *) * (subCount + 1));
                type->elements[subCount] = subFfiType;
                subCount++;
            }

            type->elements = realloc((void *)(type->elements), sizeof(ffi_type *) * (subCount + 1));
            type->elements[subCount] = NULL;
            return type;
        }
        default:
            return NULL;
    }
}

static void HookClassMethod(NSString *className, NSString *superClassName, NSString *method, BOOL isInstanceMethod, NSArray *propertys) {
    HookClassMethodWithSignature(className, superClassName, method, isInstanceMethod, propertys, nil);
}

static void HookClassMethodWithSignature(
    NSString *className, NSString *superClassName, NSString *method, BOOL isInstanceMethod, NSArray *propertys, NSString *signature) {
    if (__checkRegistedMethod(method, className, !isInstanceMethod)) {
        return;
    }
    static NSSet *disallowedSelectorList;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        disallowedSelectorList = [NSSet setWithObjects:@"retain", @"release", @"autorelease", nil];
    });

    if ([disallowedSelectorList containsObject:method]) {
        NSString *errorDescription = [NSString stringWithFormat:@"Selector %@ is blacklisted.", method];
        NSCAssert(NO, errorDescription);
    }
    TTLog_Info(@"%@.%@%@ replace success!!!", className, isInstanceMethod ? @"-" : @"+", method);

    Class aClass = NSClassFromString(className);
    SEL original_SEL = NSSelectorFromString(method);
    Method originalMethodInfo = class_getInstanceMethod(aClass, original_SEL);

    //如果是静态方法,要取 MetaClass
    guard(isInstanceMethod) else {
        originalMethodInfo = class_getClassMethod(aClass, original_SEL);
        aClass = object_getClass(aClass);
    }

    replaceMethod(aClass, original_SEL, isInstanceMethod, signature);

    //将已经替换的class做记录
    __registerMethod(method, className, !isInstanceMethod);
}

+ (id)defineClass:(NSString *)interface {
    NSArray *protocols;
    NSArray *classAndSuper;
    if ([interface containsString:@"<"]) {
        NSArray *protocolAndClass = [interface componentsSeparatedByString:@"<"];
        NSString *protocolString = [protocolAndClass lastObject];
        protocolString = [protocolString stringByReplacingOccurrencesOfString:@">" withString:@""];
        protocols = [protocolString componentsSeparatedByString:@","];
        classAndSuper = [[protocolAndClass firstObject] componentsSeparatedByString:@":"];
    } else {
        classAndSuper = [interface componentsSeparatedByString:@":"];
    }

    for (NSString *aProtocol in protocols) {
        Class cls = NSClassFromString([classAndSuper firstObject]);
        Protocol *pro = NSProtocolFromString(aProtocol);
        if (!class_conformsToProtocol(NSClassFromString([classAndSuper firstObject]), NSProtocolFromString(aProtocol))) {
            if (class_addProtocol(cls, pro)) {
                [TTDFLogModule log_info:@"添加协议成功"];
            } else {
                [TTDFLogModule log_info:@"添加协议失败"];
            }
        } else {
        }
    }

    return @{ @"self": [classAndSuper firstObject], @"super": [classAndSuper lastObject] };
}

+ (id)dynamicMethodInvocation:(id)classOrInstance
                    className:(NSString *)className
                      isSuper:(BOOL)isSuper
                      isBlock:(BOOL)isBlock
                       method:(NSString *)method
                    arguments:(NSArray *)arguments {
    return DynamicMethodInvocation(classOrInstance, className, isSuper, isBlock, method, arguments);
}

+ (NSInvocation *)dynamicBlock:(TTDFKitBlockModel *)blockModel arguments:(NSArray *)arguments custom_signature:(NSString *)custom_signature {
    return DynamicBlock(blockModel, arguments, custom_signature);
}

+ (void)hookClassMethod:(NSString *)className
         superClassName:(NSString *)superClassName
                 method:(NSString *)method
       isInstanceMethod:(BOOL)isInstanceMethod
              propertys:(NSArray *)propertys {
    return HookClassMethod(className, superClassName, method, isInstanceMethod, propertys);
}

+ (void)hookClassMethodWithSignature:(NSString *)className
                      superClassName:(NSString *)superClassName
                              method:(NSString *)method
                    isInstanceMethod:(BOOL)isInstanceMethod
                           propertys:(NSArray *)propertys
                           signature:(NSString *)signature {
    return HookClassMethodWithSignature(className, superClassName, method, isInstanceMethod, propertys, signature);
}

+ (void)addPropertys:(NSString *)className superClassName:(NSString *)superClassName propertys:(NSArray *)propertys {
    AddPropertys(className, superClassName, propertys);
}

+ (void *)typeEncodingToFfiType:(const char *)typeEncoding {
    return typeEncodingToFfiType(typeEncoding);
}

+ (id)genJsBlockSignature:(NSString *)signature block:(JSValue *)block {
    TTDFBlockHelper *blockHelper = [[TTDFBlockHelper alloc] initWithTypeEncoding:CreateSignatureWithString(signature, YES) callbackFunction:block];
    return blockHelper;
}

+ (id)getParamFromArgs:(void **)args argumentType:(const char *)argumentType index:(int)index {
    return WrapParamsWithTypeChar(args, argumentType, index);
}

+ (void)convertReturnValue:(const char *)methodSignature jsValue:(JSValue *)jsValue retPointer:(void *)retPointer {
    return ConvertReturnValue(methodSignature, jsValue, retPointer);
}

+ (NSMutableDictionary *)getReplaceMethodMap {
    return __replaceMethodMap;
}
@end
