//
//  TTDFBlockHelper.m
//  Example
//
//  Created by tianyubing on 2020/8/4.
//  Copyright © 2020 TianyuBing. All rights reserved.
//

#import "TTDFBlockHelper.h"
#import <JavaScriptCore/JavaScriptCore.h>

#import "TTDFEngine.h"
#import "ffi.h"

@interface TTDFBlockHelper () {
    ffi_cif *_cifPtr;
    ffi_type **_args;
    ffi_closure *_closure;
    void *_blockPtr;
    struct TTDFKitBlockDescriptor *_descriptor;
}

@end

@implementation TTDFBlockHelper

void copy_helper(struct TTDFKitBlock *dst, struct TTDFKitBlock *src) {
    // do not copy anything is this function! just retain if need.
    CFRetain(dst->wrapper);
}

void dispose_helper(struct TTDFKitBlock *src) {
    CFRelease(src->wrapper);
}

static void blockIMP(ffi_cif *cif, void *ret, void **args, void *userdata) {
    TTDFBlockHelper *userInfo = (__bridge TTDFBlockHelper *)userdata;  // 不可以进行释放
    NSString *typeEncoding = userInfo.typeEncoding;
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:typeEncoding.UTF8String];
    JSValue *func = userInfo.func;

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 1; i < signature.numberOfArguments; i++) {
        const char *type = [signature getArgumentTypeAtIndex:i];
        id value = [TTDFEngine getParamFromArgs:args argumentType:type index:i];
        [array addObject:value ? value : [NSNull null]];
    }

    if (func) {
        JSValue *value = [func callWithArguments:array];
        if (value && ![value isUndefined]) {
            [TTDFEngine convertReturnValue:[signature methodReturnType] jsValue:value retPointer:ret];
        }
        return;
    }

    return;
}

- (id)initWithTypeEncoding:(NSString *)typeEncoding callbackFunction:(JSValue *)func {
    self = [super init];
    if (self) {
        _typeEncoding = typeEncoding;
        _func = func;
    }
    return self;
}

- (void *)blockPtr {
    NSString *typeEncoding = self.typeEncoding;
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:typeEncoding.UTF8String];
    if (typeEncoding.length <= 0) {
        return nil;
    }
    // 第一个参数是自身block的参数
    unsigned int argCount = (unsigned int)signature.numberOfArguments;
    void *imp = NULL;
    _cifPtr = malloc(sizeof(ffi_cif));  //不可以free
    _closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&imp);
    ffi_type *returnType = (ffi_type *)[TTDFEngine typeEncodingToFfiType:signature.methodReturnType];
    _args = malloc(sizeof(ffi_type *) * argCount);
    _args[0] = &ffi_type_pointer;

    for (int i = 1; i < argCount; i++) {
        _args[i] = (ffi_type *)[TTDFEngine typeEncodingToFfiType:[signature getArgumentTypeAtIndex:i]];
    }

    if (ffi_prep_cif(_cifPtr, FFI_DEFAULT_ABI, argCount, returnType, _args) == FFI_OK) {
        if (ffi_prep_closure_loc(_closure, _cifPtr, blockIMP, (__bridge void *)self, imp) != FFI_OK) {
            NSAssert(NO, @"block 生成失败");
        }
    }

    struct TTDFKitBlockDescriptor descriptor
        = { 0, sizeof(struct TTDFKitBlock), (void (*)(void *dst, const void *src))copy_helper, (void (*)(const void *src))dispose_helper, nil };

    _descriptor = malloc(sizeof(struct TTDFKitBlockDescriptor));
    memcpy(_descriptor, &descriptor, sizeof(struct TTDFKitBlockDescriptor));

    struct TTDFKitBlock newBlock
        = { &_NSConcreteStackBlock, (TTDFKit_BLOCK_HAS_COPY_DISPOSE | TTDFKit_BLOCK_HAS_SIGNATURE), 0, imp, _descriptor, (__bridge void *)self };

    _blockPtr = Block_copy(&newBlock);
    CFRelease(&descriptor);
    CFRelease(&newBlock);
    return _blockPtr;
}

- (void)dealloc {
    ffi_closure_free(_closure);
    free(_args);
    free(_cifPtr);
    free(_descriptor);
}
@end
