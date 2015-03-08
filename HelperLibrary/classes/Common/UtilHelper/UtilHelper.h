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

#import "Reachability.h"

///------------------------------------------
/// @name UtilHelper: Public static Functions
///------------------------------------------

/**
 *  Convert the RGB code to UIColor object
 *
 *  @param r Red color code (0 - 255)
 *  @param g Green color code (0 - 255)
 *  @param b Blue color code (0 - 255)
 *  @param a Alpha value (0.0 - 1.0)
 *
 *  @return UIColor object converted
 */
inline static UIColor* rgba(CGFloat r, CGFloat g, CGFloat b, CGFloat a){
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
};

/**
 *  Convert the RGB code to UIColor object
 *
 *  @param r Red color code (0 - 255)
 *  @param g Green color code (0 - 255)
 *  @param b Blue color code (0 - 255)
 *
 *  @return UIColor object converted
 */
inline static UIColor* rgb(CGFloat r, CGFloat g, CGFloat b){
    return rgba(r, g, b, 1.f);
};

/**
 *  Check if text contains a another text
 *
 *  @param str1 target text
 *  @param str2 text for search in target text
 *
 *  @return YES, if str2 contains within str1. Otherwise NO
 */
inline static BOOL contains(NSString * str1, NSString * str2){
    return ([str1 rangeOfString: str2 ].location != NSNotFound);
};

/**
 *  Uses the same logic in SQL COALESCE, replaces str1 by str2 where str1 is null or empty
 *
 *  @param str1 target string
 *  @param str2 another string for replace when str1 is nil or empty
 *
 *  @return a new string validated
 */
inline static NSString* coalesce(NSString * str1, NSString * str2){
    return ((!str1 || str1.length == 0) ? str2 : str1);
};

/**
 *  Private directory is a hidden directory within `NSDocumentDirectory`.
 *  Use this directory for save files that the user cannot see when File Sharing on iTunes is enable.
 *
 *  @return A private hidden directory
 */
