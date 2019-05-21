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

#define guard(condfion) if(condfion){}
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,ttprotocol>

@property(nonatomic,strong)UITableView *tableview;
@property(nonatomic,strong)NSMutableArray *watchDogs;
@property(nonatomic,strong)UIView *cell;
@end

@implementation ViewController


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
- (int)customtableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 250;
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"我是第----------%ld名",indexPath.row];
    if (indexPath.row == 1) {
        self.cell = cell;
    }
    return cell;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    TTView*tview = [[TTView alloc] init];
    tview.delegate = self;
    [tview hello];

    NSString * str = [NSString string];
    [self performSelector:@selector(countA) withObject:nil];
    
    
//    [self addView];
//    [self.view addSubview:self.tableview];
    NSLog(@"--------%d",[self customtableView:self.tableview numberOfRowsInSection:0]);
}


- (void)addView{
    NSLog(@"s原生方法  addView");
}
//
//
//+(void)test{
//    NSLog(@"静态方法");
//}

- (IBAction)execJSCode:(id)sender {
//    [self addView];
    
}


-(void)loadView{
    [super loadView];
    
    [self jsContextInit];
    [self action:nil];
//    NSLog(@"UIViewController : %s", @encode(UIViewController));
//    
//    NSLog(@"CGRect : %s", @encode(CGRect));
//    NSLog(@"CGPoint : %s", @encode(CGPoint));
//    NSLog(@"CGSize : %s", @encode(CGSize));
//    NSLog(@"NSArray*                        : %s", @encode(NSArray*));
//    NSLog(@"NSMutableArray*                 : %s", @encode(NSMutableArray*));
//    NSLog(@"NSDictionary*                   : %s", @encode(NSDictionary*));
//    NSLog(@"NSMutableDictionary*            : %s", @encode(NSMutableDictionary*));
//    
//    NSLog(@"int : %s", @encode(int));
//    
//    NSLog(@"float : %s", @encode(float));
//    
//    NSLog(@"double : %s", @encode(double));
//    
//    NSLog(@"BOOL : %s", @encode(BOOL));
//    
//    NSLog(@"long : %s", @encode(long));
//    
//    NSLog(@"short : %s", @encode(short));
}



- (void)refresh{
    
}



- (void)initJSContxtPath{
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TTPatch" ofType:@"js"];
    NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    [[TTPatch shareInstance] evaluateScript:jsCode withSourceURL:[NSURL URLWithString:@"TTPatch.js"]];
    
    self.watchDogs = [[NSMutableArray alloc] init];
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"JS"];
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:scriptRootPath error:NULL];
    //    [self watchFolder:scriptRootPath mainScriptPath:path];
    
    for (NSString *aPath in contentOfFolder) {
        NSString * fullPath = [scriptRootPath stringByAppendingPathComponent:aPath];
        [self watchFolder:fullPath mainScriptPath:path];
    }
}



- (void)watchFolder:(NSString *)folderPath mainScriptPath:(NSString *)mainScriptPath
{
    SGDirWatchdog *watchDog = [[SGDirWatchdog alloc] initWithPath:folderPath update:^{
        NSLog(@"--------------------\n reload");
//        {
//            NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
//            NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"JS"];
//            NSString *srcPath = [scriptRootPath stringByAppendingPathComponent:@"TTPatch.js"];
//            [self tt_loadScript:srcPath];
//        }
        {
            NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
            NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"JS"];
            NSString *srcPath = [scriptRootPath stringByAppendingPathComponent:@"src.js"];
            
            [self tt_loadScript:srcPath];
        }
     
        [self refresh];
      
    }];
    [watchDog start];
    [self.watchDogs addObject:watchDog];
}

- (void)tt_loadScript:(NSString *)path{
    
    NSString *jsCode = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",[[TTPatch shareInstance] formatterJS:jsCode]);
    [[TTPatch shareInstance] evaluateScript:[[TTPatch shareInstance] formatterJS:jsCode] withSourceURL:[NSURL URLWithString:@"TTPatch.js"]];
}

- (IBAction)action:(id)sender {
    NSString *rootPath = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"rootPath"];
    NSString *scriptRootPath = [rootPath stringByAppendingPathComponent:@"JS"];
    NSString *srcPath = [scriptRootPath stringByAppendingPathComponent:@"src.js"];
    [self tt_loadScript:srcPath];
    
}

- (void)jsContextInit{
    [self initJSContxtPath];
}

-(UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
        _tableview.delegate =self;
        _tableview.dataSource = self;
    }
    return _tableview;
}


@end
