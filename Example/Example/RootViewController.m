//
//  RootViewController.m
//  TTPatch
//
//  Created by ty on 2019/6/23.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "RootViewController.h"
#import <WebKit/WebKit.h>
@interface RootViewController ()

@end

@implementation RootViewController

-(void)dealloc{
    NSLog(@"----");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"[super viewDidLoad]");
    // Do any additional setup after loading the view.
}

- (void)testSuper{
    NSLog(@"[super testSuper]");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
