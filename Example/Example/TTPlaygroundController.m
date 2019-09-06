//
//  TTPlaygroundController.m
//  TTPatch
//
//  Created by ty on 2019/5/22.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTPlaygroundController.h"
#import "SGDirWatchdog.h"
#import "TTPatch.h"
#import "TTPatchUtils.h"

@interface TTPlaygroundModel : NSObject
@property(nonatomic,strong)NSString *name;
@end

@implementation TTPlaygroundModel



@end

@interface TTPlaygroundController ()
@property(nonatomic,strong)NSMutableArray *watchDogs;
@property(nonatomic,strong)SGDirWatchdog *watchDog;
- (void)params1:(int)params1 params2:(int)params2 params3:(int)params3 params4:(int)params4 params5:(int)params5 params6:(int)params6 params7:(int)params7;
@end

@implementation TTPlaygroundController
-(void)dealloc{
    NSLog(@"dealloc -------- Oc");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initJSContxtPath];
    [self watch];
    [self loadJSCode];
    
}

-(void)params1:(int)params1 params2:(int)params2 params3:(int)params3 params4:(int)params4 params5:(int)params5 params6:(int)params6 params7:(int)params7{
    NSLog(@"---------1,2,3,43,45,6,");
}
- (void)btnDidAction:(id)sender{
    
}
- (void)viewWillAppear:(BOOL)animated{
    [self loadJSCode];
}

- (void)loadJSCode{}

- (void)initJSContxtPath{
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
    NSString *path = [rootPath stringByAppendingPathComponent:@"../JS/TTPatch.js"];
    NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    [[TTPatch shareInstance] clearContext];
    [[TTPatch shareInstance] evaluateScript:jsCode withSourceURL:[NSURL URLWithString:@"TTPatch.js"]];
    
    self.watchDogs = [[NSMutableArray alloc] init];
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"../JS/source"];
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:scriptRootPath error:NULL];


    for (NSString *aPath in contentOfFolder) {
        if ([aPath isEqualToString:@"Playground.js"]) {
            NSString * fullPath = [scriptRootPath stringByAppendingPathComponent:aPath];
            [self watchFolder:fullPath mainScriptPath:path];
        }
    }
    
}

- (void)watch{
    
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"../JS/source"];
    NSString *srcPath = [scriptRootPath stringByAppendingPathComponent:@"Playground.js"];
    
    NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:srcPath] encoding:NSUTF8StringEncoding];

    [[TTPatch shareInstance] evaluateScript:[[TTPatch shareInstance] formatterJS:jsCode] withSourceURL:[NSURL URLWithString:@"Playground.js"]];
    
    [self loadJSCode];
    
}

- (void)watchFolder:(NSString *)folderPath mainScriptPath:(NSString *)mainScriptPath
{
    SGDirWatchdog *watchDog = [[SGDirWatchdog alloc] initWithPath:folderPath update:^{
        NSLog(@"--------------------\n reload");
        [self watch];
    }];
    [watchDog start];
    [self.watchDogs addObject:watchDog];
}

+ (void)testAction:(NSString *)str{
    NSLog(@"--------静态方法测试--------- %@",str);
}
- (void)testAction:(NSString *)str{
    NSLog(@"--------实例方法测试--------- %@",str);
}

- (void)testSuper{
    NSLog(@"[self testSuper]");
}

- (void)invocateTest{
    NSLog(@"开始调用");
    [self testCallVV:^{
        NSLog(@"接受回调");
    }];
    
    [self testCallVID:^(NSString *str) {
        NSLog(@"接受回调 -- %@",str);
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

- (void)testCallVID:(void(^)(NSString *str))call{
    if (call) {
        call(@"arg");
    }else{
        NSLog(@"--------Call 方法未实现---------");
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
    int a = 1;
    id cb = ^void(void *p0) {
        id str = (__bridge id)p0;
        NSLog(@"%@,%d", str,a);
    };
    id cbStr = ^void(NSString *str) {
        NSLog(@"%@,%d", str,a);
    };
    NSLog(@"void --- %@",[cb class]);
    NSLog(@"string --- %@",[cbStr class]);
//    [self callBlock:cbStr]; //it's OK
//    [self callBlock:cb block2:cbStr];
//    [self callBlock:cb];    //it's not OK

    [self configViewSize:CGSizeMake(100, 100)];
    [self configView:[UIView new]];
}

- (void)configViewSize:(CGSize )size{
    
}

- (void)configView:(UIView * )view{
    
}

- (void)callBlock:(void(^)(NSString *str))block{
    
}
- (void)callBlock:(void(^)(NSString *str))block
           block2:(void(^)(NSString *str))block2
{
    
}
@end
