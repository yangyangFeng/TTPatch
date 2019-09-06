//
//  TTView.m
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTView.h"
@implementation TTView
+ (id)createView{
    NSLog(@"TTView----->工厂方法~~~~~~~~~~~~~~~~~~~~~~~~~");
    return [[TTView alloc] initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        NSLog(@"TTView----->创建成功~~~~~~~~~~~~~~~~~~~~~~~~~");

//        NSObject *a = [NSObject alloc];
//        
//        NSInvocation *invocation = [NSInvocation new];
//        [invocation invoke];
//        id returnValue;
//        void *result;
//        [invocation getReturnValue:&result];
//
//        returnValue = (__bridge id)result;
        
    }
    return self;
}
-(void)dealloc{
    NSLog(@"TTView----->s释放了~~~~~~~~~~~~~~~~~~~~~~~~~");
}

- (void)hello{
    if ([self.delegate respondsToSelector:@selector(customtableView:numberOfRowsInSection:)]) {
        UITableView*tableview=[UITableView new];
        int result = [self.delegate customtableView:tableview numberOfRowsInSection:100];
        NSLog(@"返回时:%ld",result);
    }
}
@end
