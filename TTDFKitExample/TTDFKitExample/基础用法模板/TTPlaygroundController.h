//
//  TTPlaygroundController.h
//  TTDFKit
//
//  Created by ty on 2019/5/22.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface TTPlaygroundController : RootViewController
@property(nonatomic,strong) UIViewController * rootVC;
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

- (void)testFunc;


- (void)testInt:(int)p1 string:(NSString*)p2;
- (void)testArray:(NSArray *)p1 dic:(NSDictionary *)p2;

- (void)testBlockInt:(void(^)(int))p1;
- (void)testBlockString:(void(^)(NSString*))p1;
- (void)testBlockObj:(void(^)(id))p1;

@end

NS_ASSUME_NONNULL_END
