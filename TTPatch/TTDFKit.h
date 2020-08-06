//
//  TTDFKitKit.h
//  TTDFKit
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#ifndef TTDFKitKit_h
#define TTDFKitKit_h
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
#define TTDFKit_LOG 1

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "TTContext.h"
#import "TTDFUtils.h"
#import "TTDFMethodCleaner.h"
#import "TTDFWidget.h"
#import "TTDFModels.h"
#import "TTDFEngine.h"

#endif /* TTDFKitKit_h */
