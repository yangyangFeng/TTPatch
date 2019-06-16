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
        NSCAssert(NO, [NSString stringWithFormat:@"参数个数不匹配,请检查!"]);
    }
    
    for (int i = 0; i < systemMethodArgCount; i++) {
        const char *argumentType = method_copyArgumentType(method, i+indexOffset);
        char flag = argumentType[0] == 'r' ? argumentType[1] : argumentType[0];
        switch(flag) {
            case _C_ID:
            {
                __unsafe_unretained id argument = ([arguments objectAtIndex:i]);
                [invocation setArgument:&argument atIndex:(2 + i)];
                
            }break;
            case _C_STRUCT_B:
            {
                __unsafe_unretained id argument = ([arguments objectAtIndex:i]);
             
                NSString * clsType = [argument objectForKey:@"__className"];
                guard(clsType)else{
                   NSCAssert(NO, [NSString stringWithFormat:@"***************方法签名入参为结构体,当前JS返回params未能获取当前结构体类型,请检查************"]);
                }
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
                
            }break;
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

static NSDictionary* CGPointToJSObject(CGPoint point){
    return @{@"x":@(point.x),
             @"y":@(point.y)
             };
}

static NSDictionary* CGSizeToJSObject(CGSize size){
    return @{@"width":@(size.width),
             @"height":@(size.height)
             };
}

static NSDictionary* CGReactToJSObject(CGRect react){
    NSMutableDictionary *reactDic = [NSMutableDictionary dictionaryWithDictionary:CGPointToJSObject(react.origin)];
    [reactDic setDictionary:CGSizeToJSObject(react.size)];
    return reactDic;
}


static NSString* UIEdgeInsetsToJSObject(UIEdgeInsets edge){
    return @{@"top":@(edge.top),
             @"left":@(edge.left),
             @"bottom":@(edge.bottom),
             @"right":@(edge.right)
             };
}
@interface TTJSObject : NSObject
+ (NSDictionary *)createJSObject:(id)__isa
                       className:(NSString *)__className
                      isInstance:(BOOL)__isInstance;
@end
@implementation TTJSObject

+ (NSDictionary *)createJSObject:(id)__isa
                       className:(NSString *)__className
                      isInstance:(BOOL)__isInstance{
    return @{@"__isa":__isa?:[NSNull null],
             @"__className":__className,
             @"__isInstance":@(__isInstance)
             };
}

@end

static id ToJsObject(id returnValue,NSString *clsName){
    if (returnValue) {
        return [TTJSObject createJSObject:returnValue className:clsName isInstance:YES];;
    }
    return [TTJSObject createJSObject:nil className:clsName isInstance:NO];;
}

#define TT_RETURN_WRAP(typeChar,type)\
case typeChar:{   \
type instance; \
[invocation getReturnValue:&instance];  \
return @(instance); \
}break;

static id DynamicMethodInvocation(id classOrInstance, NSString *method, NSArray *arguments){
    
    
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
#if DEBUG
            NSLog(@"动态调用------------->%@ \n----->参数个数:%ld \n----->%s \n----->%@",method,signature.numberOfArguments,method_getTypeEncoding(methodInfo),arguments);
#endif
        [invocation setTarget:classOrInstance];
        [invocation setSelector:sel_method];
        if (hasArgument) {
            setInvocationArgumentsMethod(invocation, arguments, methodInfo);
        }
        
        [invocation invoke];
        guard(strcmp(signature.methodReturnType,"v") == 0)else{
            
            const char *argumentType = signature.methodReturnType;
            char flag = argumentType[0] == 'r' ? argumentType[1] : argumentType[0];

            switch (flag) {
                case _C_ID:{
                    __unsafe_unretained id instance = nil;
                    [invocation getReturnValue:&instance];
                    return instance?ToJsObject(instance,NSStringFromClass([instance class])):[NSNull null];
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
                        return NSStringFromUIEdgeInsets(instance);
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
            
           
//            return ToJsObject(instance,signature.methodReturnType);
        }
    }else{
        
    }

    return nil;
    
}





const struct TTPatchUtils TTPatchUtils = {
    .TTPatchDynamicMethodInvocation               = DynamicMethodInvocation,
    .TTPatchGetMethodTypes                        = GetMethodTypes,
    .TTPatchMethodFormatterToOcFunc               = MethodFormatterToOcFunc,
    .TTPatchMethodFormatterToJSFunc               = MethodFormatterToJSFunc,
    .TTPatchGetInstanceOrClassMethodInfo          = GetInstanceOrClassMethodInfo,
//    .TTPatchToJsObject                            = ToJsObject
};


