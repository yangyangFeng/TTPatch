//
//  TTPatch.m
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTPatch.h"
#import "TTContext.h"
#import "TTPatchMethodCleaner.h"


#define guard(condfion) if(condfion){}
//static NSString *_replaceStr = @".call(\"$1\"";
//static NSString *_regexStr =
////@"\?=.+)$";
//@"(?<!\\\\)\\.\\s*(\\w+)\\s*\\";
static NSString *_regexStr = @"(?<!\\\\)\\.\\s*(\\w+)\\s*\\(";
static NSString *_replaceStr = @".call(\"$1\")(";

static NSString *_regexStr2 = @"[())]{3}";
static NSString *_replaceStr2 = @")";


static NSString *_regexStr3 = @"$$|\\)\\(";
static NSString *_replaceStr3 = @",";

static NSRegularExpression* _regex;
static TTPatch *instance = nil;

@interface TTPatch ()

@property(nonatomic,strong)TTContext *context;
@end

@implementation TTPatch

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
    [self loadTTJSKit];
    [TTPatchMethodCleaner clean];
    guard(script) else{
        NSAssert(NO, @"执行脚本为空,请检查");
    }
 
    
    if (sourceURL) {
        [self.context evaluateScript:script withSourceURL:sourceURL];
    }else{
        [self.context evaluateScript:script];
    }
    
}

- (NSString *)formatterJS:(NSString *)script{
//    if (!_regex) {
//        _regex = [NSRegularExpression regularExpressionWithPattern:_regexStr options:0 error:nil];
//    }
//    NSString *formatedScript = [NSString stringWithFormat:@"%@", [_regex stringByReplacingMatchesInString:script options:0 range:NSMakeRange(0, script.length) withTemplate:_replaceStr]];
//
//    _regex = [NSRegularExpression regularExpressionWithPattern:_regexStr2 options:0 error:nil];
//NSString *formatedScript2 = [NSString stringWithFormat:@"%@", [_regex stringByReplacingMatchesInString:formatedScript options:0 range:NSMakeRange(0, script.length) withTemplate:_replaceStr2]];
//
//_regex = [NSRegularExpression regularExpressionWithPattern:_regexStr3 options:0 error:nil];
//NSString *formatedScript3 = [NSString stringWithFormat:@"%@", [_regex stringByReplacingMatchesInString:formatedScript2 options:0 range:NSMakeRange(0, script.length) withTemplate:_replaceStr3]];
    return script;
}

- (void)loadTTJSKit{
    if (!_context) {
        _context = [TTContext new];
        [_context configJSBrigeActions];
    }
}


@end
