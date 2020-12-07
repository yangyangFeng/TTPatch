//
//  TTDFWidget.h
//  Example
//
//  Created by tianyubing on 2020/4/21.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTDFKitURLSession : NSObject
+ (NSURLSessionDataTask *_Nonnull)dataTaskWithRequest:(NSURLRequest *_Nullable)request completionHandler:(void (^_Nullable)(NSString * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
@end

@interface TTDFKitParser : NSObject
+ (NSData * _Nonnull)stringToData:(NSString * _Nonnull)str;
+ (NSString * _Nonnull)dataToString:(NSData * _Nonnull)data;
@end


