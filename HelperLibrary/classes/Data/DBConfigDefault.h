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

#import "DBBase.h"

@class DBConfigDefault;

/**
 *  `DBConfigDefaultDelegate` is a protocol for notify the changes of database
 */
@protocol DBConfigDefaultDelegate <NSObject>

@required
/**
 *  Notify when a new version of database is available
 *
 *  @discussion The number of database is based in number of version of bundle. This class uses the key 
 *  `CFBundleShortVersionString` for define a version of database.
 *   When a new version of bundle is available and the version is greater that old version saved, this class update for new 
 *   version and notify the classes that use this delegate.
 *
 *  @param oldVersion Old number version of the database
 *  @param newVersion New number version of the database
 */
- (void)dbConfigDefaultDidUpdatedDatabase:(CGFloat)oldVersion newVersion:(CGFloat)newVersion;

@end

/**
 * `DBConfigDefault` is a class for managment of configs default of local database
 *  
 *  @warning This class contains a logic that check if the bundle contains a file of update.
 *   It is necessary that the name of this file is in the standard nomenclature:  `db-script-update-[BUNDLE-VERSION].sql`
 *
 *   Example of file: db-script-update-1.0.sql, db-script-update-1.1.sql, db-script-update-1.5.sql
 *
 *   By default `DBConfigDefault` search for this files and execute if exists.
 */
@interface DBConfigDefault : DBBase

///---------------------------------------------
/// @name Propertiers
///---------------------------------------------

/**
 *  Delegate for notify changes local database
 */
@property (nonatomic, assign) id<DBConfigDefaultDelegate> delegate;


///---------------------------------------------
/// @name Methods
///---------------------------------------------


/**
 *  Create `DBConfigDefault` instance.
 *  
 *  @discussion This method copy file sqlite to document directory, search file for update and update database version number.
 *
 *  @return shared instance for `DBConfigDefault`
 */
+ (instancetype)managerContext;


/**
 *  Create `DBConfigDefault` instance.
 *
 *  @discussion This method copy file sqlite to document directory, search file for update and updates database version number.
 *
 *  @param delegate The delegate for notify changes local database
 *
 *  @return shared instance for `DBConfigDefault`
 */
+ (instancetype)managerContextWithDelegate:(id<DBConfigDefaultDelegate>)delegate;

@end
