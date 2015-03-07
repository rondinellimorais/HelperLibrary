//
//  UIImage+Utilities.h
//  FoodFlow
//
//  Created by Kishikawa Katsumi on 11/09/05.
//  Copyright (c) 2011 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(Utilities)

- (CGRect)convertCropRect:(CGRect)cropRect;
- (UIImage *)croppedImage:(CGRect)cropRect;
- (UIImage *)resizedImage:(CGSize)size imageOrientation:(UIImageOrientation)imageOrientation;
- (UIImage *)imageScaledToFitSize:(CGSize)size imageOrientation:(UIImageOrientation)imageOrientation;

@end
