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

@interface TTContext ()
@end

@implementation TTContext

#pragma makr- Native API
- (void)configJSBrigeActions{
    self[kMessageQueue_oc_define] = ^(NSString * interface){
        return [TTDFEngine defineClass:interface];
    };
    
    self[kMessageQueue_oc_sendMsg] = ^(id obj,BOOL isSuper,BOOL isBlock,NSString* method,id arguments){
        return [TTDFEngine dynamicMethodInvocation:obj isSuper:isSuper isBlock:isBlock method:MethodFormatterToOcFunc(method) arguments:arguments];
    };
    
    self[kMessageQueue_oc_block] = ^(id obj, id arguments, NSString *custom_signature){
        return [TTDFEngine dynamicBlock:obj arguments:arguments custom_signature:custom_signature];
    };
    self[kMessageQueue_oc_replaceMethod] = ^(NSString *className,NSString *superClassName,NSString *method,BOOL isInstanceMethod,NSArray*propertys){
        [TTDFEngine hookClassMethod:className superClassName:superClassName method:MethodFormatterToOcFunc(method) isInstanceMethod:isInstanceMethod propertys:propertys];
    };
    self[kMessageQueue_oc_replaceDynamicMethod] = ^(NSString *className,NSString *superClassName,NSString *method,BOOL isInstanceMethod,NSArray*propertys, NSString *signature){
        [TTDFEngine hookClassMethodWithSignature:className superClassName:superClassName method:MethodFormatterToOcFunc(method) isInstanceMethod:isInstanceMethod propertys:propertys signature:signature];
    };
    self[kMessageQueue_oc_addPropertys] = ^(NSString *className,NSString *superClassName,NSArray*propertys){
        [TTDFEngine addPropertys:className superClassName:superClassName propertys:propertys];
    };
    self[kMessageQueue_oc_genBlock] = ^(NSString *signature, JSValue *func){
        return [TTDFEngine GenJsBlockSignature:signature block:func];
    };
    
    self[kAPP_IsDebug] = ^(NSString *className,NSString *superClassName,NSArray*propertys){
#if DEBUG
        return YES;
#else
        return NO;
#endif
    };
    
    __weak typeof(self) weakSelf = self;
    self[kUtils_Log] = ^(log_level level,id msg){
        guard([TTDFEntry shareInstance].config.isOpenLog) else return;
        if (weakSelf.logDelegate && [weakSelf.logDelegate respondsToSelector:@selector(log:level:)]) {
            [weakSelf.logDelegate log:ToOcObject(msg) level:level];
        }
    };
}

- (JSValue *)messageQueue{
    return self[@"js_msgSend"];
}
@end

