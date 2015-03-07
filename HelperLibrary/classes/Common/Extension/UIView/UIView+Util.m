//
//  UIView+ShowBorder.m
//  ConectaCenter
//
//  Created by Rondinelli Morais on 02/07/14.
//  Copyright (c) 2014 Rondinelli Morais. All rights reserved.
//

#import "UIView+Util.h"

@implementation UIView (Util)

- (void)showBorderWithWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor {
    [[self layer] setBorderWidth:borderWidth];
    [[self layer] setBorderColor:borderColor.CGColor];
}

- (void)roundedView:(CGFloat)radius {
    [[self layer] setCornerRadius:radius];
    [[self layer] setMasksToBounds:YES];
}

@end
