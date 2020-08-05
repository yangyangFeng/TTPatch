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


#define data @[@"JS:block 传入Oc [void:void]",@"JS:block 传入Oc [void:obj]",@"JS:block 传入Oc [obj:obj]",@"JS:block 传入Oc [obj:void]",@"Oc:block 传入JS [void:int]",@"JS:block 传入Oc 多参数&多类型[void:void]"]
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
    [self sendMessage:@"1,2,3"];
    [self sendMessageVC:self];
}

- (void)testCall1:(void(^)(NSString * str,int inta))call{
    if (call) {
        call(@"{\"id\":1,\"name\":\"Tencent\",\"email\":\"admin@Tencent.com\",\"interest\":[\"Tencent\",\"Tencent\"]}",999);
    }
}

- (void)testCall2:(NSDictionary *(^)(UIViewController *str))call{
    if (call) {
//        NSLog(@"有参block----%@",);
        NSDictionary *  res = call(self);
                NSLog(@"有参block----%@",res);
//        call(@"安居客");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [res.view setBackgroundColor:[UIColor systemGreenColor]];
        });
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

- (void)testCallVID:(void(^)(NSString *arg0,NSString *arg1,int arg2,bool arg3, float arg4, NSNumber* arg5))call{
    if (call) {
        call(@"arg0",@"arg1 ",24,NO,1.99,@(58));
    }else{
        NSLog(@"--------Call 方法未实现---------");
    }
}


- (void)OCcallBlock:(void(^)(NSString *str))block{
    if (block) {
        block(@"第二个block");
    }
}

- (void)testCallIDID:(TTPlaygroundModel *(^)(NSString *str))call{
    if (call) {
        NSLog(@"block返回值-- %@",call(@"{\"id\":1,\"name\":\"jb51\",\"email\":\"admin@jb51.net\",\"interest\":[\"wordpress\",\"php\"]}"));
    }else{
        NSLog(@"--------Call 方法未实现---------");
    }
}

- (void)callBlock:(void(^)(NSString *str))block{
}

- (void)runBlock{

    id cbInt = ^void(int arg) {
        NSLog(@"js方法回调----------%d", arg);
    };

    [self callBlock:cbInt]; //it's OK
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
