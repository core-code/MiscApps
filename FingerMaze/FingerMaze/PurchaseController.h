//
//  PurchaseController.h
//  FingerMaze
//
//  Created by CoreCode on 13.06.12.
//
//

#import "GradientButton.h"

#import <StoreKit/StoreKit.h>


	
@interface PurchaseController : UIViewController<SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProductsRequest *productsRequest;
	NSString *mazePrice, *generatorPrice;
}
@property (strong, nonatomic) IBOutlet UILabel *generatorPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *mazePriceLabel;
@property (strong, nonatomic) IBOutlet GradientButton *purchaseGeneratorsButton;
@property (strong, nonatomic) IBOutlet GradientButton *purchaseMazesButton;
- (IBAction)purchaseMazesClicked:(id)sender;
- (IBAction)purchaseGeneratorsClicked:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)restore:(id)sender;

@end
