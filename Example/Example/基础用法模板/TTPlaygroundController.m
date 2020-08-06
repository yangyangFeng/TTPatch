//
//  TTPlaygroundController.m
//  TTDFKit
//
//  Created by ty on 2019/5/22.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTPlaygroundController.h"
#import "SGDirWatchdog.h"
#import <TTDFKit/TTDFKit.h>
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
   
    [self funcWithParams:@[@"1",@"2",[UIView new]] param2:@{@"key":[UIView new],
                                                            @"vc":self,
    }];
    
    /*
     * native调用js方法,参数带block
     * 实际场景:
     *      可将线上出bug的方法替换为js实现,从而规避bug.
     */
    [self testBlockInt:^(int p1) {
        TTLog_Info(@"[%s] p1:%d",__func__,p1);
    }];
    
    [self testBlockString:^(NSString * _Nonnull p1) {
        TTLog_Info(@"[%s] p1:%@",__func__,p1);
    }];
    
    [self testBlockObj:^(id _Nonnull p1) {
       TTLog_Info(@"[%s] p1:%@",__func__,p1);
    }];
    
    [self testInt:1 string:@"2"];
    [self testArray:nil dic:nil];
}

- (void)testInt:(int)p1 string:(NSString*)p2{
    TTLog_Info(@"[%s] p1:%d p2:%@",__func__,p1,p2);
 
}

- (void)testArray:(NSArray *)p1 dic:(NSDictionary *)p2{
    TTLog_Info(@"[%s] p1:%@ p2:%@",__func__,p1,p2);
}

@end
