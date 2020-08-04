//
//  TTHookUtils.h
//  TTHook
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

static id ToOcObject(id jsObj){
    if (jsObj) {
        if ([jsObj isKindOfClass:[NSString class]] ||
            [jsObj isKindOfClass:[NSNumber class]]) {
            return jsObj;
        }
        else if([jsObj isKindOfClass:[NSDictionary class]]){
            return jsObj[@"__isa"];
        }
    }
    return jsObj;
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

@interface TTHookUtils : NSObject
+(NSString *)TTHookMethodFormatterToOcFunc:(NSString *)method;
+(NSString *)TTHookMethodFormatterToJSFunc:(NSString *)method;
@end
