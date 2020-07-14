//
//  TTPatchKit.h
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#ifndef TTPatchKit_h
#define TTPatchKit_h
#define guard(condfion) if(condfion){}

#ifdef DEBUG
#define TTLog(ARGS, ...) NSLog((@"[%s:%d] " ARGS), __FILE__, __LINE__, ##__VA_ARGS__);
#else
#define TTLog(...)
#endif
#define TTLog_Info(ARGS, ...) NSLog((@"[%s:%d] " ARGS), __FILE__, __LINE__, ##__VA_ARGS__);
#define TTLog_Error(ARGS, ...) NSLog((@"[%s:%d][error] " ARGS), __FILE__, __LINE__, ##__VA_ARGS__);
#define TTAssert(con,ARGS, ...) NSAssert(con,(@"[%s:%d][error] " ARGS), __FILE__, __LINE__, ##__VA_ARGS__);

/**
 *日志开关
 */
#define TTPATCH_LOG 0
/**
 * 是否将 String, Number, Dic,Arr 转换成JS 类型,转换后不可再调用Oc方法操作对象.
 */
#define TTPATCH_ProjectConfig_IS_USE_NATIVE_DATA 1

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "TTContext.h"
#import "TTHookUtils.h"
#import "TTPatchMethodCleaner.h"
#import "TTPatchWidget.h"


#endif /* TTPatchKit_h */
