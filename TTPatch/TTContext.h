//
//  TTContext.h
//  TTPatch
//
//  Created by ty on 2019/5/17.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>



NS_ASSUME_NONNULL_BEGIN

@interface TTContext : JSContext
/// 配置JS-OC通信
- (void)configJSBrigeActions;

- (JSValue *)messageQueue;
@end

NS_ASSUME_NONNULL_END
