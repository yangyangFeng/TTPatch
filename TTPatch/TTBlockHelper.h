//
//  TTBlockHelper.h
//  Example
//
//  Created by tianyubing on 2020/8/4.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    log_level_debug=1,
    log_level_info,
    log_level_error,
} log_level;

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


struct TTPatchBlock {
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    struct TTPatchBlockDescriptor *descriptor;
    void *wrapper;
};

struct TTPatchBlockDescriptor {
    //Block_descriptor_1
    struct {
        unsigned long int reserved;
        unsigned long int size;
    };

    //Block_descriptor_2
    struct {
        // requires BLOCK_HAS_COPY_DISPOSE
        void (*copy)(void *dst, const void *src);

        void (*dispose)(const void *);
    };

    //Block_descriptor_3
    struct {
        // requires BLOCK_HAS_SIGNATURE
        const char *signature;
    };
};


@class JSValue;
@interface TTBlockHelper : NSObject
- (id)initWithTypeEncoding:(NSString *)typeEncoding func:(JSValue *)func;

- (void *)block;

@property (nonatomic, copy) NSString *typeEncoding;
@property (nonatomic, strong) JSValue *func;
@end

NS_ASSUME_NONNULL_END
