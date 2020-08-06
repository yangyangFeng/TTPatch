//
//  TTDFKitHotRefrshTool.h
//  Example
//
//  Created by tianyubing on 2020/4/2.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AUTO_CONNECTION 1
#define AUTO_CONNECTION_TIME 5
#define PING_TIME 1


NS_ASSUME_NONNULL_BEGIN

@protocol TTDFKitHotRefrshTool <NSObject>

- (void)reviceRefresh:(id)msg;

@end

@interface TTDFKitHotRefrshTool : NSObject
@property(nonatomic,weak)id<TTDFKitHotRefrshTool> delegate;

+ (instancetype)shareInstance;
- (void)startLocalServer:(NSString *)url;
- (NSString *_Nullable)getLocaServerIP;
- (NSString *_Nullable)getLocaServerPort;
@end

NS_ASSUME_NONNULL_END
