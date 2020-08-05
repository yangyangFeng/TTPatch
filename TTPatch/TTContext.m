//
//  TTContext.m
//  TTPatch
//
//  Created by ty on 2019/5/17.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTContext.h"
#import "TTHookUtils.h"
#import "TTEngine.h"
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
    self[@"Utils_Log"] = ^(log_level level,id msg){
        guard([TTPatch shareInstance].config.isOpenLog) else return;
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
    
    self[@"MessageQueue_oc_define"] = ^(NSString * interface){
        NSArray * protocols;
        NSArray * classAndSuper;
        if ([interface containsString:@"<"]) {
            NSArray *protocolAndClass = [interface componentsSeparatedByString:@"<"];
            NSString *protocolString = [protocolAndClass lastObject];
            protocolString = [protocolString stringByReplacingOccurrencesOfString:@">" withString:@""];
            protocols = [protocolString componentsSeparatedByString:@","];
            classAndSuper = [[protocolAndClass firstObject] componentsSeparatedByString:@":"];
        }else{
            classAndSuper = [interface componentsSeparatedByString:@":"];
        }
         
        for (NSString *aProtocol in protocols) {
            Class cls =NSClassFromString([classAndSuper firstObject]);
            Protocol *pro = NSProtocolFromString(aProtocol);
            if (!class_conformsToProtocol(NSClassFromString([classAndSuper firstObject]), NSProtocolFromString(aProtocol))) {
                if (class_addProtocol(cls, pro)) {
                    NSLog(@"添加协议成功");
                }else{
                    NSLog(@"添加协议失败");
                }
            }else{
                
            }
        }
        
        return @{@"self":[classAndSuper firstObject],
                 @"super":[classAndSuper lastObject]
                 };
    };
    
    self[@"MessageQueue_oc_sendMsg"] = ^(id obj,BOOL isSuper,BOOL isBlock,NSString* method,id arguments){
        return [TTEngine dynamicMethodInvocation:obj isSuper:isSuper isBlock:isBlock method:[TTHookUtils TTHookMethodFormatterToOcFunc:method] arguments:arguments];
    };
    
    self[@"MessageQueue_oc_block"] = ^(id obj, id arguments, NSString *custom_signature){
        return [TTEngine dynamicBlock:obj arguments:arguments custom_signature:custom_signature];
    };
    
    self[@"MessageQueue_oc_replaceMethod"] = ^(NSString *className,NSString *superClassName,NSString *method,BOOL isInstanceMethod,NSArray*propertys){
        [TTEngine hookClassMethod:className superClassName:superClassName method:[TTHookUtils TTHookMethodFormatterToOcFunc:method] isInstanceMethod:isInstanceMethod propertys:propertys];
    };
    self[@"MessageQueue_oc_replaceDynamicMethod"] = ^(NSString *className,NSString *superClassName,NSString *method,BOOL isInstanceMethod,NSArray*propertys, NSString *signature){
        [TTEngine hookClassMethodWithSignature:className superClassName:superClassName method:[TTHookUtils TTHookMethodFormatterToOcFunc:method] isInstanceMethod:isInstanceMethod propertys:propertys signature:signature];
    };
    self[@"MessageQueue_oc_addPropertys"] = ^(NSString *className,NSString *superClassName,NSArray*propertys){
        [TTEngine addPropertys:className superClassName:superClassName propertys:propertys];
    };
    self[@"MessageQueue_oc_setBlock"] = ^(id jsFunc){
        TTLog(@"jsfunc-----%p",jsFunc);
    };
    self[@"APP_IsDebug"] = ^(NSString *className,NSString *superClassName,NSArray*propertys){
#if DEBUG
        return YES;
#else
        return NO;
#endif
        
    };
    
    /**
     * 是否将 String, Number, Dic,Arr 转换成JS 类型,转换后不可再调用Oc方法操作对象.
     * 默认开启
     */
    self[@"ProjectConfig_IS_USE_NATIVE_DATA"] = ^(){
        return [TTPatch shareInstance].config.isUserNativeData;
    };
    
}

- (JSValue *)getBlockFunc{
    return self[@"jsBlock"];
}

- (id)execFuncParamsBlockWithBlockKey:(NSString *)key
                            arguments:(NSArray *)arguments{
    JSValue *func = [self getBlockFunc];
    NSMutableArray *tempArguments = [NSMutableArray arrayWithObject:key];
    [tempArguments addObjectsFromArray:arguments];
    
    return [func callWithArguments:tempArguments];
}


@end

