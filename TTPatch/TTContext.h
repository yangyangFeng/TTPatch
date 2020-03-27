//
//  TTContext.h
//  TTPatch
//
//  Created by ty on 2019/5/17.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

extern NSString * _Nonnull const TTPatchChangeMethodPrefix;

NS_ASSUME_NONNULL_BEGIN
@interface TTMethodList_Node : NSObject
@property(nonatomic,copy)NSString *clsName;
@property(nonatomic,copy)NSString *methodName;
@property(nonatomic,copy)NSString *key;
@property(nonatomic,assign)BOOL isClass;
+ (TTMethodList_Node *)createNodeCls:(NSString *)clsName
                          methodName:(NSString *)methodName
                             isClass:(BOOL)isClass;
@end

@interface TTContext : JSContext

- (void)configJSBrigeActions;

- (JSValue *)getBlockFunc;

- (id)execFuncParamsBlockWithBlockKey:(NSString *)key
                            arguments:(NSArray *)arguments;
@property(nonatomic,strong)NSMutableDictionary *replaceMethodMap;
@end

NS_ASSUME_NONNULL_END
