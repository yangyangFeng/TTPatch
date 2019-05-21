//
//  TTView.h
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ttprotocol <NSObject>

- (int)customtableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@end
@interface TTView : UIView
@property(nonatomic,assign)id<ttprotocol> delegate;
- (void)hello;
@end

NS_ASSUME_NONNULL_END
