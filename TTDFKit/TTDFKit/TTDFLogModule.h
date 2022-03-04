//
//  TTDFLogModule.h
//  TTDFKit
//
//  Created by tianyu on 2022/3/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT void tt_log(NSString *format, ...);
typedef enum : NSUInteger {
    log_level_debug,
    log_level_info,
    log_level_error,
} log_level;

@protocol TTLogProtocol <NSObject>
- (void)log:(NSString *)log level:(log_level)level;
@end

@interface TTDFLogModule : NSObject
+ (void)logFileName:(NSString *)fileName line:(NSInteger)line level:(log_level)level fprmat:(NSString *)format, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)log:(NSString *)message level:(log_level)level;
+ (void)log_debug:(NSString *)message;
+ (void)log_info:(NSString *)message;
+ (void)log_error:(NSString *)message;
@end

NS_ASSUME_NONNULL_END

#define TTLog_Debug(fmt, ...) \
    [TTDFLogModule logFileName:[NSString stringWithFormat:@"%s", __FILE_NAME__] line:__LINE__ level:log_level_debug fprmat:fmt, ##__VA_ARGS__, nil]
#define TTLog_Info(fmt, ...) \
    [TTDFLogModule logFileName:[NSString stringWithFormat:@"%s", __FILE_NAME__] line:__LINE__ level:log_level_info fprmat:fmt, ##__VA_ARGS__, nil]
#define TTLog_Error(fmt, ...) \
    [TTDFLogModule logFileName:[NSString stringWithFormat:@"%s", __FILE_NAME__] line:__LINE__ level:log_level_error fprmat:fmt, ##__VA_ARGS__, nil]
