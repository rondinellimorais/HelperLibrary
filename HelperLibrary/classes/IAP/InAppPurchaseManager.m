//
//  InAppPurchaseManager.m
//  InAppPurchasesTeste
//
//  Created by Rondinelli Morais on 30/07/14.
//  Copyright (c) 2014 Rondinelli Morais. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "MBProgressHUD.h"

@interface InAppPurchaseManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

// ------------------------------------------------------------------------
// Public Propertys
// ------------------------------------------------------------------------
#pragma mark - Public Property
@property (nonatomic, retain) SKProductsRequest * productsRequest;
@property (nonatomic, retain) NSSet * productIdentifiers;
@property (nonatomic, retain) NSMutableSet * purchasedProductIdentifiers;
@property (nonatomic, retain) MBProgressHUD * hud;

@end

@implementation InAppPurchaseManager

// ------------------------------------------------------------------------
// Public Methods
// ------------------------------------------------------------------------
#pragma mark - Public Methods
+ (InAppPurchaseManager *)sharedInstance {
    static dispatch_once_t once;
    static InAppPurchaseManager * sharedInstance;
    dispatch_once(&once, ^{
        
        NSArray * storeProductIdentifiers = [[NSBundle mainBundle]
                                             objectForInfoDictionaryKey:@"StoreProductsIdentifiers"];
        
        if(!storeProductIdentifiers){
            NSAssert(NO, @"Key 'StoreProductsIdentifiers' no found in info.plist!");
        }
        
        NSSet * productIdentifiers = [NSSet setWithArray:storeProductIdentifiers];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (void)requestProductsAddProgressInView:(UIView*)view {
    
    if(view){
        [self setHudProgressView:view];
        [self setHud:[MBProgressHUD showHUDAddedTo:view animated:YES]];
        [self.hud setLabelText:NSLocalizedString(@"Carregando...", nil)];
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:60.0];
    }
    
    // initialized StoreKit
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    [_productsRequest setDelegate:self];
    [_productsRequest start];
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    NSLog(@"Buying %@...", product.productIdentifier);
    if(_hudProgressView){
        [self setHud:[MBProgressHUD showHUDAddedTo:_hudProgressView animated:YES]];
        [self.hud setLabelText:NSLocalizedString(@"Comprando...", nil)];
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:60*5];
    }
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

// ------------------------------------------------------------------------
// Private Methods
// ------------------------------------------------------------------------
#pragma mark - Private Method
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    self = [super init];
    if (self) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {

    NSLog(@"completeTransaction...");
    
    [self dismissHUD];
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {

    NSLog(@"restoreTransaction...");
    NSLog(@"Product: %@ retored", transaction.payment.productIdentifier);
    
    [self dismissHUD];
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    
    [self dismissHUD];
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        [[[UIAlertView alloc] initWithTitle:@"Transaction error"
                                    message:transaction.error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    [_purchasedProductIdentifiers addObject:productIdentifier];

    if([_delegate respondsToSelector:@selector(productPurchased:)]){
        [_delegate productPurchased:productIdentifier];
    }
}

- (void)restoreCompletedTransactions {
    
    if(_hudProgressView){
        [self setHud:[MBProgressHUD showHUDAddedTo:_hudProgressView animated:YES]];
        [self.hud setLabelText:NSLocalizedString(@"Restaurando...", nil)];
    }
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:60];
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

// ------------------------------------------------------------------------
// SKPaymentTransactionObserver
// ------------------------------------------------------------------------
#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction * transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [self dismissHUD];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"restore complete");
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Restauração concluída com sucesso.", nil)
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

// ------------------------------------------------------------------------
// SKProductsRequestDelegate
// ------------------------------------------------------------------------
#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    [self dismissHUD];
    
    if([self.delegate respondsToSelector:@selector(productsLoadedWithProducts:)]){
        [self.delegate productsLoadedWithProducts:skProducts];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    [[[UIAlertView alloc] initWithTitle:@"Payment error"
                                message:error.localizedDescription
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    
    _productsRequest = nil;
    
    [self dismissHUD];
}

// ------------------------------------------------------------------------
// MBProgressHUD
// ------------------------------------------------------------------------
#pragma mark - MBProgressHUD
- (void)dismissHUD {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if(_hudProgressView){
        [MBProgressHUD hideHUDForView:_hudProgressView animated:YES];
    }
    [self setHud:nil];
}

- (void)timeout:(id)arg {
    
    [self.hud setLabelText:@"Timeout!"];
    [self.hud setDetailsLabelText:NSLocalizedString(@"Tempo de requisição esgotado, por favor tente novamente.", nil)];
    self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	self.hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:3.0];
}

@end
