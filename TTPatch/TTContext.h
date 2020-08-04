//
//  TTContext.h
//  TTPatch
//
//  Created by ty on 2019/5/17.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

extern NSString * _Nonnull const TTPatchChangeMethodPrefix;

NS_ASSUME_NONNULL_BEGIN

/// JS上下文与Native交互 核心管理类
@interface TTContext : JSContext

/// 配置JS-OC通信
- (void)configJSBrigeActions;

/// 获取当前正在调用的block
- (JSValue *)getBlockFunc;

- (id)execFuncParamsBlockWithBlockKey:(NSString *)key
                            arguments:(NSArray *)arguments;

@end

NS_ASSUME_NONNULL_END
