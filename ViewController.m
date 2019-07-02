//
//  ViewController.m
//  TTPatch
//
//  Created by ty on 2019/5/17.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "ViewController.h"
#import "libs/SGDirWatchdog.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "TTPatch/TTPatch.h"
#import "TTPatchUtils.h"
#import <objc/runtime.h>
#import "TTView.h"
#import "TTTableView.h"
#define guard(condfion) if(condfion){}
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,ttprotocol>

@property(nonatomic,strong)TTTableView *tableview;
@property(nonatomic,strong)NSMutableArray *watchDogs;
@property(nonatomic,strong)UITableViewCell *cell;
-(void)params1:(NSString*)params1 params2:(int)params2 params3:(int)params3 params4:(int)params4 params5:(int)params5 params6:(int)params6 params7:(int)params7;
@end

@implementation ViewController

//-(void)dealloc{
//    NSLog(@"dealloc -------- Oc");
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initJSContxtPath];
    [self watch];
    [self loadJSCode];
//    UIImageView *logo = [UIImageView new];
//    [logo setImage:[UIImage imageNamed:@"applelogo"]];
//    UILabel * title = [UILabel new];
//    [title setText:@"Apple"];
//    title.font = [UIFont fontWithName:@"GillSans-UltraBold" size:25];
//    title.textAlignment = 1;
//    title.frame = CGRectMake(0, 0, 0, 0);
//    [self.view addSubview:logo];
//    [self.view addSubview:title];
//    self.view.backgroundColor = [UIColor whiteColor];
//    a.image = [UIImage image]
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self params1:@"string" params2:2 params3:3 params4:4 params5:5 params6:6 params7:7];
}

-(void)params1:(NSString*)params1 params2:(int)params2 params3:(int)params3 params4:(int)params4 params5:(int)params5 params6:(int)params6 params7:(int)params7{
    NSLog(@"---------1,2,3,43,45,6,");
}

- (void)btnDidAction:(id)sender{
    
}
- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)loadJSCode{}

- (void)initJSContxtPath{
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TTPatch" ofType:@"js"];
    NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    [[TTPatch shareInstance] clearContext];
    [[TTPatch shareInstance] evaluateScript:jsCode withSourceURL:[NSURL URLWithString:@"TTPatch.js"]];
    
    self.watchDogs = [[NSMutableArray alloc] init];
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"JS/source"];
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:scriptRootPath error:NULL];
    
    
    for (NSString *aPath in contentOfFolder) {
        NSString * fullPath = [scriptRootPath stringByAppendingPathComponent:aPath];
//        [self watchFolder:fullPath mainScriptPath:path];
    }
    
}

- (void)watch{
    
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"JS/source"];
    NSString *srcPath = [scriptRootPath stringByAppendingPathComponent:@"Demo.js"];
    
    NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:srcPath] encoding:NSUTF8StringEncoding];
    [[TTPatch shareInstance] evaluateScript:[[TTPatch shareInstance] formatterJS:jsCode] withSourceURL:[NSURL URLWithString:@"Demo.js"]];
    
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
//- (TTTableView*)getTableview{
//    _tableview = [[TTTableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
//    _tableview.delegate =self;
//    _tableview.dataSource = self;
//    return _tableview;
//}

@end
