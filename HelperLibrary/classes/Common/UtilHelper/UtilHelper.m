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
#import "UtilHelper.h"
#include <math.h>
#import <sys/xattr.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSData+CommonCrypto.h"
#import "NSData+Base64.h"

@interface UtilHelper ()

@property (nonatomic,retain) Reachability* reachability;
@property (nonatomic, copy) HelperLibraryReachabilityStatusBlock updateReachabilityBlock;

@end

@implementation UtilHelper

// ------------------------------------------------------------------------
// Public instance methods
// ------------------------------------------------------------------------
#pragma mark - Public instance methods

// Monitora a conexao com a internet, notifica seu estado atraves do block
- (Reachability *)internetConnectionNotification:(HelperLibraryReachabilityStatusBlock)updateReachabilityBlock {
    
    self.updateReachabilityBlock = updateReachabilityBlock;
    
    // Register notify
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:)
                                                 name:kReachabilityChangedNotification object:nil];
    
    if (&UIApplicationDidEnterBackgroundNotification && &UIApplicationWillEnterForegroundNotification)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityPause)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityResume)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    
    _reachability = [Reachability reachabilityForInternetConnection];
    if([_reachability startNotifier]){
        [self updateReachabilityNotifity:_reachability isCurrentState:YES];
    }
    return _reachability;
}

- (void)handleNetworkChange:(NSNotification*)notification {
    Reachability* reachability = notification.object;
    [self updateReachabilityNotifity:reachability isCurrentState:NO];
}

- (void)updateReachabilityNotifity:(Reachability *)reachability isCurrentState:(BOOL)isCurrentState {
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    if(self.updateReachabilityBlock){
        self.updateReachabilityBlock(remoteHostStatus, isCurrentState);
    }
}

- (void)reachabilityPause {
    [self.reachability stopNotifier];
}

- (void)reachabilityResume {
    [self.reachability startNotifier];
}

// ------------------------------------------------------------------------
// Public static methods
// ------------------------------------------------------------------------
#pragma mark - Public static methods

+ (id)sharedInstance {
    static dispatch_once_t once;
    static UtilHelper *sharedInstance = nil;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// Converte um número inteiro em distância
+ (NSString*)convertDistanceToString:(int)distance {
    if (distance < 100)
        return [NSString stringWithFormat:@"%g M", roundf(distance)];
    else if (distance < 1000)
        return [NSString stringWithFormat:@"%g M", roundf(distance/5)*5];
    else if (distance < 10000)
        return [NSString stringWithFormat:@"%g KM", roundf(distance/100)/10];
    else
        return [NSString stringWithFormat:@"%g KM", roundf(distance/1000)];
}

// verifica conexao com internet
+ (BOOL)isInternetConnected {

    Reachability * reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    BOOL isConnect = netStatus != NotReachable;
    return isConnect;
}

// Verifica posição do dispositivo
+ (NSString *)stringFromOrientation:(UIDeviceOrientation) orientation {
	
    NSString *orientationString;
	switch (orientation) {
		case UIDeviceOrientationPortrait: 
			orientationString =  @"Portrait"; 
			break;
		case UIDeviceOrientationPortraitUpsideDown: 
			orientationString =  @"Portrait Upside Down"; 
			break;
		case UIDeviceOrientationLandscapeLeft: 
			orientationString =  @"Landscape Left"; 
			break;
		case UIDeviceOrientationLandscapeRight: 
			orientationString =  @"Landscape Right"; 
			break;
		case UIDeviceOrientationFaceUp: 
			orientationString =  @"Face Up"; 
			break;
		case UIDeviceOrientationFaceDown: 
			orientationString =  @"Face Down"; 
			break;
		case UIDeviceOrientationUnknown: 
			orientationString = @"Unknown";
			break;
		default: 
			orientationString = @"Not Known";
			break;
	}
	return orientationString;
}

// Pinta uma determinada imagem
+ (UIImage *)image:(UIImage*)img WithColor:(UIColor *)color {
	
	// begin a new image context, to draw our colored image onto
	UIGraphicsBeginImageContextWithOptions(img.size, NO, [[UIScreen mainScreen] scale]);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode, and the original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
	
	// End
    UIGraphicsEndImageContext();
	
	return coloredImg;	
}

// Retorna a StoryBoard a parti de um identificador
+ (id)storyboardWithIdentifier:(NSString*)identifier {
    
    NSString * storyBoard = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIMainStoryboardFile"];
    return [[UIStoryboard storyboardWithName:storyBoard bundle:nil] instantiateViewControllerWithIdentifier:identifier];
}

// Converte NSData em String (Token push notification)
+ (NSString *)convertTokenToDeviceID:(NSData *)token {
    NSMutableString *deviceID = [NSMutableString string];
    unsigned char *ptr = (unsigned char *)[token bytes];
    
    for (NSInteger i = 0; i < 32; ++i) {
        [deviceID appendString:[NSString stringWithFormat:@"%02x", ptr[i]]];
    }
    return deviceID;
}

// Salva uma imagem no sistema de arquivos
+ (BOOL)saveImage:(NSString*)filePath imagem:(UIImage*)imagem {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager createFileAtPath:filePath contents:UIImageJPEGRepresentation(imagem, [UIScreen mainScreen].scale) attributes:nil];
}

