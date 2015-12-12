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

/**
 *  `DownloadManager` is a class to manage cached files
 */
@interface DownloadManager : NSObject

///---------------------------------------------
/// @name Propertiers
///---------------------------------------------

/**
 * Directory where the images are stored
 */
@property (nonatomic, retain) NSString * cacheDirectory;

// ------------------------------------------------------------------------
// Public static methods
// ------------------------------------------------------------------------
#pragma mark - Public static methods

/**
 *  Create `DownloadManager` shared instance
 *
 *  @return A shared instance valid of the `DownloadManager`
 */
+ (id)sharedInstance;

// ------------------------------------------------------------------------
// Public instance methods
// ------------------------------------------------------------------------
#pragma mark - Public instance methods

/**
 *  Recovery the image saved in cache, if image not exists, download the image.
 *
 *  @param imageURL      The URL valid of image
 *  @param completeBlock If the image exists in cache, return the image, if not exists, return the image after download, nil if download not 
 *                       complete with success
 */
- (void)imageWithURL:(NSURL*)imageURL completeBlock:(void(^)(UIImage*image))completeBlock;


/**
 * Save the image in cache
 *
 * @param imageURL      The URL valid of image
 * @param imageData     Data of image to be stored
 *
 * @discussion Use this method if you are using some image upload API (eg: Cloudinary, Imgur, Flickr, etc.), 
 * where you have the URL of the image and the image discarding the need to download.
 */
- (BOOL)saveImageWithURL:(NSURL*)imageURL imageData:(NSData*)imageData;

@end
