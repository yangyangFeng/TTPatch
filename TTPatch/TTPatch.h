//
//  TTPatch.h
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>



@class TTContext;
/**
 *TTPatch
 */
@interface TTPatch : NSObject

/// SDK 初始化, 建议程序启动时优先初始化,以保证能修复更多场景
+ (void )initSDK;

/// 获取当前JS 上下文
+ (TTPatch *)shareInstance;


/// 执行 patch
/// @param script js
- (void)evaluateScript:(NSString *)script;

/// 执行 patch
/// @param script js
/// @param sourceURL ,用于调式时展示的 .js 文件名
- (void)evaluateScript:(NSString *)script withSourceURL:(NSURL *)sourceURL;


/// 清理全部交换过的方法
- (void)clearContext;
- (NSString *)formatterJS:(NSString *)script;
@property(nonatomic,strong,readonly)TTContext *context;
@end


