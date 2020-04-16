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

    [self funcWithParams:@"悟空"];
    [self funcWithParams:@"熊大" param2:@"熊二"];
    [self funcWithParams:@"百度" param2:@"腾讯" param3:@"阿里"];
    
}

@end
