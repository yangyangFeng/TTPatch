//
//  TTDFKit.m
//  TTDFKit
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTDFEntry.h"
#import "TTDFKit.h"



static NSRegularExpression* _regex;
static TTDFEntry *instance = nil;

@interface TTDFEntry ()

@property(nonatomic,strong)TTContext *context;
@property(nonatomic,strong)TTDFKitConfigModel *config;
@end

@implementation TTDFEntry

+ (void)initSDK{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TTDFEntry new];
    });
    [instance loadTTJSKit];
}

+ (void)deInitSDK{
    [[TTDFEntry shareInstance] clearContext];
}

+ (TTDFEntry *)shareInstance{
    return instance;
}

- (void)evaluateScript:(NSString *)script{
    [self evaluateScript:script withSourceURL:nil];
}

- (void)evaluateScript:(NSString *)script withSourceURL:(NSURL *)sourceURL{
    guard(script != nil && script.length) else{
        TTAssert(NO, @"执行脚本为空,请检查");
    }
    if (sourceURL) {
        [self.context evaluateScript:script withSourceURL:sourceURL];
    }else{
        [self.context evaluateScript:script];
    }
}

- (void)clearContext{
    [TTDFMethodCleaner clean];
    self.context = nil;
}

- (void)loadTTJSKit{
    if (!_context) {
        _context = [TTContext new];
        [_context configJSBrigeActions];
        [self projectConfig:[TTDFKitConfigModel defaultConfig]];
        [self runMainJS];
    }
}

- (void)runMainJS{
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [myBundle pathForResource:@"TTDF.js" ofType:nil];
    NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    [self evaluateScript:jsCode withSourceURL:[NSURL URLWithString:@"TTDF_Core.js"]];
    
}

- (void)projectConfig:(TTDFKitConfigModel *)config{
    self.config=config;
}

- (void)setLogDelegate:(id<TTLogProtocol>)logDelegate{
    self.context.logDelegate = logDelegate;
}
@end
