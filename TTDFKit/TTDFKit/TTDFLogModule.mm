//
//  TTDFLogModule.m
//  TTDFKit
//
//  Created by tianyu on 2022/3/3.
//

#import "TTDFLogModule.h"

#import "TTDFEntry.h"
#import "TTDFKit.h"

@implementation TTDFLogModule
+ (void)logFileName:(NSString *)fileName line:(NSInteger)line level:(log_level)level fprmat:(NSString *)format, ... NS_REQUIRES_NIL_TERMINATION {
    va_list paramList;
    va_start(paramList, format);
    NSString *argMsg = [[NSString alloc] initWithFormat:format arguments:paramList];
    NSString *msg = [NSString stringWithFormat:@"[TTDFKit][%@:%ld]%@", fileName, line, argMsg];
    va_end(paramList);
    [self log:msg level:level];
}

+ (void)log:(NSString *)message level:(log_level)level {
    if (![TTDFEntry shareInstance].config.isOpenLog) {
        return;
    }
    switch (level) {
        case log_level_debug: {
            [self log_debug:message];
        } break;
        case log_level_info: {
            [self log_info:message];
        } break;
        case log_level_error: {
            [self log_error:message];
        } break;
        default:
            [self log_debug:message];
            break;
    }
}

+ (void)log_debug:(NSString *)message {
    if ([TTDFEntry shareInstance].logDelegate) {
        [[TTDFEntry shareInstance].logDelegate log:message level:log_level_debug];
    }
}

+ (void)log_info:(NSString *)message {
    if ([TTDFEntry shareInstance].logDelegate) {
        [[TTDFEntry shareInstance].logDelegate log:message level:log_level_info];
    }
}

+ (void)log_error:(NSString *)message {
    if ([TTDFEntry shareInstance].logDelegate) {
        [[TTDFEntry shareInstance].logDelegate log:message level:log_level_error];
    }
}

@end
