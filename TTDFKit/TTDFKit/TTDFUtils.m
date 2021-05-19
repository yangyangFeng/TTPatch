//
//  TTDFUtils.m
//  TTHook
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTDFUtils.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/message.h>

NSString * MethodFormatterToOcFunc(NSString *method){
    if ([method rangeOfString:@"_"].length > 0) {
        method = [method stringByReplacingOccurrencesOfString:@"__" withString:@"$$"];
        method = [method stringByReplacingOccurrencesOfString:@"_" withString:@":"];
        method = [method stringByReplacingOccurrencesOfString:@"$$" withString:@"_"];
    }
    return method;
}

NSString * MethodFormatterToJSFunc(NSString *method){
    if ([method rangeOfString:@"_"].length > 0) {
        method = [method stringByReplacingOccurrencesOfString:@"_" withString:@"__"];
    }
    if ([method rangeOfString:@":"].length > 0) {
        method = [method stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    }
    return method;
}

Method GetInstanceOrClassMethodInfo(Class aClass,SEL aSel){
    Method instanceMethodInfo = class_getInstanceMethod(aClass, aSel);
    Method classMethodInfo    = class_getClassMethod(aClass, aSel);
    return instanceMethodInfo?instanceMethodInfo:classMethodInfo;
}

id ToJsObject(id returnValue,NSString *clsName){
    if (returnValue) {
        return [TTJSObject createJSObject:returnValue className:clsName isInstance:YES];;
    }
    return [TTJSObject createJSObject:nil className:clsName isInstance:NO];;
}

id ToOcObject(id jsObj){
    if (jsObj) {
        if([jsObj isKindOfClass:[NSNull class]]){
            return nil;
        }
        else if ([jsObj isKindOfClass:[NSString class]] ||
            [jsObj isKindOfClass:[NSNumber class]]) {
            return jsObj;
        }
        else if([jsObj isKindOfClass:[NSDictionary class]]){
            jsObj = jsObj[@"__isa"]?jsObj[@"__isa"]:jsObj;
            if ([jsObj isKindOfClass:NSDictionary.class]) {
                NSMutableDictionary *temp = (NSMutableDictionary *)[jsObj mutableCopy];
                [temp removeObjectForKey:@"_c"];
                jsObj = temp;
            }
            return jsObj;
        }
    }
    return jsObj;
}

NSDictionary* CGPointToJSObject(CGPoint point){
    return @{@"x":@(point.x),
             @"y":@(point.y)
    };
}

NSDictionary* CGSizeToJSObject(CGSize size){
    return @{@"width":@(size.width),
             @"height":@(size.height)
    };
}

NSDictionary* CGReactToJSObject(CGRect react){
    NSMutableDictionary *reactDic = [NSMutableDictionary dictionaryWithDictionary:CGPointToJSObject(react.origin)];
    [reactDic setDictionary:CGSizeToJSObject(react.size)];
    return reactDic;
}

NSDictionary* UIEdgeInsetsToJSObject(UIEdgeInsets edge){
    return @{@"top":@(edge.top),
             @"left":@(edge.left),
             @"bottom":@(edge.bottom),
             @"right":@(edge.right)
    };
}

CGRect toOcCGReact(NSString *jsObjValue){
    
    if (jsObjValue) {
        return CGRectFromString(jsObjValue);
    }
    return CGRectZero;
}

CGPoint toOcCGPoint(NSString *jsObjValue){
    if (jsObjValue){
        return CGPointFromString(jsObjValue);
    }
    return CGPointZero;
}

CGSize toOcCGSize(NSString *jsObjValue){
    if (jsObjValue) {
        return CGSizeFromString(jsObjValue);
    }
    return CGSizeZero;
}

UIEdgeInsets toOcEdgeInsets(NSString *jsObjValue){
    if (jsObjValue) {
        return UIEdgeInsetsFromString(jsObjValue);
    }
    return UIEdgeInsetsZero;
}

NSMethodSignature *block_methodSignatureForSelector(id self, SEL _cmd, SEL aSelector) {
    
    uint8_t *p = (uint8_t *)((__bridge void *)self);
    p += sizeof(void *) * 2 + sizeof(int32_t) *2 + sizeof(uintptr_t) * 2;
    const char **signature = (const char **)p;
    
    return [NSMethodSignature signatureWithObjCTypes:*signature];
}

@implementation TTDFUtils

@end

