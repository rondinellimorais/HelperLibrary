//
//  UIView+ShowBorder.h
//  ConectaCenter
//
//  Created by Rondinelli Morais on 02/07/14.
//  Copyright (c) 2014 Rondinelli Morais. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Util)

- (void)showBorderWithWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;
- (void)roundedView:(CGFloat)radius;

@end
