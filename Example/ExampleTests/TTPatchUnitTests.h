//
//  TTPatchUnitTests.h
//  ExampleTests
//
//  Created by tianyubing on 2020/4/24.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTPatchUnitTests : NSObject
- (void)nativeCallJsCase;

- (void)JsCallNativeCase;

- (void)blockAddSignatureCase;

- (void)funcWithParams:(NSString * )param1;

- (void)funcWithParams:(NSArray * )param1
                param2:(NSDictionary *)param2;

- (void)funcWithParams:(NSString * )param1
                param2:(NSString *)param2
                param3:(NSString *)param3;

- (void)funcWithBlockParams:(NSString * )param1
                     param2:(void(^)(NSString *arg))param2;

- (void)funcWithBlockParams:(NSString * )param1
                     paramInt2:(void(^)(int ))param2;
@end

NS_ASSUME_NONNULL_END
