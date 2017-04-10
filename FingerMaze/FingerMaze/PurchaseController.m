//
//  PurchaseController.m
//  FingerMaze
//
//  Created by CoreCode on 13.06.12.
//
//

#import "PurchaseController.h"

#define kInAppPurchaseMazesProductId @"mazes"
#define kInAppPurchaseGeneratorsProductId @"random"


@interface SKProduct (LocalizedPrice)
@property (nonatomic, readonly) NSString *localizedPrice;
@end
@implementation SKProduct (LocalizedPrice)
- (NSString *)localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    return formattedString;
}
@end

@implementation PurchaseController
@synthesize generatorPriceLabel;
@synthesize mazePriceLabel;
@synthesize purchaseGeneratorsButton;
@synthesize purchaseMazesButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadStore];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self setupButtons];
}

- (void)setupButtons
{
	if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"mazesPurchased"])
	{
		[purchaseMazesButton setTitle:@"Already Purchased" forState:UIControlStateNormal];
		[purchaseMazesButton setEnabled:NO];
	}
	else
	{
		[purchaseMazesButton setTitle:@"Purchase 160 mazes" forState:UIControlStateNormal];
		[purchaseMazesButton setEnabled:YES];
	}
	
	if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"generatorsPurchased"])
	{
		[purchaseGeneratorsButton setTitle:@"Already Purchased" forState:UIControlStateNormal];
		[purchaseGeneratorsButton setEnabled:NO];
	}
	else
	{
		[purchaseGeneratorsButton setTitle:@"Purchase maze generators" forState:UIControlStateNormal];
		[purchaseGeneratorsButton setEnabled:YES];
	}
	
	[generatorPriceLabel setText:generatorPrice];
	[mazePriceLabel setText:mazePrice];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight) ||
	(interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


- (void)viewDidUnload {
	[self setPurchaseGeneratorsButton:nil];
	[self setPurchaseMazesButton:nil];
	[self setMazePriceLabel:nil];
	[self setGeneratorPriceLabel:nil];
	[super viewDidUnload];
}

- (IBAction)purchaseMazesClicked:(id)sender {
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:kInAppPurchaseMazesProductId];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (IBAction)purchaseGeneratorsClicked:(id)sender {
    if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:kInAppPurchaseGeneratorsProductId];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
}

- (IBAction)done:(id)sender
{
	[self dismissViewControllerAnimated:NO  completion:^{}];
	
}

- (IBAction)restore:(id)sender
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];

}

- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    NSSet *productIdentifiers = [NSSet setWithObjects:kInAppPurchaseMazesProductId, kInAppPurchaseGeneratorsProductId, nil ];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];     // we will release the request object in the delegate callback
}

#pragma mark Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseMazesProductId] ||
		[transaction.payment.productIdentifier  isEqualToString:kInAppPurchaseGeneratorsProductId])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"transactionReceipt"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:kInAppPurchaseMazesProductId] )
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"mazesPurchased" ];
    if ([productId isEqualToString:kInAppPurchaseGeneratorsProductId] )
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"generatorsPurchased" ];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
	
	[self setupButtons];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];

	[self setupButtons];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}


#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
//{
//	for (SKPaymentTransaction *transaction in queue.transactions)
//	{
//		NSString *productID = transaction.payment.productIdentifier;
//	//	[purchasedItemIDs addObject:productID];
//	}
//}

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
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
                break;
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
	
	for (SKProduct * product in products)
	{
//		NSLog(@"Product title: %@" , product.localizedTitle);
//		NSLog(@"Product description: %@" , product.localizedDescription);
//		NSLog(@"Product price: %@" , product.price);
//		NSLog(@"Product id: %@" , product.productIdentifier);
		
		if ([product.productIdentifier isEqualToString:kInAppPurchaseMazesProductId])
		{
			mazePrice = [[product localizedPrice] copy];
		}
		else if ([product.productIdentifier isEqualToString:kInAppPurchaseGeneratorsProductId])
		{
			generatorPrice = [[product localizedPrice] copy];
		}
	}
	


    cc_log_debug(@"Invalid product ids: %@" , response.invalidProductIdentifiers);


    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
}
@end
