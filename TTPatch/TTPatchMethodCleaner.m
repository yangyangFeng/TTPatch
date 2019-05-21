//
//  TTPatchMethodCleaner.m
//  TTPatch
//
//  Created by ty on 2019/5/18.
//  Copyright © 2019 TianyuBing. All rights reserved.
//

#import "TTPatchMethodCleaner.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "TTContext.h"
#import "TTPatch.h"
#define guard(condfion) if(condfion){}
@implementation TTPatchMethodCleaner

+ (void)clean{
    [self cleanClass:nil];
    [[TTPatch shareInstance].context.replaceMethodMap removeAllObjects];
}

+ (void)cleanClass:(NSString *)className{
    NSDictionary *methodsDict = [TTPatch shareInstance].context.replaceMethodMap;
    for (TTMethodList_Node * node in methodsDict.allValues) {
        Class cls = NSClassFromString(node.clsName);
        guard(cls) else {continue;}
        
        NSString *selectorName = node.methodName;
        NSString *originalSelectorName = [NSString stringWithFormat:@"%@%@", TTPatchChangeMethodPrefix, selectorName];
        
        SEL selector = NSSelectorFromString(selectorName);
        SEL originalSelector = NSSelectorFromString(originalSelectorName);
        IMP originalImp = class_respondsToSelector(cls, originalSelector) ? class_getMethodImplementation(cls, originalSelector) : NULL;
        
        Method method;
        if (node.isClass) {
            method = class_getClassMethod(cls, originalSelector);
        }else{
            method = class_getInstanceMethod(cls, originalSelector);
        }
        guard(method) else{continue;}
        char *typeDescription = (char *)method_getTypeEncoding(method);
        class_replaceMethod(cls, selector, originalImp, typeDescription);


    }
}
@end
