//
//  TTPlaygroundController.m
//  TTPatch
//
//  Created by ty on 2019/5/22.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTPlaygroundController.h"
#import "SGDirWatchdog.h"
#import "TTPatch.h"
#import <objc/runtime.h>

@interface TTPlaygroundController ()
@end

@implementation TTPlaygroundController

- (NSString *)jsFileName{

     
    return @"Playground.js";
}

-(void)dealloc{
    NSLog(@"dealloc -------- Oc");
}

- (void)viewDidLoad {
    [super viewDidLoad];

        
}
- (void)testFunc{

    [self funcWithBlockParams:@"blockFunc" param2:^(NSString * _Nonnull arg) {
        NSLog(@"blockFunc: %@",arg);
    }];
    
    [self funcWithBlockParams:@"blockFuncInt" paramInt2:^(int arg) {
        NSLog(@"blockFuncInt: %d",arg);
    }];
   
    
}


@end
