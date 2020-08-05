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
@implementation TTDFUtils

+(NSString *)TTHookMethodFormatterToOcFunc:(NSString *)method{
    return MethodFormatterToOcFunc(method);
}
+(NSString *)TTHookMethodFormatterToJSFunc:(NSString *)method{
    return MethodFormatterToJSFunc(method);
}
@end

