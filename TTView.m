//
//  TTView.m
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTView.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation TTView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.frame = CGRectMake(100, 100, 100, 100);
        self.backgroundColor = [UIColor redColor];
        
        [self class];
        [super class];
        NSLog(@"TTView----->创建成功~~~~~~~~~~~~~~~~~~~~~~~~~");
//        objc_msgSuper
//        objc_msgSendSuper()
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
