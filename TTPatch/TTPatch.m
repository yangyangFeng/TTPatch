//
//  TTPatch.m
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTPatch.h"
#import "TTPatchKit.h"



static NSRegularExpression* _regex;
static TTPatch *instance = nil;

@interface TTPatch ()

@property(nonatomic,strong)TTContext *context;
@end

@implementation TTPatch

+ (void)initSDK{
    [[self shareInstance] loadTTJSKit];
}

+ (TTPatch *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TTPatch new];
    });
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

- (NSString *)formatterJS:(NSString *)script{
    return script;
}

- (void)clearContext{
    [TTPatchMethodCleaner clean];
    self.context = nil;
}

- (void)loadTTJSKit{
    if (!_context) {
        _context = [TTContext new];
        [_context configJSBrigeActions];
        [self runMainJS];
    }
}

- (void)runMainJS{
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [myBundle pathForResource:@"TTPatch" ofType:@"js"];
    NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    [self evaluateScript:jsCode withSourceURL:[NSURL URLWithString:@"TTPatch.js"]];
}

@end
