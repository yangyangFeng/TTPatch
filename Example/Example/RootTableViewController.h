//
//  RootTableViewController.h
//  Example
//
//  Created by tianyubing on 2020/4/3.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RootTableViewController : UITableViewController
- (void)loadJSCode;
- (NSString *)jsFileName;
- (void)updateResource:(void(^)(void))callback;
- (void)refresh;
@end

NS_ASSUME_NONNULL_END
