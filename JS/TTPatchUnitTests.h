//
//  TTPatchUnitTests.h
//  ExampleTests
//
//  Created by tianyubing on 2020/4/24.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTPatchUnitTests : NSObject
- (void)testExample;
- (void)testInt:(int)p1 string:(NSString*)p2;
- (void)testArray:(NSArray *)p1 dic:(NSDictionary *)p2;

- (void)testBlockInt:(void(^)(int))p1;
- (void)testBlockString:(void(^)(NSString*))p1;
- (void)testBlockObj:(void(^)(id))p1;


@end

NS_ASSUME_NONNULL_END
