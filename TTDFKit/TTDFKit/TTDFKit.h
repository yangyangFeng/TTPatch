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

#define TTLog(ARGS, ...) NSLog((@"[%s:%d] " ARGS), __FILE__, __LINE__, ##__VA_ARGS__);
#define TTLog_Info(ARGS, ...) NSLog((@"[%s:%d] " ARGS), __FILE__, __LINE__, ##__VA_ARGS__);
#define TTLog_Error(ARGS, ...) NSLog((@"[%s:%d][error] " ARGS), __FILE__, __LINE__, ##__VA_ARGS__);
#define TTAssert(con,ARGS, ...) NSAssert(con,(@"[%s:%d][error] " ARGS), __FILE__, __LINE__, ##__VA_ARGS__);


#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "TTDFEntry.h"
#import "TTDFEngine.h"
#import "TTContext.h"
#import "TTDFUtils.h"
#import "TTDFModels.h"
#import "TTDFBlockHelper.h"
#import "TTDFMethodCleaner.h"

#endif /* TTDFKitKit_h */