// Faz a união de duas imagens
+ (UIImage*)unionRetinaDisplayImage:(UIImage*)first withImage:(UIImage*)second {
    
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth)/2, MAX(firstHeight, secondHeight)/2);
    
    // capture image context ref
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(mergedSize.width, mergedSize.height*2), NO, [[UIScreen mainScreen] scale]);
    
    
    //Draw images into the context
    [first drawInRect:CGRectMake(0, 0, firstWidth/2, firstHeight/2)];
    [[self roundedRectImageFromImage:second withRadious:2] drawInRect:CGRectMake(2, 2, secondWidth/1.6, secondHeight/1.6)];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}
+ (UIImage*)unionNoRetinaDisplayImage:(UIImage*)first withImage:(UIImage*)second {
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
    
    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef);
    CGFloat secondHeight = CGImageGetHeight(secondImageRef);
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(CGSizeMake(mergedSize.width, mergedSize.height*2));
    
    //Draw images onto the context
    //[first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    //[second drawInRect:CGRectMake(0, (firstHeight), secondWidth, secondHeight)]; 
    [first drawInRect:CGRectMake(0, 0, firstWidth/2, firstHeight/2)];
    [[self roundedRectImageFromImage:second withRadious:2] drawInRect:CGRectMake(2, 2, secondWidth/1.6, secondHeight/1.6)];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}
+ (UIImage*)unionImage:(UIImage*)first withImage:(UIImage*)second {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0) {
        return [self unionRetinaDisplayImage:first withImage:second];
    } else {
        return [self unionNoRetinaDisplayImage:first withImage:second];
    }
}
+ (UIImage *)roundedRectImageFromImage:(UIImage *)image withRadious:(CGFloat)radious {
    
    if(radious == 0.0f)
        return image;
    
    if( image != nil) {
        
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        
        CGRect rect = CGRectMake(0.0f, 0.0f, imageWidth, imageHeight);
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        const CGFloat scale = window.screen.scale;
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextBeginPath(context);
        CGContextSaveGState(context);
        CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM (context, radious, radious);
        
        CGFloat rectWidth = CGRectGetWidth (rect)/radious;
        CGFloat rectHeight = CGRectGetHeight (rect)/radious;
        
        CGContextMoveToPoint(context, rectWidth, rectHeight/2.0f);
        CGContextAddArcToPoint(context, rectWidth, rectHeight, rectWidth/2.0f, rectHeight, radious);
        CGContextAddArcToPoint(context, 0.0f, rectHeight, 0.0f, rectHeight/2.0f, radious);
        CGContextAddArcToPoint(context, 0.0f, 0.0f, rectWidth/2.0f, 0.0f, radious);
        CGContextAddArcToPoint(context, rectWidth, 0.0f, rectWidth, rectHeight/2.0f, radious);
        CGContextRestoreGState(context);
        CGContextClosePath(context);
        CGContextClip(context);
        
        [image drawInRect:CGRectMake(0.0f, 0.0f, imageWidth, imageHeight)];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    return nil;
}

// Marca os arquivos como no-Backup
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

// realiza uma lição
+ (void)call:(NSString*)phoneNumber {
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", phoneNumber]]];
}

// Converte o número JSON (1374202800000) em NSDate
+ (NSDate*)convertJSONDateToNSDateWithLongValue:(long long)interval {
    return [self convertJSONDateToNSDate:[NSString stringWithFormat:@"%lld", interval]];
}

// Converte o número JSON (1374202800000) em NSDate
+ (NSDate*)convertJSONDateToNSDate:(NSString*)jsonDate {
    NSTimeInterval interval = [jsonDate longLongValue]/1000;
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

// Converte NSDate para o formanto JSON (1374202800000)
+ (NSTimeInterval)convertNSDateToJSONDate:(NSDate*)date {
    return [date timeIntervalSince1970]*1000;
}

// Converte string para NSDate
+ (NSDate*)convertNSStringToNSDate:(NSString*)strDate formatterDate:(NSString*)formatterDate{
    
    NSDateFormatter * formatter = [NSDateFormatter new];
    
    //[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-03]];//-03:00
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:formatterDate];
    return [formatter dateFromString:strDate];
}

// Converte NSDate para string
+ (NSString*)convertNSDateToNSString:(NSDate*)date formatterDate:(NSString*)formatterDate {
    
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:formatterDate];
    return [formatter stringFromDate:date];
}

