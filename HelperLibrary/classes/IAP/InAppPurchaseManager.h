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

@import Foundation;
@import StoreKit;


@class InAppPurchaseManager;

/**
 *  InAppPurchaseManagerDelegate is a protocol of the InAppPurchaseManager
 */
@protocol InAppPurchaseManagerDelegate <NSObject>

@optional

/**
 *  Call when the array of products is loaded
 *
 *  @param array identifiers of products of iTunesConnect
 */
- (void)productsLoadedWithProducts:(NSArray*)products;

/**
 *  Call when a new products is purchased
 *
 *  @param productIdentifier the product identifier
 */
- (void)productPurchased:(NSString*)productIdentifier;

@end



/**
 *  InAppPurchaseManager is a class for management the products within the iTunes Connect
 */
@interface InAppPurchaseManager : NSObject

///---------------------------------------------
/// @name Methods
///---------------------------------------------

/**
 *  Create a shared instance of `InAppPurchaseManager` object.
 *
 *  @return `InAppPurchaseManager` object if successful; `nil` if failure.
 */
+ (InAppPurchaseManager *)sharedInstance;

/**
 *  Request products of the iTunes Connect
 *
 *  @param view the view for add progress indicator while products is loaded
 */
- (void)requestProductsAddProgressInView:(UIView*)view;

/**
 *  Send the request for buy product
 *
 *  @param product The products target
 */
- (void)buyProduct:(SKProduct *)product;

/**
 *  Check if product was purchased
 *
 *  @param productIdentifier product identifier
 *
 *  @return YES if products is purchased. Otherwise NO
 */
- (BOOL)productPurchased:(NSString *)productIdentifier;

/**
 *  Send request for restore the no-consumable products
 *
 *  @discussion When the products is restored, the `productPurchased:productIdentifier` is call
 *
 */
- (void)restoreCompletedTransactions;


///---------------------------------------------
/// @name Propertiers
///---------------------------------------------

/**
 *  The instance of target for notify actions of the `InAppPurchaseManager`
 */
@property (nonatomic, assign) id<InAppPurchaseManagerDelegate> delegate;

/**
 *  A target view for add progress indicator
 */
@property (nonatomic, retain) UIView * hudProgressView;

@end
