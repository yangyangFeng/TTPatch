//
//  AppDelegate.m
//  TTDFKit
//
//  Created by ty on 2019/5/17.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "AppDelegate.h"

#import "TTDFKitHotRefrshTool.h"
#import <TTDFKit/TTDFKit.h>

@interface AppDelegate () <TTDFKitHotRefrshTool, TTLogProtocol>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 初始化SDK
    [TTDFEntry initSDK];
    [TTDFEntry shareInstance].logDelegate = self;
    TTDFKitConfigModel *config = [TTDFKitConfigModel new];
    config.isOpenLog = YES;  //打开日志输出, release下可关闭.
    [[TTDFEntry shareInstance] projectConfig:config];

    /**
     * 加载离线的热修复补丁
     * 这里 `rootPath` 为项目根目录,如果通过手机运行 ,需要修改为bundle资源访问, 否则无法访问电脑资源,页面显示空白
     */
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"bugfix"]) {
        NSString *srcPath = [[NSBundle mainBundle] pathForResource:@"bugPatch" ofType:@"js"];

        NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:srcPath] encoding:NSUTF8StringEncoding];

        [[TTDFEntry shareInstance] evaluateScript:jsCode withSourceURL:[NSURL URLWithString:@"bugfix.js"]];
        NSLog(@"[补丁加载成功!!]");
    }
    /**
     * 连接本地测试服务,如加载空白,请检查
     * 1.本地服务是否已启动成功
     * 2.检查`info.plist`中IP是否获取正确
     */
    [self testSocket];
    // 拉取本地js资源
    [self updateResource:@"hotfixPatch.js" callbacl:nil];
    return YES;
}

- (void)log:(NSString *)log level:(log_level)level {
    NSLog(@"%@", log);
}

- (void)testSocket {
    NSString *socket;
#if TARGET_IPHONE_SIMULATOR  //模拟器
    socket = [NSString
        stringWithFormat:@"ws://%@:%@/socket.io/?EIO=4&transport=websocket", @"127.0.0.1", [TTDFKitHotRefrshTool shareInstance].getLocaServerPort];
#elif TARGET_OS_IPHONE  //真机
    socket = [NSString stringWithFormat:@"ws://%@:%@/socket.io/?EIO=4&transport=websocket", [TTDFKitHotRefrshTool shareInstance].getLocaServerIP,
                       [TTDFKitHotRefrshTool shareInstance].getLocaServerPort];
#endif
    [[TTDFKitHotRefrshTool shareInstance] startLocalServer:socket];
    [TTDFKitHotRefrshTool shareInstance].delegate = self;
}

- (void)reviceRefresh:(id)msg {
    [self updateResource:msg callbacl:nil];
}

- (void)updateResource:(NSString *)filename callbacl:(void (^)(void))callback {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *req = [NSURLRequest
        requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/%@", [TTDFKitHotRefrshTool shareInstance].getLocaServerIP,
                                                      [TTDFKitHotRefrshTool shareInstance].getLocaServerPort, filename]]];

    NSLog(@"更新Path:%@", [req URL].absoluteString);
    NSURLSessionDataTask *dataTask =
        [session dataTaskWithRequest:req
                   completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                       if (data && (error == nil)) {
                           NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                           if (!result || !result.length) {
                               return;
                           }
                           [[TTDFEntry shareInstance] evaluateScript:result withSourceURL:[NSURL URLWithString:filename]];
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [[NSNotificationCenter defaultCenter] postNotificationName:@"TTDFKit-Refresh" object:nil];
                           });
                           if (callback) {
                               callback();
                           }
                       } else {
                           // 本地代理未开启,加载本地bundle资源,无法实时预览
                           NSString *srcPath = [[NSBundle mainBundle] pathForResource:@"hotfixPatch" ofType:@"js"];

                           NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:srcPath]
                                                                    encoding:NSUTF8StringEncoding];

                           [[TTDFEntry shareInstance] evaluateScript:jsCode withSourceURL:[NSURL URLWithString:@"hotfixPatch.js"]];
                       }
                   }];
    [dataTask resume];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as
    // an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state. Use this
    // method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later. If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the
    // background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
