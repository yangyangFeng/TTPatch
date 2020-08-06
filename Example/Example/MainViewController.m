//
//  MainViewController.m
//  TTDFKit
//
//  Created by ty on 2019/6/27.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "MainViewController.h"
#import <TTDFKit/TTDFKit.h>
#import "TTDFKitHotRefrshTool.h"

@interface MainViewController ()

@end

@implementation MainViewController
- (IBAction)refresh:(id)sender {
    [TTDFEntry deInitSDK];
    [self updateResource:nil];
}
- (void)updateResource:(void(^)(void))callback
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/%@",
                                                                           [TTDFKitHotRefrshTool shareInstance].getLocaServerIP,
                                                                           [TTDFKitHotRefrshTool shareInstance].getLocaServerPort,
                                                                           self.jsFileName]]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && (error == nil)) {
            // 网络访问成功
            NSLog(@"data=%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [[TTDFEntry shareInstance] evaluateScript:result withSourceURL:[NSURL URLWithString:@"hotfixPatch.js"]];
            if (callback) {
                callback();
            }
        } else {
            // 网络访问失败
            NSLog(@"error=%@",error);
        }
    }];
    [dataTask resume];
}

- (IBAction)openHomeAction:(id)sender {
        
    Class homeVCClass = NSClassFromString(@"HomeViewController");
    id homeVC = [homeVCClass new];
    [self.navigationController pushViewController:homeVC animated:YES];
}

- (NSString *)jsFileName{
    return @"Home.js";
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
