//
//  TTPatchUtils.h
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

extern const struct TTPatchUtils {
    id          (*TTPatchDynamicMethodInvocation)           (id classOrInstance, NSString *method, NSArray *arguments);
    char *      (*TTPatchGetMethodTypes)                    (NSString *method,NSArray *arguments);
    NSString *  (*TTPatchMethodFormatterToOcFunc)           (NSString *method);
    NSString *  (*TTPatchMethodFormatterToJSFunc)           (NSString *method);
    Method      (*TTPatchGetInstanceOrClassMethodInfo)      (Class aClass,SEL aSel);
    
} TTPatchUtils;





