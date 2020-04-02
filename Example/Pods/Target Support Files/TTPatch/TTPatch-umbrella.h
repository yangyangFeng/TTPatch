#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TTContext.h"
#import "TTPatch.h"
#import "TTPatchKit.h"
#import "TTPatchMethodCleaner.h"
#import "TTPatchModels.h"
#import "TTPatchUtils.h"

FOUNDATION_EXPORT double TTPatchVersionNumber;
FOUNDATION_EXPORT const unsigned char TTPatchVersionString[];

