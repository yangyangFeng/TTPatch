//
//  TTEngine.h
//  Pods-Example
//
//  Created by tianyubing on 2020/7/29.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

#import "TTPatchModels.h"
#import "TTPatch.h"
#import "TTPatchKit.h"

NS_ASSUME_NONNULL_BEGIN

#define guard(condfion) if(condfion){}
#define TTPATCH_DERIVE_PRE @"TTPatch_Derive_"
#define TTPatchInvocationException @"TTPatchInvocationException"

#pragma mark - 函数声明
static NSString *CreateSignatureWithString(NSString *signatureStr, bool isBlock);
static void OC_MSG_SEND_HANDLE(__unsafe_unretained NSObject *self, SEL invocation_selector, NSInvocation *invocation);
static void HookClassMethodWithSignature(NSString *className,NSString *superClassName,NSString *method,BOOL isInstanceMethod,NSArray *propertys,NSString *signature);
static id CreateBlockWithSignatureString(NSString *signatureStr);

static CGRect toOcCGReact(NSString *jsObjValue){

    if (jsObjValue) {
        return CGRectFromString(jsObjValue);
    }
    return CGRectZero;
}

static CGPoint toOcCGPoint(NSString *jsObjValue){
    if (jsObjValue){
        return CGPointFromString(jsObjValue);
    }
    return CGPointZero;
}

static CGSize toOcCGSize(NSString *jsObjValue){
    if (jsObjValue) {
        return CGSizeFromString(jsObjValue);
    }
    return CGSizeZero;
}

static NSMethodSignature *block_methodSignatureForSelector(id self, SEL _cmd, SEL aSelector) {
    
    uint8_t *p = (uint8_t *)((__bridge void *)self);
    p += sizeof(void *) * 2 + sizeof(int32_t) *2 + sizeof(uintptr_t) * 2;
    const char **signature = (const char **)p;
    
    return [NSMethodSignature signatureWithObjCTypes:*signature];
}


@interface TTEngine : NSObject
+ (id)dynamicMethodInvocation:(id)classOrInstance
                      isSuper:(BOOL)isSuper
                      isBlock:(BOOL)isBlock
                       method:(NSString *)method
                    arguments:(NSArray *)arguments;

+ (NSInvocation*)dynamicBlock:(TTPatchBlockModel *)blockModel
                    arguments:(NSArray *)arguments
             custom_signature:(NSString*)custom_signature;

+ (void)hookClassMethod:(NSString *)className
         superClassName:(NSString *)superClassName
                 method:(NSString *)method
       isInstanceMethod:(BOOL)isInstanceMethod
              propertys:(NSArray *)propertys;

+ (void)hookClassMethodWithSignature:(NSString *)className
                      superClassName:(NSString *)superClassName
                              method:(NSString *)method
                    isInstanceMethod:(BOOL)isInstanceMethod
                           propertys:(NSArray *)propertys
                           signature:(NSString *)signature;

+ (void)addPropertys:(NSString *)className
      superClassName:(NSString *)superClassName
           propertys:(NSArray *)propertys;

+ (NSMutableDictionary *)getReplaceMethodMap;
@end

NS_ASSUME_NONNULL_END

