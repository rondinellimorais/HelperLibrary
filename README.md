# THIS REPO IS DEPRECATED

Thank you for using HelperLibrary, but this repo is deprecated. Now we have a new framework, this is call [RMExtensionKit](https://github.com/rondinellimorais/RMExtensionKit)

# HelperLibrary

Rondinelli Morais

[@rondmorais](https://twitter.com/rondmorais)

rondinellimorais@gmail.com

## Overview ##

The HelperLibrary framework is a static library iOs simple that contains all the implementation of the silly and repetitive work you have to do every time you create a new iOS / OSX project.

HelperLibrary contains a main class called `UtilHelper.h` which is full of silly work that I have been adding since I started working with iOS SDK. Below is a brief list of things we can do with HelperLibrary:

- Create a representation `UIColor` from the RGB code
- Calculate the height of a given text (Used in very dynamic table cells)
- Truncate a string to a certain size
- Monitor the state of the Internet and receive notification through block
- Check that the device has an active connection to the Internet
- Convert the token Push Notification in `NSString`
- Save a file
- Mark a file saved as No-Backup (file that should not be copying in sync iCloud)
- Convert `NSDate` in `NSString` or otherwise
- Convert `NSDate` in `NSTimeInterval` or otherwise
- Create a `NSDictionary` from a Query String
- And anymore...

## Generate HelperLibrary.framework ##

For generate the package HelperLibrary.framework is super simple, only select the target `Framework` and compile the project (⌘+B), see image below:

<div style="float: right"><img src="http://rondinelliharris.xpg.uol.com.br/images/framework_target.png" /></div>

In doing so HelperLibrary will create the package `HelperLibrary.framework` in `${PROJECT_DIR}`:

<div style="float: right"><img width="70%" src="http://rondinelliharris.xpg.uol.com.br/images/generate_framework.png" /></div>

## Usage ##

After generate the package .framework, drag and drop the HelperLibrary into your XCode project.

Go to `YourProject > Build Settings` within search field enter the text `Other Linker Flags`, double click on `Other Linker Flags` and click in + button, add `-ObjC` flag.

To use the HelperLibrary classes within your application, simply include the core framework header using the following:

    #import <HelperLibrary/HelperLibrary.h>

## Basic use ##

##### Monitor the state of the Internet #####

```objective-c
[[UtilHelper sharedInstance] internetConnectionNotification:^(NetworkStatus remoteHostStatus, BOOL isCurrentState) {
       
      switch (remoteHostStatus) {
          case NotReachable:
              NSLog(@"no connection!");
              break;
          case ReachableViaWiFi:
              NSLog(@"Connected via Wifi");
              break;
          case ReachableViaWWAN:
              NSLog(@"Connected via mobile data");
              break;
          default:
              break;
      }
  }];
```
This block will called every time there is a change in the internet state.

##### Convert `UIView` to `UIImage` #####

```objective-c
// create view
UIView * snoopfyView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {400, 400}}];
[snoopfyView setBackgroundColor:rgb(218, 218, 255)];// using rgb function in UtilHelper

// create my image of the chicken Leg
UIImageView * chickenLegImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chickenleg"]];

// centralize
chickenLegImageView.center = snoopfyView.center;

// add my imageview into my view
[snoopfyView addSubview:chickenLegImageView];

// converte my view to UIImage
// Now, only send to Post Facebook Wall
UIImage * sharedImage = [UtilHelper imageWithView:snoopfyView];
```

##### Extensions #####

`UIAlertView` with block:

```objective-c
[[[UIAlertView alloc] initWithTitle:@"Do you wanna close this page?"
                                message:nil
                          completeBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              NSLog(@"%i", (int)buttonIndex);
                          }
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Yes", @"No", @"Home", nil] show];
```

`NSDictionary` with override get values

```objective-c
NSDictionary * values = @{ @"number" : @"141",
                               @"name" : @"Rondinelli Morais",
                               @"items" : [NSMutableArray arrayWithObjects:@"Product1", @"Product2", @"Product3", @"Product4", nil]
                             };
    

    // using extension NSDictionary
    NSLog(@"My number is: %i", (int)[values integerForkey:@"number"]);
    NSLog(@"My name is: %@", [values stringForKey:@"name"]);
    NSLog(@"My products is: %@", [values mutableArrayValueForKey:@"items"]);
```

See more list extensions below:
  - UIAlertView
  - NSObject
  - NSDictionary
  - UIView
  - UIDevice
  - NSData
  - NSData
  - NSDate
  - UIImage
  

##### Download Image #####

Make the image download dynamically certainly is a boring task. You can use the `DownloadManager` class to download any image and maintain a cache in your application:

```objective-c
NSURL * URL = [NSURL URLWithString:@"https://avatars0.githubusercontent.com/u/3987557?v=3&s=460"];
    
// Download the image and create cache
[[DownloadManager sharedInstance] imageWithURL:URL completeBlock:^(UIImage *image) {
    NSLog(@"Done!");
    NSLog(@"%@", image);
}];
```

After the download is complete, the image cache is maintained in the directory `/Library/Caches/Images`.

## Using SQLite database ##

HelperLibrary can deal very well with the database, and use the API [FMDB] (https://github.com/ccgus/fmdb) to do all the hard work of dealing with SQLite.

However there is a basic configuration that you must do to integrate with the database to function as we expect:

##### Create the file .sqlite3 #####

First create the database file, use any program to do this or even the terminal.
From the name you want to your file with the extension you want, the most common are: .db, .sqlite, .sqlite3 and .sql, HelperLibrary works with .sqlite3 extension, but feel comfortable with the name and extension your database file.

##### Specify the database name into plist #####

Is necessary add a new row into your plist with the name `SQLiteName` and value with the name of your database file. By default `DBBase` will search by `PRODUCT_NAME.sqlite3`.

##### Include a table ConfigDefault #####

The class `DBConfigDefault` uses a table to maintain and update the version of the database, take the query below and perform at your database:

```sql
DROP TABLE IF EXISTS ConfigDefault;
CREATE TABLE ConfigDefault (
    cdf_id                 	INTEGER PRIMARY KEY,
    cdf_dsc					VARCHAR(30),		
    cdf_vle					VARCHAR(100)
);

-- Use this line to informe initialize database version
INSERT INTO ConfigDefault VALUES (null, 'APP_VERSION', '1.0');
```
With this, you are ready to use SQLite in your project.

You can use the class `DBConfigDefault` for manage your database .sqlite3

The methods `managerContext` and `managerContextWithDelegate:` are responsible for managing all the boring process: 
- Copy the file .sqlite3 into the directory Document/.Private, 
- Run the files of the update (See more in documentation of the `DBConfigDefault`)
- Update the version of database. Your app will be notified by the delegate `dbConfigDefaultDidUpdatedDatabase:newVersion:` case have the update in version of database.

Add this code in your `AppDelegate`:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // static function into UtilHelper.h
    NSLog(@"%@", privateDirectory());
    
    // Copy database in bundle to privateDirectory()
    // If exists file of update, execute!
    [DBConfigDefault managerContext];

    return YES;
}
```

With delegate:

```objective-c
@interface AppDelegate () <DBConfigDefaultDelegate>
@end

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // static function into UtilHelper.h
    NSLog(@"%@", privateDirectory());
    
    // Copy database in bundle to privateDirectory()
    // If exists file of update, execute!
    [DBConfigDefault managerContextWithDelegate:self];

    return YES;
}

#pragma mark - DBConfigDefaultDelegate
- (void)dbConfigDefaultDidUpdatedDatabase:(CGFloat)oldVersion newVersion:(CGFloat)newVersion {
    if(newVersion > oldVersion){
        NSLog(@"now I'm using a new version of database!");
    }
}

```

#### Creating your DB class extension DBBase ####

Assuming you have a database table called `ItemDashboard`, their representation in class would be:

```objective-c
// DBItemDashboard.h extends DBBase
@interface DBItemDashboard : DBBase
//....Your public methods
@end
```

```objective-c
// DBItemDashboard.m
@implementation DBItemDashboard

#pragma mark - Public Methods
- (BOOL)add:(NSString*)identifier index:(NSInteger)index msisdn:(NSString*)msisdn {
    
    return [[self db] executeUpdate:@" INSERT INTO ItemDashboard (_id, Identifier, OrderIndex, Msisdn) VALUES (NULL, ?, ?, ?) ",
            identifier, @(index), msisdn];
}

- (BOOL)deleteWithIdentifier:(NSString*)identifier msisdn:(NSString*)msisdn {
    return [[self db] executeUpdate:@" DELETE FROM ItemDashboard WHERE Identifier = ? AND Msisdn = ? ", identifier, msisdn];
}

- (NSMutableArray*)itemsAtMsisdn:(NSString*)msisdn {
    
    NSMutableArray * itens = nil;
    
    FMResultSet * rs = [[self db] executeQuery:@" SELECT Identifier FROM ItemDashboard WHERE Msisdn = ? ORDER BY OrderIndex ", msisdn];
    
    while ([rs next]) {
        
        if(!itens){
            itens = [NSMutableArray new];
        }
        [itens addObject:[rs stringForColumn:@"Identifier"]];
    }
    return itens;
}

- (BOOL)exchangeIndex:(NSUInteger)srcIndex withIndex:(NSUInteger)destIndex msisdn:(NSString*)msisdn {
    
    return [[self db] executeUpdate:@" UPDATE ItemDashboard SET OrderIndex = CASE WHEN OrderIndex = ? THEN ? ELSE ? END WHERE OrderIndex IN (?,?) AND Msisdn = ? ",
                                @(srcIndex), @(destIndex), @(srcIndex), @(destIndex), @(srcIndex), msisdn];
}
@end
```

## Generate Apple documentation ##

The project was documented using the standard appledoc. To generate documentation choose the target `Documentation` and compile the project (⌘+B), see the image below:

<div style="float: right"><img src="http://rondinelliharris.xpg.uol.com.br/images/documentation.png" /></div>

In doing so HelperLibrary will create the directory `documentation` in `${PROJECT_DIR}` containing all HTML documentation:

<div style="float: right"><img width="70%" src="http://rondinelliharris.xpg.uol.com.br/images/documentation_2.png" /></div>

The documentation will also be available in `Documentation and Reference API (⇧⌘0)` the XCode.

## Included Libraries ##
  - [FMDB](https://github.com/ccgus/fmdb)
  - [NSData (CommonCrypto)](https://github.com/AlanQuatermain/aqtoolkit/tree/master/CommonCrypto)
  - [NSData (Base64)](https://github.com/l4u/NSData-Base64)
  - [NSDate] (https://github.com/belkevich/nsdate-calendar)
  - [UIImage](https://github.com/kishikawakatsumi/CropImageSample/blob/master/CropImageSample/UIImage%2BUtilities.h)
  - [UIDevice](https://github.com/InderKumarRathore/UIDeviceUtil)
