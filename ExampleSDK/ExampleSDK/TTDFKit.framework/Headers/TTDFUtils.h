//
//  TTDFUtils.h
//  TTHook
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "TTDFModels.h"



extern id ToJsObject(id returnValue,NSString *clsName);
extern id ToOcObject(id jsObj);;

extern NSDictionary* CGPointToJSObject(CGPoint point);
extern NSDictionary* CGSizeToJSObject(CGSize size);
extern NSDictionary* CGReactToJSObject(CGRect react);
extern NSDictionary* UIEdgeInsetsToJSObject(UIEdgeInsets edge);

extern CGRect toOcCGReact(NSString *jsObjValue);
extern CGPoint toOcCGPoint(NSString *jsObjValue);
extern CGSize toOcCGSize(NSString *jsObjValue);
extern UIEdgeInsets toOcEdgeInsets(NSString *jsObjValue);

extern NSMethodSignature *block_methodSignatureForSelector(id self, SEL _cmd, SEL aSelector);
extern NSString * MethodFormatterToOcFunc(NSString *method);
extern NSString * MethodFormatterToJSFunc(NSString *method);

@interface TTDFUtils : NSObject
@end
