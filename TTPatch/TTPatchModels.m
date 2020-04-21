//
//  TTPatchModels.m
//  Example
//
//  Created by tianyubing on 2019/9/6.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTPatchModels.h"


@implementation TTJSObject

+ (NSDictionary *)createJSObject:(id)__isa
                       className:(NSString *)__className
                      isInstance:(BOOL)__isInstance{

    if ([__isa isKindOfClass:NSString.class]) {
        __className=@"NSString";
    }else if ([__isa isKindOfClass:NSNumber.class]){
        __className=@"NSNumber";
    }
    else if ([__isa isKindOfClass:NSDictionary.class] && !__className){
        __className=@"NSDictionary";
    }
    else if ([__isa isKindOfClass:NSMutableDictionary.class] && !__className){
        __className=@"NSMutableDictionary";
    }else if ([__isa isKindOfClass:NSArray.class]){
        __className=@"NSArray";
    }
    else if ([__isa isKindOfClass:NSMutableArray.class]){
        __className=@"NSMutableArray";
    }
    NSLog(@"className:%@ ISA:%@",__className,__isa);
    if (__className==nil) {
        __className = NSStringFromClass([__isa class]);
    }else{
        
    }
    
    return @{@"__isa":__isa?:[NSNull null],
             @"__className":__className,
             @"__isInstance":@(__isInstance)
             };
}

@end

@implementation TTPatchBlockModel

-(void)dealloc{
    NSLog(@"%@----dealloc",self);
}
@end

@implementation TTPatchConfigModel
+ (TTPatchConfigModel*)defaultConfig{
    TTPatchConfigModel *config = [TTPatchConfigModel new];
    config.isUserNativeData = NO;
    config.isOpenLog = YES;
    return config;
}

@end


