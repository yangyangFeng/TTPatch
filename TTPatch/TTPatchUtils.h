//
//  TTPatchUtils.h
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
typedef enum {
    // Set to true on blocks that have captures (and thus are not true
    // global blocks) but are known not to escape for various other
    // reasons. For backward compatiblity with old runtimes, whenever
    // BLOCK_IS_NOESCAPE is set, BLOCK_IS_GLOBAL is set too. Copying a
    // non-escaping block returns the original block and releasing such a
    // block is a no-op, which is exactly how global blocks are handled.
    TTPATCH_BLOCK_IS_NOESCAPE      =  (1 << 23),

    TTPATCH_BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    TTPATCH_BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    TTPATCH_BLOCK_IS_GLOBAL =         (1 << 28),
    TTPATCH_BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    TTPATCH_BLOCK_HAS_SIGNATURE =     (1 << 30),
} TTPATCH_BLOCK_FLAGS;


typedef struct TTPatchBlock {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    TTPATCH_BLOCK_FLAGS flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
    unsigned long int reserved;         // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
} *TTPatchBlockRef;

@class JSValue;
extern const struct TTPatchUtils {
    id          (*TTPatchDynamicMethodInvocation)           (id classOrInstance,BOOL isSuper,BOOL isInstance,NSString *method, NSArray *arguments);
    id          (*TTPatchDynamicBlock)                      (id block,NSArray *arguments);
    id          (*TTDynamicBlockWithInvocation)             (id block,NSInvocation *invocation);
    char *      (*TTPatchGetMethodTypes)                    (NSString *method,NSArray *arguments);
    NSString *  (*TTPatchMethodFormatterToOcFunc)           (NSString *method);
//    id          (*TTPatchToJsObject)                        (id returnValue);
    NSString *  (*TTPatchMethodFormatterToJSFunc)           (NSString *method);
    Method      (*TTPatchGetInstanceOrClassMethodInfo)      (Class aClass,SEL aSel);
    
} TTPatchUtils;

@interface TTPatchBlockModel : NSObject
@property(nonatomic,strong)id __isa;
@property(nonatomic,strong)NSInvocation *invocation;
@property(nonatomic,strong)NSArray *arguments;
- (void)invote;
@end


@interface TTJSObject : NSObject
+ (NSDictionary *)createJSObject:(id)__isa
                       className:(NSString *)__className
                      isInstance:(BOOL)__isInstance;
@end

static id ToJsObject(id returnValue,NSString *clsName){
    if (returnValue) {
        return [TTJSObject createJSObject:returnValue className:clsName isInstance:YES];;
    }
    return [TTJSObject createJSObject:nil className:clsName isInstance:NO];;
}

static NSDictionary* CGPointToJSObject(CGPoint point){
    return @{@"x":@(point.x),
             @"y":@(point.y)
             };
}

static NSDictionary* CGSizeToJSObject(CGSize size){
    return @{@"width":@(size.width),
             @"height":@(size.height)
             };
}

static NSDictionary* CGReactToJSObject(CGRect react){
    NSMutableDictionary *reactDic = [NSMutableDictionary dictionaryWithDictionary:CGPointToJSObject(react.origin)];
    [reactDic setDictionary:CGSizeToJSObject(react.size)];
    return reactDic;
}


static NSDictionary* UIEdgeInsetsToJSObject(UIEdgeInsets edge){
    return @{@"top":@(edge.top),
             @"left":@(edge.left),
             @"bottom":@(edge.bottom),
             @"right":@(edge.right)
             };
}

static
