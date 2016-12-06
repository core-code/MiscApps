//
//  PurchaseController.m
//  FingerMaze
//
//  Created by CoreCode on 13.06.12.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "PurchaseController.h"

#define kInAppPurchase1ProductId @"3pack"
#define kInAppPurchase2ProductId @"5pack"
#define kInAppPurchase3ProductId @"mappack"
#define kProductIDs @[kInAppPurchase1ProductId, kInAppPurchase2ProductId, kInAppPurchase3ProductId]
#define kProductButtons @{kInAppPurchase1ProductId : @"Purchase 3 additional maps",  kInAppPurchase2ProductId : @"Purchase 5 additional maps", kInAppPurchase3ProductId : @"Purchase 99990 maps"}

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



@interface PurchaseController ()
{
    SKProductsRequest *productsRequest;
	NSMutableDictionary *savedProducts;
}

@property (retain, nonatomic) IBOutlet UILabel *label_3pack;
@property (retain, nonatomic) IBOutlet UILabel *label_5pack;
@property (retain, nonatomic) IBOutlet UILabel *label_mappack;

@property (retain, nonatomic) IBOutlet UIButton *button_3pack;
@property (retain, nonatomic) IBOutlet UIButton *button_5pack;
@property (retain, nonatomic) IBOutlet UIButton *button_mappack;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end


@implementation PurchaseController

+ (int)usedMaps
{
	return (int)@"OmniMaps".defaultArray.count;
}

+ (int)allowedMaps
{
	int allowed = 1;

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"3packPurchased"]) allowed += 3;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"5packPurchased"]) allowed += 5;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"mappackPurchased"]) allowed += 99990;

	return allowed;

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
        [self loadStore];
		savedProducts = [NSMutableDictionary new];
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
	for (NSString *pid in kProductIDs)
	{
		UIButton *button = [self valueForKey:makeString(@"button_%@", pid)];
		UILabel *label = [self valueForKey:makeString(@"label_%@", pid)];

		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:makeString(@"%@Purchased", pid)])
		{
			[button setTitle:@"Already Purchased" forState:UIControlStateNormal];
			[button setEnabled:NO];
		}
		else
		{
			[button setTitle:kProductButtons[pid] forState:UIControlStateNormal];
			[button setEnabled:YES];
		}

		[label setText:[savedProducts[pid] localizedPrice]];
	}

	[_statusLabel setText:makeString(@"You are currently using %i of %i allowed maps.", [PurchaseController usedMaps], [PurchaseController allowedMaps])];
}

- (IBAction)purchaseClicked:(id)sender
{
	if ([SKPaymentQueue canMakePayments])
	{
		for (NSString *pid in kProductIDs)
		{
			UIButton *button = [self valueForKey:makeString(@"button_%@", pid)];
			if (button == sender)
			{
				SKProduct *product = savedProducts[pid];
				SKPayment *payment;
				if (product)
					payment = [SKPayment paymentWithProduct:product];
				else
					payment = [SKPayment paymentWithProductIdentifier:pid];

				[[SKPaymentQueue defaultQueue] addPayment:payment];
				return;
			}
		}
		asl_NSLog_debug(@"FATAL error");
	}
}

- (IBAction)done:(id)sender
{
	[self dismissViewControllerAnimated:NO completion:NULL];
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
    NSSet *productIdentifiers = [NSSet setWithArray:kProductIDs];
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
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:makeString(@"%@Purchased", productId)];
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

		savedProducts[product.productIdentifier] = product;
	}

	[self setupButtons];

	for (NSString *invalidProductId in response.invalidProductIdentifiers)
	{
		asl_NSLog_debug(@"Invalid product id: %@" , invalidProductId);
	}
}
@end
