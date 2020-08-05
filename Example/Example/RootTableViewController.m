//
//  RootTableViewController.m
//  Example
//
//  Created by tianyubing on 2020/4/3.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import "RootTableViewController.h"
#import "SGDirWatchdog.h"
#import "TTDFKit.h"
#import "TTDFKitHotRefrshTool.h"
@interface RootTableViewController ()

@end

@implementation RootTableViewController
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"TTDFKit-Refresh" object:nil];
}

- (void)refresh{
    
}

- (void)updateResource:(void(^)(void))callback
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/%@",
                                                                           [TTDFKitHotRefrshTool shareInstance].getLocaServerIP,
                                                                           [TTDFKitHotRefrshTool shareInstance].getLocaServerPort,
                                                                           self.jsFileName]]];
    if (!self.jsFileName.length) {
        return;
    }
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && (error == nil)) {
            // 网络访问成功
            NSLog(@"data=%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [[TTDFKit shareInstance] evaluateScript:result withSourceURL:[NSURL URLWithString:self.jsFileName]];
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


- (void)loadJSCode{}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
