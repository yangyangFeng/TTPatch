//
//  TTPatchUnitTests.m
//  ExampleTests
//
//  Created by tianyubing on 2020/4/24.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import "TTPatchUnitTests.h"
#import "TTPatch.h"
#import "TTPatchKit.h"
@implementation TTPatchUnitTests
- (void)nativeCallJsCase{
    
    TTLog(@"[1]funcWithBlockParams: string");
     [self funcWithBlockParams:@"string" param2:^(NSString * _Nonnull arg) {
         TTLog(@"[1]funcWithBlockParams:callback %@",arg);
     }];
    
    TTLog(@"[2]funcWithBlockParams:paramInt2: blockFuncInt");
     [self funcWithBlockParams:@"blockFuncInt" paramInt2:^(int arg) {
         TTLog(@"[2]funcWithBlockParams:paramInt2: %d",arg);
     }];
    
    TTLog(@"[3]funcWithBlockParams:param2: %@,%@",@[@"1",@"2",[NSObject new]],@{@"key":@"TTPatchUnitTests",
                                                            @"vc":self,});
     [self funcWithParams:@[@"1",@"2",[NSObject new]] param2:@{@"key":@"TTPatchUnitTests",
                                                             @"vc":self,
     }];
}

- (void)JsCallNativeCase{
    
}

- (void)blockAddSignatureCase{
    
}

@end
