//
//  TTPatchModels.h
//  Example
//
//  Created by tianyubing on 2019/9/6.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TTJSObject : NSObject
+ (NSDictionary *)createJSObject:(id)__isa
                       className:(NSString *)__className
                      isInstance:(BOOL)__isInstance;
@end

@interface TTPatchBlockModel : NSObject
@property(nonatomic,copy)id __isa;
@property(nonatomic,strong)NSInvocation *invocation;
@property(nonatomic,strong)NSArray *arguments;

@end

@interface TTPatchConfigModel : NSObject
/**
* 获取默认配置
*/
+ (TTPatchConfigModel*)defaultConfig;


/**
 * default is NO
 */
@property(nonatomic,assign)BOOL isUserNativeData;

/**
 * default is YES
 */
@property(nonatomic,assign)BOOL isOpenLog;
@end

