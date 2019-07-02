//
//  MainViewController.m
//  TTPatch
//
//  Created by ty on 2019/6/27.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "MainViewController.h"
#import "TTPatch.h"
@interface MainViewController ()

@end

@implementation MainViewController
- (IBAction)refresh:(id)sender {
    [[TTPatch shareInstance] clearContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
