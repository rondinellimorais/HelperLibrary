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

#import <Foundation/Foundation.h>


@interface NSDictionary (ObjectForKeyOverride)

/**
 *  Returns the string validate value associated with a given key.
 *
 *  @param aKey The key for which to return the corresponding value.
 *
 *  @return The value associated with aKey, or nil if no value is associated with aKey.
 */
- (NSString*)stringForKey:(id)aKey;

/**
 *  Returns the integer validate value associated with a given key.
 *
 *  @param aKey The key for which to return the corresponding value.
 *
 *  @return The value associated with aKey, or nil if no value is associated with aKey.
 */
- (NSInteger)integerForkey:(id)aKey;

/**
 *  Returns the boolean validate value associated with a given key.
 *
 *  @param aKey The key for which to return the corresponding value.
 *
 *  @return The value associated with aKey, or nil if no value is associated with aKey.
 */
- (BOOL)booleanForKey:(id)aKey;

/**
 *  Returns the mutable array validate value associated with a given key.
 *
 *  @param aKey The key for which to return the corresponding value.
 *
 *  @return The value associated with aKey, or nil if no value is associated with aKey.
 */
- (NSMutableArray*)mutableArrayForKey:(id)aKey;

/**
 *  Returns the float validate value associated with a given key.
 *
 *  @param aKey The key for which to return the corresponding value.
 *
 *  @return The value associated with aKey, or nil if no value is associated with aKey.
 */
- (CGFloat)floatForKey:(id)aKey;

/**
 *  Returns the double validate value associated with a given key.
 *
 *  @param aKey The key for which to return the corresponding value.
 *
 *  @return The value associated with aKey, or nil if no value is associated with aKey.
 */
- (double)doubleForKey:(id)aKey;

@end
