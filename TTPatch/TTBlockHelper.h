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


@interface TTBlockHelper : NSObject

@end

NS_ASSUME_NONNULL_END
