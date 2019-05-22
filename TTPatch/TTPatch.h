//
//  TTPatch.h
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>



@class TTContext;
@interface TTPatch : NSObject
+ (TTPatch *)shareInstance;

- (void)evaluateScript:(NSString *)script;
- (void)evaluateScript:(NSString *)script withSourceURL:(NSURL *)sourceURL;

- (void)clearContext;
- (NSString *)formatterJS:(NSString *)script;
@property(nonatomic,strong,readonly)TTContext *context;
@end


