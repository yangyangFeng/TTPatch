//
//  TTDFEngine.h
//  Pods-Example
//
//  Created by tianyubing on 2020/7/29.
//

#import <Foundation/Foundation.h>

#import "ffi.h"
NS_ASSUME_NONNULL_BEGIN

extern NSString *_Nonnull const TTDFKitChangeMethodPrefix;
extern NSString *_Nonnull const kMessageQueue_oc_define;
extern NSString *_Nonnull const kMessageQueue_oc_sendMsg;
extern NSString *_Nonnull const kMessageQueue_oc_block;
extern NSString *_Nonnull const kMessageQueue_oc_replaceMethod;
extern NSString *_Nonnull const kMessageQueue_oc_replaceDynamicMethod;
extern NSString *_Nonnull const kMessageQueue_oc_addPropertys;
extern NSString *_Nonnull const kMessageQueue_oc_genBlock;
extern NSString *_Nonnull const kAPP_IsDebug;
extern NSString *_Nonnull const kUtils_Log;

@class JSValue,TTDFKitBlockModel;

//@class ffi_type;
/// JS上下文与Native交互 核心管理类
@interface TTDFEngine : NSObject
+ (id)defineClass:(NSString *)interface;

+ (id)dynamicMethodInvocation:(id)classOrInstance
                      isSuper:(BOOL)isSuper
                      isBlock:(BOOL)isBlock
                       method:(NSString *)method
                    arguments:(NSArray *)arguments;

+ (NSInvocation*)dynamicBlock:(TTDFKitBlockModel *)blockModel
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

+ (id)GetParamFromArgs:(void **)args
          argumentType:(const char *)argumentType
                 index:(int)index;

+ (void)ConvertReturnValue:(const char *)methodSignature
                   jsValue:(JSValue *)jsValue
                retPointer:(void *)retPointer;

+ (id)GenJsBlockSignature:(NSString *)signature
                    block:(JSValue *)block;

+ (ffi_type *)typeEncodingToFfiType:(const char *)typeEncoding;

+ (NSMutableDictionary *)getReplaceMethodMap;
@end
NS_ASSUME_NONNULL_END
