//
//  TTPatchUtils.h
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "TTPatchModels.h"



static id ToJsObject(id returnValue,NSString *clsName){
    if (returnValue) {
        return [TTJSObject createJSObject:returnValue className:clsName isInstance:YES];;
    }
    return [TTJSObject createJSObject:nil className:clsName isInstance:NO];;
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


static NSDictionary* UIEdgeInsetsToJSObject(UIEdgeInsets edge){
    return @{@"top":@(edge.top),
             @"left":@(edge.left),
             @"bottom":@(edge.bottom),
             @"right":@(edge.right)
             };
}

@class JSValue;
extern const struct TTPatchUtils {
    id          (*TTPatchDynamicMethodInvocation)           (id classOrInstance,BOOL isSuper,BOOL isBlock,NSString *method, NSArray *arguments);
    NSInvocation*          (*TTPatchDynamicBlock)                      (id block,NSArray *arguments);
    id          (*TTDynamicBlockWithInvocation)             (id block,NSInvocation *invocation);
    char *      (*TTPatchGetMethodTypes)                    (NSString *method,NSArray *arguments);
    NSString *  (*TTPatchMethodFormatterToOcFunc)           (NSString *method);
//    id          (*TTPatchToJsObject)                        (id returnValue);
    NSString *  (*TTPatchMethodFormatterToJSFunc)           (NSString *method);
    Method      (*TTPatchGetInstanceOrClassMethodInfo)      (Class aClass,SEL aSel);
    void        (*TTPATCH_hookClassMethod)                  (NSString *className,NSString *superClassName,NSString *method,BOOL isInstanceMethod,NSArray *propertys);
    void        (*TTPATCH_addPropertys)                     (NSString *className,NSString *superClassName,NSArray *propertys);
    
} TTPatchUtils;
