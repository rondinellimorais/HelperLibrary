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

#import "DownloadManager.h"

@interface DownloadManager ()

@end

@implementation DownloadManager

// ------------------------------------------------------------------------
// Public static methods
// ------------------------------------------------------------------------
#pragma mark - Public static methods

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cacheDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/Images"];
    }
    return self;
}

+ (id)sharedInstance {
    static dispatch_once_t once;
    static DownloadManager *sharedInstance = nil;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// ------------------------------------------------------------------------
// Public instance methods
// ------------------------------------------------------------------------
#pragma mark - Public instance methods

- (void)imageWithURL:(NSURL*)imageURL completeBlock:(void(^)(UIImage*image))completeBlock {
    
    // return file if exists
    NSString *fullPath = [self.cacheDirectory stringByAppendingPathComponent:[imageURL path]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath])
    {
        if(completeBlock){
            UIImage * image = [UIImage imageWithContentsOfFile:fullPath];
            completeBlock(image);
        }
        return;
    }
    
    // downloading if not exists
    NSString *fileName = [imageURL lastPathComponent];
    NSString *fullPathFile = [[imageURL path] stringByDeletingLastPathComponent];
    
    NSString *directory = [self.cacheDirectory stringByAppendingPathComponent:fullPathFile];
    
    // create directory
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (!error)
    {
        // Go Download file
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            
            NSURLRequest * imageRequest = [NSURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
            
            NSData * imageData = [NSURLConnection sendSynchronousRequest:imageRequest returningResponse:nil error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                if(imageData)
                {
                    [imageData writeToFile:[NSString stringWithFormat:@"%@/%@", directory, fileName] atomically:YES];
                    
                    if(completeBlock){
                        UIImage * imageSaved = [UIImage imageWithData:imageData];
                        completeBlock(imageSaved);
                    }
                }
                else
                    if(completeBlock)completeBlock(nil);
            });
        });
        
    }
    
    // error
    else if(completeBlock)completeBlock(nil);
}


- (BOOL)saveImageWithURL:(NSURL*)imageURL imageData:(NSData*)imageData {
    
    NSAssert(imageData!=nil, @"imageData can't be nil");
    
    NSString *fileName = [imageURL lastPathComponent];
    NSString *fullPathFile = [[imageURL path] stringByDeletingLastPathComponent];
    
    NSString *directory = [self.cacheDirectory stringByAppendingPathComponent:fullPathFile];
    
    // create directory
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error == nil) {
        return [imageData writeToFile:[NSString stringWithFormat:@"%@/%@", directory, fileName] atomically:YES];
    }
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), error.localizedDescription);
    return NO;
}

- (BOOL)releaseCacheAtURL:(NSURL*)url {
    
    NSString *fullPathFile = [[url path] stringByDeletingLastPathComponent];
    NSString *directory = [self.cacheDirectory stringByAppendingPathComponent:fullPathFile];
    
    NSError *error = nil;
    if ([[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:directory] error:&error] && error == nil){
        return YES;
    }
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), error.localizedDescription);
    return NO;
}

@end
