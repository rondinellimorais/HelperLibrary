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

##### Using SQLite database #####

You can use the class `DBConfigDefault` for manage your database .sqlite3

The methods `managerContext` and `managerContextWithDelegate:` are responsible for managing all the boring process: Copy the file .sqlite3 into the directory Document/.Private, run the files of the update (See more in documentation of the `DBConfigDefault`) and update the version of database. Your app will be notified by the delegate `dbConfigDefaultDidUpdatedDatabase:newVersion:` case have the update in version of database.

```objective-c
// static function into UtilHelper.h
NSLog(@"%@", privateDirectory());

// Copy database in bundle to privateDirectory()
// If exists file of update, execute!
[DBConfigDefault managerContext];
```

With delegate:

```objective-c
@interface AppDelegate () <DBConfigDefaultDelegate>
@end

// static function into UtilHelper.h
NSLog(@"%@", privateDirectory());

// Copy database in bundle to privateDirectory()
// If exists file of update, execute!
[DBConfigDefault managerContextWithDelegate:self];

#pragma mark - DBConfigDefaultDelegate
- (void)dbConfigDefaultDidUpdatedDatabase:(CGFloat)oldVersion newVersion:(CGFloat)newVersion {
    if(newVersion > oldVersion){
        NSLog(@"now I'm using a new version of database!");
    }
}

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
                    otherButtonTitles:@"I'm", @"No"] show];
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
