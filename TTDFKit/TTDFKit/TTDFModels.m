//
//  TTDFModels.m
//  Example
//
//  Created by tianyubing on 2019/9/6.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTDFModels.h"

@implementation TTJSObject

+ (NSDictionary *)createJSObject:(id)__isa className:(NSString *)__className isInstance:(BOOL)__isInstance {
    if ([__isa isKindOfClass:NSString.class]) {
        __className = @"NSString";
    } else if ([__isa isKindOfClass:NSNumber.class]) {
        __className = @"NSNumber";
    } else if ([__isa isKindOfClass:NSDictionary.class] && !__className) {
        __className = @"NSDictionary";
    } else if ([__isa isKindOfClass:NSMutableDictionary.class] && !__className) {
        __className = @"NSMutableDictionary";
    } else if ([__isa isKindOfClass:NSArray.class]) {
        __className = @"NSArray";
    } else if ([__isa isKindOfClass:NSMutableArray.class]) {
        __className = @"NSMutableArray";
    }
    if (__className == nil) {
        __className = NSStringFromClass([__isa class]);
    } else {
    }

    return @{ @"__isa": __isa ?: [NSNull null], @"__className": __className, @"__isInstance": @(__isInstance) };
}

@end

@implementation TTDFKitBlockModel

@end

@implementation TTDFKitConfigModel
+ (TTDFKitConfigModel *)defaultConfig {
    TTDFKitConfigModel *config = [TTDFKitConfigModel new];
    config.isUserNativeData = NO;
    config.isOpenLog = YES;
    return config;
}

@end

@implementation TTMethodList_Node

+ (TTMethodList_Node *)createNodeCls:(NSString *)clsName methodName:(NSString *)methodName isClass:(BOOL)isClass {
    TTMethodList_Node *node = [TTMethodList_Node new];
    node.clsName = clsName;
    node.methodName = methodName;
    node.key = [NSString stringWithFormat:@"%@-%@%@", clsName, methodName, isClass ? @"+" : @"-"];
    node.isClass = isClass;
    return node;
}

@end
