//
//  TTDFUtilsTest.m
//  TTDFKitTests
//
//  Created by tianyu on 2022/3/4.
//  Copyright © 2022 tianyubing. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TTDFUtils.h"
@interface TTDFUtilsTest : XCTestCase

@end

@implementation TTDFUtilsTest

- (void)testObjectConvertMethod {
    id pointObj = CGPointToJSObject(CGPointZero);
    XCTAssertNotNil(pointObj);

    id sizeObj = CGSizeToJSObject(CGSizeZero);
    XCTAssertNotNil(sizeObj);

    id rectObj = CGReactToJSObject(CGRectZero);
    XCTAssertNotNil(rectObj);

    id insetsObj = UIEdgeInsetsToJSObject(UIEdgeInsetsZero);
    XCTAssertNotNil(insetsObj);

    CGPoint point = toOcCGPoint(@"{0,0}}");
    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, point));
    point = toOcCGPoint(nil);
    XCTAssertTrue(CGPointEqualToPoint(CGPointZero, point));
    point = toOcCGPoint(@"{1,1}}");
    XCTAssertTrue(!CGPointEqualToPoint(CGPointZero, point));

    CGSize size = toOcCGSize(@"{0,0}");
    XCTAssertTrue(CGSizeEqualToSize(CGSizeZero, size));
    size = toOcCGSize(nil);
    XCTAssertTrue(CGSizeEqualToSize(CGSizeZero, size));
    size = toOcCGSize(@"{1,1}");
    XCTAssertTrue(!CGSizeEqualToSize(CGSizeZero, size));

    CGRect rect = toOcCGReact(@"{0,0,0,0}");
    XCTAssertTrue(CGRectEqualToRect(CGRectZero, rect));
    rect = toOcCGReact(nil);
    XCTAssertTrue(CGRectEqualToRect(CGRectZero, rect));
    rect = toOcCGReact(@"{{1,1},{1,1}}");
    XCTAssertTrue(!CGRectEqualToRect(CGRectZero, rect));

    UIEdgeInsets insets = toOcEdgeInsets(@"{0,0,0,0}");
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, insets));
    insets = toOcEdgeInsets(nil);
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, insets));
    insets = toOcEdgeInsets(@"{1,1,1,1}");
    XCTAssertTrue(!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, insets));
}

- (void)testMethodFormatterToOcFunc {
    //单个_转换:
    NSString *ocFunc = MethodFormatterToOcFunc(@"test__a");
    XCTAssertTrue([ocFunc isEqualToString:@"test_a"]);
    //两个__转换_
    ocFunc = MethodFormatterToOcFunc(@"test___a");
    XCTAssertTrue([ocFunc isEqualToString:@"test_:a"]);
}

- (void)testMethodFormatterToJSFunc {
    //:转换成_
    NSString *jsFunc = MethodFormatterToJSFunc(@"test:a");
    XCTAssertTrue([jsFunc isEqualToString:@"test_a"]);
    //_转换成__
    jsFunc = MethodFormatterToJSFunc(@"test_:a");
    XCTAssertTrue([jsFunc isEqualToString:@"test___a"]);
}

- (void)testObjectConvert {
    // oc对象 to js, 再将转回 oc对象.
    id ocObj = [NSObject new];
    id jsObj = ToJsObject(ocObj, @"NSObject");
    XCTAssertTrue(jsObj != nil);
    id newOcObj = ToOcObject(jsObj);
    XCTAssertEqual(ocObj, newOcObj);

    ocObj = nil;
    jsObj = ToJsObject(ocObj, @"NSObject");
    XCTAssertTrue(jsObj != nil);
    newOcObj = ToOcObject(jsObj);
    XCTAssertEqual(ocObj, newOcObj);

    //容器里对象在js/oc转换时会自动转换,容器对象会发生改变, 容器内的对象,基础数据类型不改变
    ocObj = @[@"1", @"2", @"3"];
    jsObj = ToJsObject(ocObj, @"NSArray");
    XCTAssertTrue(jsObj != nil);
    newOcObj = ToOcObject(jsObj);
    XCTAssertTrue(ocObj[0] == newOcObj[0]);

    ocObj = @[@"1", @"2", @"3"].mutableCopy;
    jsObj = ToJsObject(ocObj, @"NSMutableArray");
    XCTAssertTrue(jsObj != nil);
    newOcObj = ToOcObject(jsObj);
    XCTAssertTrue(ocObj[0] == newOcObj[0]);

    ocObj = @{ @"key": @"val" };
    jsObj = ToJsObject(ocObj, @"NSDictionary");
    XCTAssertTrue(jsObj != nil);
    newOcObj = ToOcObject(jsObj);
    XCTAssertTrue([(NSString *)ocObj[@"key"] isEqualToString:newOcObj[@"key"]]);

    ocObj = @{ @"key": @"val" }.mutableCopy;
    jsObj = ToJsObject(ocObj, @"NSMutableDictionary");
    XCTAssertTrue(jsObj != nil);
    newOcObj = ToOcObject(jsObj);
    XCTAssertTrue([(NSString *)ocObj[@"key"] isEqualToString:newOcObj[@"key"]]);
}

@end
