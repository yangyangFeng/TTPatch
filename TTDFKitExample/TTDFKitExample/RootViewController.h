//
//  RootViewController.h
//  TTDFKit
//
//  Created by ty on 2019/6/23.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RootViewController : UIViewController
- (void)loadJSCode;
- (NSString *)jsFileName;
- (void)updateResource:(void(^)(void))callback;
- (void)refresh;
@end

NS_ASSUME_NONNULL_END
