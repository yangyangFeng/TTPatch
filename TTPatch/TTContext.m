//
//  TTContext.m
//  TTDFKit
//
//  Created by ty on 2019/5/17.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTContext.h"

#import "TTDFUtils.h"
#import "TTDFEngine.h"

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    log_level_debug=1,
    log_level_info,
    log_level_error,
} log_level;

@interface TTContext ()
@end

@implementation TTContext

#pragma makr- Native API
- (void)configJSBrigeActions{
    
    self[@"MessageQueue_oc_define"] = ^(NSString * interface){
        return [TTDFEngine defineClass:interface];
    };
    
    self[@"MessageQueue_oc_sendMsg"] = ^(id obj,BOOL isSuper,BOOL isBlock,NSString* method,id arguments){
        return [TTDFEngine dynamicMethodInvocation:obj isSuper:isSuper isBlock:isBlock method:[TTDFUtils TTHookMethodFormatterToOcFunc:method] arguments:arguments];
    };
    
    self[@"MessageQueue_oc_block"] = ^(id obj, id arguments, NSString *custom_signature){
        return [TTDFEngine dynamicBlock:obj arguments:arguments custom_signature:custom_signature];
    };
    
    self[@"MessageQueue_oc_replaceMethod"] = ^(NSString *className,NSString *superClassName,NSString *method,BOOL isInstanceMethod,NSArray*propertys){
        [TTDFEngine hookClassMethod:className superClassName:superClassName method:[TTDFUtils TTHookMethodFormatterToOcFunc:method] isInstanceMethod:isInstanceMethod propertys:propertys];
    };
    self[@"MessageQueue_oc_replaceDynamicMethod"] = ^(NSString *className,NSString *superClassName,NSString *method,BOOL isInstanceMethod,NSArray*propertys, NSString *signature){
        [TTDFEngine hookClassMethodWithSignature:className superClassName:superClassName method:[TTDFUtils TTHookMethodFormatterToOcFunc:method] isInstanceMethod:isInstanceMethod propertys:propertys signature:signature];
    };
    self[@"MessageQueue_oc_addPropertys"] = ^(NSString *className,NSString *superClassName,NSArray*propertys){
        [TTDFEngine addPropertys:className superClassName:superClassName propertys:propertys];
    };
    self[@"MessageQueue_oc_genBlock"] = ^(NSString *signature, JSValue *func){
        return [TTDFEngine GenJsBlockSignature:signature block:func];
    };

    self[@"APP_IsDebug"] = ^(NSString *className,NSString *superClassName,NSArray*propertys){
#if DEBUG
        return YES;
#else
        return NO;
#endif
    };
    
    self[@"Utils_Log"] = ^(log_level level,id msg){
        guard([TTDFKit shareInstance].config.isOpenLog) else return;
        switch (level) {
            case log_level_debug:
                TTLog(@"%@",ToOcObject(msg));
                break;
            case log_level_info:
                TTLog_Info(@"%@",ToOcObject(msg));
                break;
            case log_level_error:
                TTLog_Error(@"%@",ToOcObject(msg));
                break;
            default:
                TTLog(@"%@",ToOcObject(msg));
                break;
        }
    };
}

- (JSValue *)messageQueue{
    return self[@"js_msgSend"];
}
@end

