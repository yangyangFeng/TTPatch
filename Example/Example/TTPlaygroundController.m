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
- (void)params1:(int)params1 params2:(int)params2 params3:(int)params3 params4:(int)params4 params5:(int)params5 params6:(int)params6 params7:(int)params7;
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

-(void)params1:(int)params1 params2:(int)params2 params3:(int)params3 params4:(int)params4 params5:(int)params5 params6:(int)params6 params7:(int)params7{
    NSLog(@"---------1,2,3,43,45,6,");
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadJSCode];
}


- (void)jsInvocationOcWithBlock:(void(^)(void))block
{
    NSLog(@"%s",__func__);
    block();
}

- (void)test{
    NSLog(@"%s",__func__);
}

+ (void)testAction:(NSString *)str{
    NSLog(@"--------静态方法测试--------- %@",str);
}
- (void)testAction:(NSString *)str{
    NSLog(@"--------实例方法测试--------- %@",str);
}

- (void)testSuper{
    NSLog(@"[self testSuper]");
}



@end
