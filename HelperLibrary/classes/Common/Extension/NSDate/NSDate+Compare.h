//
//  NSDate+Compare.h
//  NSDate+Calendar
//
//  Created by Alexey Belkevich on 9/10/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Compare)

- (BOOL)isLessDate:(NSDate *)date;
- (BOOL)isGreaterDate:(NSDate *)date;
- (BOOL)isLessOrEqualToDate:(NSDate *)date;
- (BOOL)isGreaterOrEqualToDate:(NSDate *)date;

@end
