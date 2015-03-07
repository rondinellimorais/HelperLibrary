//
//  Copyright (c) 2012 Rondinelli Morais. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
//  Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSDictionary+ObjectForKeyOverride.h"

@implementation NSDictionary (ObjectForKeyOverride)

- (NSString*)stringForKey:(id)aKey {
    
    id object = [self objectForKey:aKey];
    
    if(![object isEqual:[NSNull null]]){
        return [self objectForKey:aKey];
    } return @"";
}

- (NSInteger)integerForkey:(id)aKey {
    
    id object = [self objectForKey:aKey];
    
    if(![object isEqual:[NSNull null]]){
        return [[self objectForKey:aKey] intValue];
    } return 0;
}

- (BOOL)booleanForKey:(id)aKey {
    
    id object = [self objectForKey:aKey];
    
    if(![object isEqual:[NSNull null]]){
        return [[self objectForKey:aKey] boolValue];
    } return 0;
}

- (NSMutableArray*)mutableArrayForKey:(id)aKey {
    
    id object = [self objectForKey:aKey];
    
    if(![object isEqual:[NSNull null]]){
        return (NSMutableArray*)[self objectForKey:aKey];
    } return nil;
}

- (CGFloat)floatForKey:(id)aKey {
    
    id object = [self objectForKey:aKey];
    
    if(![object isEqual:[NSNull null]]){
        return [[self objectForKey:aKey] floatValue];
    } return 0.0f;
}

- (double)doubleForKey:(id)aKey {
    
    id object = [self objectForKey:aKey];
    
    if(![object isEqual:[NSNull null]]){
        return [[self objectForKey:aKey] doubleValue];
    } return 0.0f;
}

@end
