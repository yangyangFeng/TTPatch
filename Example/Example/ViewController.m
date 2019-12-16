//
//  ViewController.m
//  TTPatch
//
//  Created by ty on 2019/5/17.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "ViewController.h"


#import "TTPatch.h"
#import "TTPatchUtils.h"
#import "TTView.h"
#import "TTTableView.h"
#import "SGDirWatchdog.h"
#define guard(condfion) if(condfion){}
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)TTTableView *tableview;
@property(nonatomic,strong)NSMutableArray *watchDogs;
@property(nonatomic,strong)UITableViewCell *cell;
-(void)params1:(NSString*)params1 params2:(int)params2 params3:(int)params3 params4:(int)params4 params5:(int)params5 params6:(int)params6 params7:(int)params7;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initJSContxtPath];
    [self watch];
    [self loadJSCode];

}


- (void)loadJSCode{}

- (void)initJSContxtPath{
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
    NSString *path = [rootPath stringByAppendingPathComponent:@"../JS/TTPatch.js"];
    NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];

    
    self.watchDogs = [[NSMutableArray alloc] init];
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"../JS/source"];
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:scriptRootPath error:NULL];
    
    
    for (NSString *aPath in contentOfFolder) {
        if ([aPath isEqualToString:@"Demo.js"]) {
            NSString * fullPath = [scriptRootPath stringByAppendingPathComponent:aPath];
            [self watchFolder:fullPath mainScriptPath:path];
        }
    }
    
}

- (void)watch{
    
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"../JS/source"];
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
