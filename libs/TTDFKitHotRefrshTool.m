//
//  TTDFKitHotRefrshTool.m
//  Example
//
//  Created by tianyubing on 2020/4/2.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import "TTDFKitHotRefrshTool.h"

@import SocketIO;

static TTDFKitHotRefrshTool *instance=nil;
static NSString * LocaServerIP=nil;
@interface TTDFKitHotRefrshTool ()
@property(nonatomic,strong )SocketManager* manager;
@property(nonatomic,strong) NSString *curUrl;
@end

@implementation TTDFKitHotRefrshTool
+ (instancetype)shareInstance{
    if (!instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [TTDFKitHotRefrshTool new];
            NSString *_ip=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"TTDFKitIP"];
            NSArray *arr=[_ip componentsSeparatedByString:@"\n"];
            NSString *localIp = [arr firstObject];
            LocaServerIP=localIp;
        });
    }
    return instance;
}

- (void)startLocalServer:(NSString *)url
{
        self.manager = [[SocketManager alloc] initWithSocketURL:[NSURL URLWithString:url] config:@{@"log": @NO, @"forcePolling": @YES}];
        SocketIOClient* socket = _manager.defaultSocket;

        [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"\n------------------------------------------------------------\
            \n本地服务已连接,js文件保存后可实时同步结果\
            \n------------------------------------------------------------");
        }];

        
        [socket on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSLog(@"\n------------------------------------------------------------\
            \n断开连接\
            \n------------------------------------------------------------");
        }];
        [socket on:@"message" callback:^(NSArray* data, SocketAckEmitter* ack) {
            NSString *msg = [data firstObject];
            NSString *file=[[msg componentsSeparatedByString:@":"] lastObject];
            if ([msg containsString:@"refresh"]) {
                if ([self.delegate respondsToSelector:@selector(reviceRefresh:)]) {
                    [self.delegate reviceRefresh:file];
                }
            }
        }];
        [socket on:@"error" callback:^(NSArray* data, SocketAckEmitter* ack) {
            
            NSLog(@"\n------------------------------------------------------------\
            \n本地服务连接失败,实时显示不可用,请开启本地服务,将手机与PC置于统一网络环境,并设置PC当前ip到工程中\
            \n------------------------------------------------------------");
        }];

        [socket connect];
    
}


- (NSString *_Nullable)getLocaServerIP
{
    return LocaServerIP;
}

- (NSString *_Nullable)getLocaServerPort{
    return @"3000";
}

static NSArray *GetMsgContent(NSString *string,NSString *regexStr){

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray * matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    //match: 所有匹配到的字符,根据() 包含级
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in matches) {
        
        for (int i = 0; i < [match numberOfRanges]; i++) {
            //以正则中的(),划分成不同的匹配部分
            NSString *component = [string substringWithRange:[match rangeAtIndex:i]];
            
            [array addObject:component];
            
        }
        
    }
    return array;
}

@end
