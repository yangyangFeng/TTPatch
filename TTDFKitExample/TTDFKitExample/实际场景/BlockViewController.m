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


#define data @[@"1.JS替换:noReturnParamsVoid, 无返回/无参 ",\
                @"2.JS替换:noReturnParamsStringInt, 无返回/Str,Int",\
                @"3.JS替换:returnParamsId, 有返回/有参",\
                @"4.JS调用OC:OCNoReturnParams, 有返回/有参",\
                @"5.JS替换:testMoreParams, 多参数&多类型"]

@interface BlockViewController ()

@end

@implementation BlockViewController



- (void)viewDidLoad {
    [super viewDidLoad];
 
    // Do any additional setup after loading the view.
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    msg.text = @"    参数携带block参数请参考例:1~4.\n    常规方法替换请参照[testMoreParams]";
    msg.numberOfLines = 0;
    msg.backgroundColor = [UIColor systemGreenColor];
    msg.textColor = [UIColor whiteColor];
    return msg;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 100;;
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

#pragma mark - 演示代码

- (void)noReturnParamsVoid:(void(^)(void))call{
    if (call) {
        call();
    }
    [self sendMessage:@"1,2,3"];
    [self sendMessageVC:self];
}

- (void)noReturnParamsStringInt:(void(^)(NSString * str,int inta))call{
    if (call) {
        call(@"{\"id\":1,\"name\":\"Tencent\",\"email\":\"admin@Tencent.com\",\"interest\":[\"Tencent\",\"Tencent\"]}",999);
    }
}

- (void)returnParamsId:(NSDictionary *(^)(UIViewController *str))call{
    if (call) {
        NSDictionary *  res = call(self);
        NSLog(@"有参block----%@",res);
    }
}



- (void)testMoreParams:(void(^)(NSString *arg0,NSString *arg1,int arg2,bool arg3, float arg4, NSNumber* arg5))call{
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

- (void)OCNoReturnParams:(void(^)(NSString *str))block{
    
}

- (void)runBlock{
    id cbInt = ^void(NSString *arg) {
        NSLog(@"js方法回调----------%@", arg);
    };
    
    [self OCNoReturnParams:cbInt]; //it's OK
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

- (void)testCall3:(NSString *(^)(void))call{
    if (call) {
        NSLog(@"有参block----%@",call());
    }
}


//- (void)invocateTest{
//    NSLog(@"开始调用");
//    [self testCallVV:^{
//        NSLog(@"接受回调");
//    }];
//
//    [self testCallIDID:^TTPlaygroundModel *(NSString *str) {
//        NSLog(@"接受回调 -- %@",str);
//        TTPlaygroundModel *model = [TTPlaygroundModel new];
//        model.name = @"TTDFKit";
//        return model;
//    }];
//}

@end
