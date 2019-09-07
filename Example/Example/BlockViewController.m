//
//  BlockViewController.m
//  Example
//
//  Created by tianyubing on 2019/9/7.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "BlockViewController.h"
@interface TTPlaygroundModel : NSObject
@property(nonatomic,strong)NSString *name;
@end

@implementation TTPlaygroundModel



@end


#define data @[@"block-返回值void,入参void",@"block-返回值void,入参id",@"block-返回值id,入参id",@"block-返回值id,入参id",@"block-js调用OC传入block",@"同一js方法多次调用OC-block方法"]
@interface BlockViewController ()

@end

@implementation BlockViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
    cell.textLabel.text = data[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self btnAction:(int)indexPath.row];
}


- (void)testCall0:(void(^)(void))call{
    if (call) {
        call();
    }
}

- (void)testCall1:(void(^)(NSString *str))call{
    if (call) {
        call(@"58同城");
    }
}

- (void)testCall2:(NSString *(^)(NSString *str))call{
    if (call) {
        NSLog(@"有参block----%@",call(@"安居客"));
//        call(@"安居客");
    }
}

- (void)testCall3:(NSString *(^)(void))call{
    if (call) {
          NSLog(@"有参block----%@",call());
      }
}


- (void)invocateTest{
    NSLog(@"开始调用");
    [self testCallVV:^{
        NSLog(@"接受回调");
    }];
    
//    [self testCallVID:^(NSString *str) {
//        NSLog(@"接受回调 -- %@",str);
//    }];
    
    [self testCallIDID:^TTPlaygroundModel *(NSString *str) {
        NSLog(@"接受回调 -- %@",str);
        TTPlaygroundModel *model = [TTPlaygroundModel new];
        model.name = @"TTPatch";
        return model;
    }];
}


- (void)testCallVV:(void(^)(void))call{
    if (call) {
        call();
    }else{
        NSLog(@"--------Call 方法未实现---------");
    }
}

- (void)testCallVID:(void(^)(NSString *str,NSString *str2))call{
    if (call) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            call(@"arg",@"arg2");
        });
    }else{
        NSLog(@"--------Call 方法未实现---------");
    }
}

- (void)callBlock:(void(^)(NSString *str))block{
}

- (void)OCcallBlock:(void(^)(NSString *str))block{
    if (block) {
        block(@"第二个block");
    }
}

- (void)testCallIDID:(TTPlaygroundModel *(^)(NSString *str))call{
    if (call) {
        NSLog(@"block返回值-- %@",call(@"arg IDID"));
    }else{
        NSLog(@"--------Call 方法未实现---------");
    }
}

- (void)runBlock{
    id cb = ^void(void *p0) {
        id str = (__bridge id)p0;
        NSLog(@"%@,%d", str);
    };
    id cbStr = ^void(NSString *str) {
        NSLog(@"js方法回调----------%@,%d", str);
    };
    [self callBlock:cbStr]; //it's OK
//    [self callBlock:cb];    //it's not OK
}

- (void)configViewSize:(CGSize )size{
    
}

- (void)configView:(UIView * )view{
    
}


- (void)callBlock:(void(^)(NSString *str))block
           block2:(void(^)(NSString *str))block2
{
    
}

- (void)btnAction:(int)index{

}
@end
