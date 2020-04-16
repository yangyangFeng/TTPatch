//
//  TTPlaygroundController.h
//  TTPatch
//
//  Created by ty on 2019/5/22.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTPlaygroundController : RootViewController
- (void)funcWithParams:(NSString * )param1;

- (void)funcWithParams:(NSString * )param1
                param2:(NSString *)param2;

- (void)funcWithParams:(NSString * )param1
                param2:(NSString *)param2
                param3:(NSString *)param3;

- (void)funcWithBlockParams:(NSString * )param1
                     param2:(void(^)(NSString *arg))param2;

@end

NS_ASSUME_NONNULL_END
