//
//  AppDelegate.m
//  TTPatch
//
//  Created by ty on 2019/5/17.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "AppDelegate.h"
#import "TTPatch.h"
#import "SRWebSocket.h"
@interface AppDelegate ()<SRWebSocketDelegate>
@property(nonatomic,strong) SRWebSocket*hotReloadSocket;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 初始化SDK
    [TTPatch initSDK];
    
    /**
     * 加载离线的热修复补丁
     * 这里 `rootPath` 为项目根目录,如果通过手机运行 ,需要修改为bundle资源访问, 否则无法访问电脑资源,页面显示空白
     */
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"bugfix"]) {
        NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
        NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"../JS/outputs"];
        NSString *srcPath = [scriptRootPath stringByAppendingPathComponent:@"bugPatch.js"];
           
        NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:srcPath] encoding:NSUTF8StringEncoding];
               
        [[TTPatch shareInstance] evaluateScript:[[TTPatch shareInstance] formatterJS:jsCode] withSourceURL:[NSURL URLWithString:@"bugfix.js"]];
        NSLog(@"[补丁加载成功!!]");
    }
    [self updateResource:nil];
    [self testSocket];
    return YES;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"[socket]:%@",message);
    NSString *msg = [NSString stringWithFormat:@"%@",message];
    if ([msg containsString:@"refresh"]) {
//        [TTPatch deInitSDK];
//        [TTPatch initSDK];
        [self updateResource:nil];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    [webSocket sendPing:[NSData dataWithBytes:"p" length:1]];
    NSLog(@"%s",__func__);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"%s",__func__);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (webSocket.readyState == SR_CLOSED) {
            [self testSocket];
//        }
    });
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (webSocket.readyState == SR_OPEN) {
            [webSocket sendPing:[NSData dataWithBytes:"p" length:1]];
        }
    });
    NSLog(@"[pong]:%s",[pongPayload bytes]);
}

- (void)testSocket{
    
    
//    NSURL *socketURL = [NSURL URLWithString:[NSString stringWithFormat:@"ws://10.72.148.19:8888/socket.io/?EIO=4&transport=websocket"]];
    NSURL *socketURL = [NSURL URLWithString:[NSString stringWithFormat:@"ws://10.72.148.19:8888/socket.io/?EIO=4&transport=websocket"]];

    self.hotReloadSocket = [[SRWebSocket alloc] initWithURL:socketURL protocols:@[@"echo-protocol"]];
    self.hotReloadSocket.delegate = self;
    [self.hotReloadSocket open];
}

- (void)updateResource:(void(^)(void))callback
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://10.72.148.19:8888/%@",@"hotfixPatch.js"]]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && (error == nil)) {
            // 网络访问成功
//            NSLog(@"data=%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [[TTPatch shareInstance] evaluateScript:[[TTPatch shareInstance] formatterJS:result] withSourceURL:[NSURL URLWithString:@"hotfixPatch.js"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TTPatch-Refresh" object:nil];
            });
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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
