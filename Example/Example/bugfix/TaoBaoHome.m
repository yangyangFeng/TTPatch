//
//  TaoBaoHome.m
//  Example
//
//  Created by tianyubing on 2020/3/27.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import "TaoBaoHome.h"

@interface TaoBaoHome ()

@property(nonatomic,strong)UIAlertController *alert;
@end

@implementation TaoBaoHome

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *home = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tianmao.jpg"]];
    home.frame = self.view.bounds;
    
    [self.view addSubview:home];
    
    [self showAlert];
}

- (void)showAlert{
    _alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"将于**月**日强制升级!!!!!" preferredStyle:(UIAlertControllerStyleAlert)];
    [_alert addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
 
    [self presentViewController:_alert animated:YES completion:nil];
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