// Trunca a String
+ (NSString*)trunc:(NSString*)str length:(int)length {
    return [str substringToIndex:MIN(length, [str length])];
}

// Retorna apenas os caracteres permitidos em uma String
+ (NSString *)cleanedText:(NSString*)text charactesAllowed:(NSString*)charactesAllowed {
    NSCharacterSet * invertedSet = [[NSCharacterSet characterSetWithCharactersInString:charactesAllowed] invertedSet];
    return [[text componentsSeparatedByCharactersInSet:invertedSet] componentsJoinedByString:@""];
}

// Faz parse de url para dicionário
+ (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

// View para Image
+ (UIImage*)imageWithView:(UIView *)view {
    
    CGSize imageSize = view.bounds.size;
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(imageSize, view.opaque, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage*)screenshotAtView:(UIView*)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    if( [view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)] ){
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    }else{
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // hack, helps w/ our colors when blurring
    NSData *imageData = UIImageJPEGRepresentation(image, 1); // convert to jpeg
    image = [UIImage imageWithData:imageData];
    
    return image;
}

// carrega uma imagem a parti do rolo da camera
+ (void)imageWithALAssetURL:(NSURL*)URL completeBlock:(void (^)(UIImage * resultImage))completeBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:URL
                 resultBlock:^(ALAsset *asset) {
                     ALAssetRepresentation *rep = [asset defaultRepresentation];
                     CGImageRef iref = [rep fullScreenImage];
                     
                     if(iref){
                         
                         UIImage * image = [UIImage imageWithCGImage:iref
                                                               scale:rep.scale
                                                         orientation:UIImageOrientationUp];
                         
                         dispatch_async(dispatch_get_main_queue(), ^(void) {
                             completeBlock(image);
                         });
                     }
                 }
                failureBlock:nil];
    });
}

// retorna a idioma preferencial do usuário na mesma ordem de 'settings'
+ (NSString*)preferredUserLanguage {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * globalDomain = [defaults persistentDomainForName:@"NSGlobalDomain"];
    NSArray * languages = [globalDomain objectForKey:@"AppleLanguages"];
    
    NSString* preferredLang = [languages objectAtIndex:0];
    
    return preferredLang;
}

// converte NSDictionary em string JSON
+ (NSString*)parseDictionaryToJSON:(NSDictionary*)dictionary {
    
    if(!dictionary) return nil;
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

// converte string JSON em NSDictionary
+ (NSDictionary*)parseJSONToDictionary:(NSString*)jsonString {
    
    if(!jsonString) return nil;
    
    return [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                           options:kNilOptions
                                             error:nil];
}

@end
