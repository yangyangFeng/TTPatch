//
//  RootViewController.m
//  TTPatch
//
//  Created by ty on 2019/6/23.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "RootViewController.h"
#import "SGDirWatchdog.h"
#import "TTPatch.h"
#import "TTPatchHotRefrshTool.h"
@interface RootViewController ()
@property(nonatomic,strong)SGDirWatchdog *watchDog;
@end

@implementation RootViewController

- (NSString *)jsFileName{
    return @"";
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"----");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"TTPatch-Refresh" object:nil];
}

- (void)refresh{
    
}

- (void)updateResource:(void(^)(void))callback
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/%@",
                                                                           [TTPatchHotRefrshTool shareInstance].getLocaServerIP,
                                                                           [TTPatchHotRefrshTool shareInstance].getLocaServerPort,
                                                                           self.jsFileName]]];
    if (!self.jsFileName.length) {
        return;
    }
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && (error == nil)) {
            // 网络访问成功
            NSLog(@"data=%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [[TTPatch shareInstance] evaluateScript:[[TTPatch shareInstance] formatterJS:result] withSourceURL:[NSURL URLWithString:self.jsFileName]];
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

- (void)initJSContxtPath{
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
    NSString *path = [rootPath stringByAppendingPathComponent:@"../JS/TTPatch.js"];

    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"../JS/outputs"];
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:scriptRootPath error:NULL];


    for (NSString *aPath in contentOfFolder) {
        if ([aPath isEqualToString:@"Playground.js"]) {
            NSString * fullPath = [scriptRootPath stringByAppendingPathComponent:aPath];
            [self watchFolder:fullPath mainScriptPath:path];
        }
    }
    
}

- (void)watch{
    
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"../JS/outputs"];
    NSString *srcPath = [scriptRootPath stringByAppendingPathComponent:self.jsFileName];
    
    NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:srcPath] encoding:NSUTF8StringEncoding];
    if (jsCode.length) {
        [[TTPatch shareInstance] evaluateScript:[[TTPatch shareInstance] formatterJS:jsCode] withSourceURL:[NSURL URLWithString:self.jsFileName]];
    }
    
    [self loadJSCode];
}

- (void)watchFolder:(NSString *)folderPath mainScriptPath:(NSString *)mainScriptPath
{
    SGDirWatchdog *watchDog = [[SGDirWatchdog alloc] initWithPath:folderPath update:^{
        NSLog(@"--------------------\n reload");
        [self watch];
    }];
    [watchDog start];
    self.watchDog = watchDog;
//    [self.watchDogs addObject:watchDog];
}

- (void)loadJSCode{}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
