//
//  TTDFKitHelper.m
//  Example
//
//  Created by tianyubing on 2020/4/21.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import "TTDFWidget.h"

@implementation TTDFKitURLSession
+ (instancetype _Nonnull)sharedSession{
    return [TTDFKitURLSession new];
}
- (NSURLSessionDataTask *_Nonnull)TTDFKit_dataTaskWithRequest:(NSURLRequest *_Nullable)request completionHandler:(void (^_Nullable)(NSString * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    return [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],response,error);
        }
    }];
}
@end

@implementation TTDFKitParser
+ (NSData *)stringToData:(NSString *)str{
    return [str dataUsingEncoding:(NSUTF8StringEncoding)];
}
+ (NSString *)dataToString:(NSData *)data{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
