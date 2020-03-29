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
#import "TTPatchUtils.h"

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


@end
