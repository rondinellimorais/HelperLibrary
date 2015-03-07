//
//  NSObject+Util.m
//  HelperLibrary
//
//  Created by Rondinelli Morais on 13/08/14.
//  Copyright (c) 2014 Rondinelli Morais. All rights reserved.
//

#import "NSObject+Util.h"
#import <objc/runtime.h>

@implementation NSObject (Util)

// ------------------------------------------------------------------------
// Plublic Property
// ------------------------------------------------------------------------
#pragma mark - Plublic Property
- (BOOL)implementsSelector:(SEL)aSelector {
    Method          *methods;
    unsigned int    count;
    unsigned int    i;
    
    methods = class_copyMethodList([self class], &count);
    BOOL implementsSelector = NO;
    for (i = 0; i < count; i++) {
        if (sel_isEqual(method_getName(methods[i]), aSelector)) {
            implementsSelector = YES;
            break;
        }
    }
    free(methods);
    return implementsSelector;
}

@end
