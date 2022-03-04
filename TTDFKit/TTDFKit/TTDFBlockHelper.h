//
//  TTDFBlockHelper.h
//  Example
//
//  Created by tianyubing on 2020/8/4.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    // Set to true on blocks that have captures (and thus are not true
    // global blocks) but are known not to escape for various other
    // reasons. For backward compatiblity with old runtimes, whenever
    // BLOCK_IS_NOESCAPE is set, BLOCK_IS_GLOBAL is set too. Copying a
    // non-escaping block returns the original block and releasing such a
    // block is a no-op, which is exactly how global blocks are handled.
    TTDFKit_BLOCK_IS_NOESCAPE = (1 << 23),
    TTDFKit_BLOCK_HAS_COPY_DISPOSE = (1 << 25),
    TTDFKit_BLOCK_HAS_CTOR = (1 << 26),  // helpers have C++ code
    TTDFKit_BLOCK_IS_GLOBAL = (1 << 28),
    TTDFKit_BLOCK_HAS_STRET = (1 << 29),  // IFF BLOCK_HAS_SIGNATURE
    TTDFKit_BLOCK_HAS_SIGNATURE = (1 << 30),
} TTDFKit_BLOCK_FLAGS;

struct TTDFKitBlock {
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    struct TTDFKitBlockDescriptor *descriptor;
    void *wrapper;
};

struct TTDFKitBlockDescriptor {
    struct {
        unsigned long int reserved;
        unsigned long int size;
    };
    struct {
        // requires BLOCK_HAS_COPY_DISPOSE
        void (*copy)(void *dst, const void *src);
        void (*dispose)(const void *);
    };
    struct {
        // requires BLOCK_HAS_SIGNATURE
        const char *signature;
    };
};

@class JSValue;
@interface TTDFBlockHelper : NSObject
@property (nonatomic, copy) NSString *typeEncoding;
@property (nonatomic, strong) JSValue *func;

- (id)initWithTypeEncoding:(NSString *)typeEncoding callbackFunction:(JSValue *)func;
- (void *)blockPtr;
@end

NS_ASSUME_NONNULL_END
