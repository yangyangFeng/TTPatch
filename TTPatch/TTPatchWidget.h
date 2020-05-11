//
//  TTPatchWidget.h
//  Example
//
//  Created by tianyubing on 2020/4/21.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface TTPatchURLSession : NSObject
+ (instancetype _Nonnull)sharedSession;
- (NSURLSessionDataTask *_Nonnull)ttpatch_dataTaskWithRequest:(NSURLRequest *_Nullable)request completionHandler:(void (^_Nullable)(NSString * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
@end

@interface TTPatchParser : NSObject
+ (NSData *)stringToData:(NSString *)str;
+ (NSData *)dataToString:(NSData *)data;
@end


