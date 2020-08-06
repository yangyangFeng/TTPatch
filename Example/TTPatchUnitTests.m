//
//  TTPatchUnitTests.m
//  ExampleTests
//
//  Created by tianyubing on 2020/4/24.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import "TTPatchUnitTests.h"
#import "TTPatch.h"
#import "TTPatchKit.h"
#import "TTPatchHotRefrshTool.h"

@implementation TTPatchUnitTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // 初始化SDK
//    [TTPatch initSDK];

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

        /**
//         * 连接本地测试服务,如加载空白,请检查
//         * 1.本地服务是否已启动成功
//         * 2.检查`info.plist`中IP是否获取正确
//         */
//        [self testSocket];
//        // 拉取本地js资源
////        [self updateResource:@"hotfixPatch" callbacl:nil];
////        [self loadupdateResource:@"hotfixPatch.js" callbacl:nil];
////    [TTPatchUnitTests testAction:@"unit-test"];
    [self testNativeCallJsCase];
}


- (void)testNativeCallJsCase{
//    sleep(10);
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
}

/*
 * js调用native方法,参数携带block
 * 实际场景:
 *      js可以实现一部分逻辑,如必须调用native方法,可以参照该场景实现
 */
- (void)testCall0:(void(^)(void))call{
    if (call) {
        call();
    }
}

- (void)testInt:(int)p1 string:(NSString*)p2{
    
}
- (void)testArray:(NSArray *)p1 dic:(NSDictionary *)p2{
    
}

//- (void)testBlockInt:(void(^)(int))p1{
//
//}
//- (void)testBlockString:(void(^)(NSString*))p1{
//
//}
//- (void)testBlockObj:(void(^)(id))p1{
//
//}

- (void)testCall1:(void(^)(NSString * str,int inta))call{
    if (call) {
        call(@"{\"id\":1,\"name\":\"Tencent\",\"email\":\"admin@Tencent.com\",\"interest\":[\"Tencent\",\"Tencent\"]}",999);
    }
}

- (void)testCall2:(NSString *(^)(NSString *str))call{
    if (call) {
        NSString * val = call(@"input");
        
    }
}

- (void)testCall3:(NSString *(^)(void))call{
    if (call) {
        NSString * val = call();
        
    }
}

/*
* js调用native方法,静态方法
*/
+ (void)testAction:(NSString *)str{
    
}


- (void)testSocket{
    
    NSString *socket;
#if TARGET_IPHONE_SIMULATOR  //模拟器
    socket = [NSString stringWithFormat:@"ws://%@:%@/socket.io/?EIO=4&transport=websocket",
              @"127.0.0.1",
              [TTPatchHotRefrshTool shareInstance].getLocaServerPort];
#elif TARGET_OS_IPHONE      //真机
    socket = [NSString stringWithFormat:@"ws://%@:%@/socket.io/?EIO=4&transport=websocket",
              [TTPatchHotRefrshTool shareInstance].getLocaServerIP,
              [TTPatchHotRefrshTool shareInstance].getLocaServerPort];
#endif
    [[TTPatchHotRefrshTool shareInstance] startLocalServer:socket];
    [TTPatchHotRefrshTool shareInstance].delegate = self;
}

- (void)reviceRefresh:(id)msg{
//    [self updateResource:msg callbacl:nil];
}

//- (void)updateResource:(NSString *)filename callbacl:(void(^)(void))callback
//{
//    NSString *srcPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"js"];
//
//
//    NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:srcPath] encoding:NSUTF8StringEncoding];
//
//    [[TTPatch shareInstance] evaluateScript:[[TTPatch shareInstance] formatterJS:jsCode] withSourceURL:[NSURL URLWithString:filename]];
//}


@end