inline static NSString* privateDirectory() {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // create a private directory, this directory is hidden
    NSString * privateDirectory = [documentsDirectory stringByAppendingPathComponent:@".Private"];
    
    NSFileManager * f = [NSFileManager defaultManager];
    
    NSError *error = nil;
    BOOL success = [f createDirectoryAtPath:privateDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    if(success && !error)
        return privateDirectory;
    return nil;
}

/**
 *  Calcule the height of the text
 *
 *  @param text          The text target
 *  @param font          The font of the text target
 *  @param maxSize       The max of size os the label view
 *  @param lineBreakMode These constants specify what happens when a line is too long for its container. See more `NSLineBreakMode`
 *  @param isMultiLine   Says if the calculation is based on single line or multi line
 *
 *  @return The Height of text
 */
inline static CGFloat textHeight(NSString * text, UIFont * font, CGSize maxSize, NSLineBreakMode lineBreakMode, BOOL isMultiLine) {
    
    if(text.length == 0)return 0.f;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    if(isMultiLine)
    {
        return [text boundingRectWithSize:maxSize
                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                               attributes:@{ NSFontAttributeName : font } context:NULL].size.height;
    }
    return [text sizeWithAttributes:nil].height;
#else
    if(isMultiLine)
    {
        return [text sizeWithFont:font constrainedToSize:maxSize lineBreakMode:lineBreakMode];
    }
    return [text sizeWithFont:font].height;
#endif
    return 0.f;
}

/**
 *  Truncate of the text target
 *
 *  @param str    The text target
 *  @param length The length that you wanna preserve the text
 *
 *  @return The new text truncated
 */
inline static NSString * truncateString(NSString * str, int length) {
    return [str substringToIndex:MIN(length, [str length])];
}

/**
 *  `UtilHelper` is a class with several util methods to assist in developing your application
 */
@interface UtilHelper : NSObject



///------------------------------------------
/// @name UtilHelper: Public instance methods
///------------------------------------------

typedef void (^HelperLibraryReachabilityStatusBlock)(NetworkStatus remoteHostStatus, BOOL isCurrentState);
/**
 *  Monitoring the internet connection, notify you status by block
 *
 *  @param updateReachabilityBlock The block fo notify status of internet connection
 *
 *  @return The `Reachability` instance
 */
- (Reachability *)internetConnectionNotification:(HelperLibraryReachabilityStatusBlock)updateReachabilityBlock;




///------------------------------------------
/// @name UtilHelper: Public static Methods
///------------------------------------------

/**
*  Create `UtilHelper` shared instance
*
*  @return shared instance of the `UtilHelper`
*/
+ (id)sharedInstance;

/**
*  Convert distance to formatted string meters or kilometers
*
*  @param distance integer value
*
*  @return a formatted string meters or kilometers
*/
+ (NSString*)convertDistanceToString:(int)distance;

/**
 *  Check if internet connected
 *
 *  @return YES if internet connected, otherwise NO
 */
+ (BOOL)isInternetConnected;

/**
 *  Return a string indicate the orientation
 *
 *  @param orientation device orientation
 *
 *  @return string indicate the orientation
 */
+ (NSString *)stringFromOrientation:(UIDeviceOrientation) orientation;

/**
 *  Paint a image with a determine color
 *
 *  @param img   UIImage representation
 *  @param color UIColor representation
 *
 *  @return new image with a new color
 */
+ (UIImage *)image:(UIImage*)img WithColor:(UIColor *)color;

/**
 *  Get the instance of the View Controller with storyboard identifier.
 *  This method use UIMainStoryboardFile key for get current storyboard file
 *
 *  @param identifier storyboard identifier
 *
 *  @return instance of the View Controller
 */
+ (id)storyboardWithIdentifier:(NSString*)identifier;

/**
 *  Convert the data deviceToken to string formatter
 *
 *  @param token a data deviceToken for receive push notification
 *
 *  @return a string represented the binary deviceToken
 */
+ (NSString *)convertTokenToDeviceID:(NSData *)token;

/**
 *  Save image with specific filePath
 *
 *  @param filePath Full path name of file with extension if exists
 *  @param imagem   UIImage representation this value can't be nil
 *
 *  @return YES if file is saved, otherwise NO
 */
+ (BOOL)saveImage:(NSString*)filePath imagem:(UIImage*)imagem;

/**
 *  Defines the file as no backup
 *
 *  @param URL NSURL of file
 *
 *  @discussion iCloud and iTunes will not copy files defined as no backup. If you have files with size large enough to impact 
 *  the backed up by iCloud or iTunes, defines this files to no backup. Otherwise Apple can reject your application.
 *
 *  @return YES if no error. Otherwise NO
 */
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

/**
 *  Make a call for a specific phone number. This method use URL Scheme to launch the phone application
 *
 *  @param phoneNumber phone number
 */
+ (void)call:(NSString*)phoneNumber;

/**
 *  Remove all characters not allowed of a determined text
 *
 *  @param text             the target text
 *  @param charactesAllowed the characters allowed in the target text
 *
 *  @return a new string only with characters allowed
 */
+ (NSString *)cleanedText:(NSString*)text charactesAllowed:(NSString*)charactesAllowed;

/**
 *  Convert a value NSTimeInterval to NSDate
 *
 *  @param interval time interval of date
 *
 *  @return a NSDate object representation
 */
+ (NSDate*)convertJSONDateToNSDateWithLongValue:(long long)interval;

/**
 *  Convert the format date JSON to NSDate
 *
 *  @param jsonDate JSON date value
 *
 *  @return a NSDate object representation
 */
+ (NSDate*)convertJSONDateToNSDate:(NSString*)jsonDate;

/**
 *  Convert a NSDate objeto to NSTimeInterval
 *
 *  @param date NSDate representation
 *
 *  @return a NSTimeInterval object representation
 */
+ (NSTimeInterval)convertNSDateToJSONDate:(NSDate*)date;

/**
 *  Convert a string date to NSDate
 *
 *  @param strDate       string date value
 *  @param formatterDate string format date value
 *
 *  @return a NSDate object representation
 */
+ (NSDate*)convertNSStringToNSDate:(NSString*)strDate formatterDate:(NSString*)formatterDate;

/**
 *  Convert a NSDate to NSString date value
 *
 *  @param date          NSDate object
 *  @param formatterDate string format date value
 *
 *  @return a string formatted of the date value
 */
+ (NSString*)convertNSDateToNSString:(NSDate*)date formatterDate:(NSString*)formatterDate;

/**
 *  Trunc a string
 *
 *  @param str    text value
 *  @param length length trunc
 *
 *  @return a new string truncated
 */
+ (NSString*)trunc:(NSString*)str length:(int)length;

/**
 *  Parse a URL query string to dictionary
 *
 *  @param query string url query string
 *
 *  @discussion If your application uses URL Scheme and its application allows other applications by sending the bid 
 *  parameters in the URL,
 *  this method to analyze a query string and converts it to a valid dictionary.
 *
 *  @return dictionary with keys and values of the query string
 */
+ (NSDictionary *)parseQueryString:(NSString *)query;

/**
 *  Convert View to Image
 *
 *  @param view a view for converto to image
 *
 *  @return Image base target view
 */
+ (UIImage *)imageWithView:(UIView *)view;

/**
 *  Convert View to Image
 *
 *  @param view view for convert to image
 *
 *  @return Image base target view
 */
+ (UIImage*)screenshotAtView:(UIView*)view;

/**
 *  Retrieve image base asset url
 *
 *  @param URL           Asset URL
 *  @param completeBlock block complete proccess
 */
+ (void)imageWithALAssetURL:(NSURL*)URL completeBlock:(void (^)(UIImage * resultImage))completeBlock;

/**
 *  Retrieve a language user preferred. This methods return the first language defines for user in settings
 *
 *  @return string with language user preferred
 */
+ (NSString *)preferredUserLanguage;

/**
 *  Convert NSDictionary object to JSON representation string
 *  Also, working with NSMutableArray object.
 *
 *  @param dictionary a valid NSDictionary or NSMutableArray representation
 *
 *  @return JSON string
 */
+ (NSString*)parseDictionaryToJSON:(NSDictionary*)dictionary;

/**
 *  Convert JSON string to NSDictionary
 *
 *  @param jsonString a valid JSON string representation
 *
 *  @return a dictionary representation
 */
+ (NSDictionary*)parseJSONToDictionary:(NSString*)jsonString;

@end
