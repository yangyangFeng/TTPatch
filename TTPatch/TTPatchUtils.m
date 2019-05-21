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

#define TT_ARG_Injection(charAbbreviation,type,func)\
case charAbbreviation:\
{\
NSNumber *jsObj = arguments[i];  \
type argument=[jsObj func]; \
[invocation setArgument:&argument atIndex:(2 + i)]; \
}   \
break;
static void setInvocationArgumentsMethod(NSInvocation *invocation,NSArray *arguments,Method method){
    //@:@ count=3 参数个数1
    int indexOffset = 2;
    int systemMethodArgCount = method_getNumberOfArguments(method);
    if (systemMethodArgCount>indexOffset) {
        systemMethodArgCount-=indexOffset;
    }else{
        
        systemMethodArgCount=0;
        return;
    }
    guard(systemMethodArgCount == arguments.count)else{
//        NSAssert(NO, [NSString stringWithFormat:@"参数个数不匹配,请检查!"]);
    }
    
    for (int i = 0; i < systemMethodArgCount; i++) {
        const char *argumentType = method_copyArgumentType(method, i+indexOffset);
        switch(argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
            case _C_ID:
            {
                __unsafe_unretained id argument = ([arguments objectAtIndex:i]);
                guard([argument isKindOfClass:NSDictionary.class]) else{
                    [invocation setArgument:&argument atIndex:(indexOffset + i)];
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
            case 'c':
            {
                JSValue *jsObj = arguments[i];
                char argument[1000];
                strcpy(argument,(char *)[[jsObj toString] UTF8String]);
                [invocation setArgument:&argument atIndex:(2 + i)];
            }
                break;
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

static id DynamicMethodInvocation(id classOrInstance, NSString *method, NSArray *arguments){
    
    __autoreleasing id instance = nil;
    BOOL hasArgument = NO;
    TTCheckArguments(hasArgument,arguments);
    if([classOrInstance isKindOfClass:NSString.class]){
        classOrInstance = NSClassFromString(classOrInstance);
    }
    SEL sel_method = NSSelectorFromString(method);
    NSMethodSignature *signature = [classOrInstance methodSignatureForSelector:sel_method];
    Method classMethod = class_getClassMethod([classOrInstance class], sel_method);
    Method instanceMethod = class_getInstanceMethod([classOrInstance class], sel_method);
    Method methodInfo = classMethod?classMethod:instanceMethod;
    guard(signature) else{
        @throw [NSException exceptionWithName:TTPatchInvocationException reason:[NSString stringWithFormat:@"没有找到 '%@' 中的 %@ 方法", classOrInstance,  method] userInfo:nil];
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    if ([classOrInstance respondsToSelector:sel_method]) {
        [invocation setTarget:classOrInstance];
        NSLog(@"%@参数个数:%ld----------%@>>>>> %@",method,signature.numberOfArguments,[NSString stringWithUTF8String:signature.methodReturnType],signature);
        [invocation setSelector:sel_method];
        if (hasArgument) {
//            setInvocationArguments(invocation, arguments);
            setInvocationArgumentsMethod(invocation, arguments, methodInfo);
        }
        [invocation invoke];
        guard(strcmp(signature.methodReturnType,"v") == 0)else{
            [invocation getReturnValue:&instance];
        }
    }else{
        
    }

    return instance;
    
}







const struct TTPatchUtils TTPatchUtils = {
    .TTPatchDynamicMethodInvocation               = DynamicMethodInvocation,
    .TTPatchGetMethodTypes                        = GetMethodTypes,
    .TTPatchMethodFormatterToOcFunc               = MethodFormatterToOcFunc,
    .TTPatchMethodFormatterToJSFunc               = MethodFormatterToJSFunc,
    .TTPatchGetInstanceOrClassMethodInfo          = GetInstanceOrClassMethodInfo
};


