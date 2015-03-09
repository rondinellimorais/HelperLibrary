//
//  Copyright (c) 2014 Rondinelli Morais. All rights reserved.
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

#import "DBBase.h"
#import <sys/xattr.h>

@implementation DBBase

// ------------------------------------------------------------------------
// Public Methods
// ------------------------------------------------------------------------
- (instancetype)init {
    self = [super init];
    if (self) {
        
        // Copy data base to Document if neccessary
        [self copyDataBase];
        
        // Path database
        NSString * databasePath = [self writableDataBasePath];
        
        // load database
        _db = [FMDatabase databaseWithPath:databasePath];
        
        if(![_db open]){
            NSLog(@"Cannot open database.");
        }
    }
    return self;
}

- (void)close {
    [_db close];
}

// ------------------------------------------------------------------------
// Private Methods
// ------------------------------------------------------------------------
#pragma mark - Private Methods
- (void)copyDataBase {
    
    // Testing for existence
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *writableDBPath = [privateDirectory() stringByAppendingPathComponent:[self dbName]];
    
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
	
    // The writable database does not exist, so copy the default to
    // the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[self dbName]];
    
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    
    if(!success) {
        NSAssert1(0,@"Failed to create writable database file with Message : '%@'.", [error localizedDescription]);
    } else {
        [UtilHelper addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:writableDBPath]];
    }
}

- (NSString *)writableDataBasePath {
	return [privateDirectory() stringByAppendingPathComponent:[self dbName]];
}

- (NSString*)dbName {
    
    // Verify if database name is a custom name
    NSString *SQLiteName = [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"SQLiteName"];
    
    if(SQLiteName)
        return SQLiteName;
    
    // If NO, use PRODUCT_NAME.sqlite3
    __block NSString * dbName = nil;
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:bundlePath error:nil];
    
    __block NSString *appName = [[[NSBundle mainBundle] infoDictionary]  objectForKey:@"CFBundleName"];
    
    [dirContents enumerateObjectsUsingBlock:^(NSString * fileName, NSUInteger idx, BOOL *stop) {
        
        if([fileName isEqualToString:[NSString stringWithFormat:@"%@.sqlite3", appName]]){
            dbName = fileName;
            *stop = YES;
        }
    }];
    
    NSString * erroDescription = [NSString stringWithFormat:@"Database '%@.sqlite3' not exist!", appName];
    NSAssert((dbName!=nil), erroDescription);
    
    return dbName;
}

@end
