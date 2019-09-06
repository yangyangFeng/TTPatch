//
//  main.m
//  Example
//
//  Created by ty on 2019/7/2.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
typedef void(^MyBlock)(void);
int main(int argc, char * argv[]) {
    @autoreleasepool {
        
    
                    MyBlock block1 = ^{
                    };
                    block1();
        
        
           __block int a = 10;
                MyBlock block2 = ^{
                    a = 20;
                    NSLog(@"a --- %d",a);
                };
                block2();

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
