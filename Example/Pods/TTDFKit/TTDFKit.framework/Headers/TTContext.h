//
//  TTContext.h
//  TTDFKit
//
//  Created by ty on 2019/5/17.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>



NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    log_level_debug=1,
    log_level_info,
    log_level_error,
} log_level;

@protocol TTLogProtocol <NSObject>
- (void)log:(NSString *)log level:(log_level)level;
@end

@interface TTContext : JSContext
/// 配置JS-OC通信
- (void)configJSBrigeActions;

- (JSValue *)messageQueue;

@property(nonatomic,weak) id<TTLogProtocol> logDelegate;
@end

NS_ASSUME_NONNULL_END
