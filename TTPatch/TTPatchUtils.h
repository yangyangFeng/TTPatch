//
//  TTPatchUtils.h
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@class JSValue;
extern const struct TTPatchUtils {
    id          (*TTPatchDynamicMethodInvocation)           (id classOrInstance,BOOL isSuper,BOOL isInstance,NSString *method, NSArray *arguments);
    char *      (*TTPatchGetMethodTypes)                    (NSString *method,NSArray *arguments);
    NSString *  (*TTPatchMethodFormatterToOcFunc)           (NSString *method);
//    id          (*TTPatchToJsObject)                        (id returnValue);
    NSString *  (*TTPatchMethodFormatterToJSFunc)           (NSString *method);
    Method      (*TTPatchGetInstanceOrClassMethodInfo)      (Class aClass,SEL aSel);
    
} TTPatchUtils;





