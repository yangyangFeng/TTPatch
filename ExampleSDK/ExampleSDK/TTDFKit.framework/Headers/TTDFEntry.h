//
//  TTDFKit.h
//  TTDFKit
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>


@class TTContext,TTDFKitConfigModel;
@protocol TTLogProtocol;
/**
 *TTDFKit 声明周期,初始化u入口
 */
@interface TTDFEntry : NSObject

/// SDK 初始化, 建议程序启动时优先初始化,以保证能修复更多场景
+ (void )initSDK;

/// 析构组件
+ (void)deInitSDK;

/// 获取当前JS 上下文
+ (TTDFEntry *)shareInstance;


/// 执行 patch
/// @param script js
- (void)evaluateScript:(NSString *)script;

/// 执行 patch
/// @param script js
/// @param sourceURL ,用于调式时展示的 .js 文件名
- (void)evaluateScript:(NSString *)script withSourceURL:(NSURL *)sourceURL;

- (void)projectConfig:(TTDFKitConfigModel *)config;

@property(nonatomic,strong,readonly)TTContext *context;
@property(nonatomic,strong,readonly)TTDFKitConfigModel *config;

@property(nonatomic,weak) id<TTLogProtocol> logDelegate;
@end


