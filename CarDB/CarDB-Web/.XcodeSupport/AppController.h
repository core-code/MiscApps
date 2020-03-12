#import <Cocoa/Cocoa.h>
#import "xcc_general_include.h"

@interface BaseValueTransformer : NSValueTransformer
@end

@interface EuroValueTransformer : BaseValueTransformer
@end

@interface DollarValueTransformer : BaseValueTransformer
@end

@interface CM3ValueTransformer : BaseValueTransformer
@end

@interface KGValueTransformer : BaseValueTransformer
@end

@interface LBSValueTransformer : BaseValueTransformer
@end

@interface SValueTransformer : BaseValueTransformer
@end

@interface KMHValueTransformer : BaseValueTransformer
@end

@interface MPHValueTransformer : BaseValueTransformer
@end

@interface NMValueTransformer : BaseValueTransformer
@end

@interface LBFTValueTransformer : BaseValueTransformer
@end

@interface MMValueTransformer : BaseValueTransformer
@end

@interface PSValueTransformer : BaseValueTransformer
@end

@interface BHPValueTransformer : BaseValueTransformer
@end

@interface LValueTransformer : BaseValueTransformer
@end

@interface MPGValueTransformer : BaseValueTransformer
@end

@interface INValueTransformer : BaseValueTransformer
@end

@interface FuelValueTransformer : BaseValueTransformer
@end

@interface FuelValueTransformers : BaseValueTransformer
@end

@interface PropValueTransformer : BaseValueTransformer
@end

@interface PropValueTransformers : BaseValueTransformer
@end

@interface TransmissionValueTransformer : BaseValueTransformer
@end

@interface TransmissionValueTransformers : BaseValueTransformer
@end

@interface LayoutValueTransformer : BaseValueTransformer
@end

@interface LayoutValueTransformers : BaseValueTransformer
@end

@interface EngineValueTransformer : BaseValueTransformer
@end

@interface EngineValueTransformers : BaseValueTransformer
@end

@interface LocationValueTransformer : BaseValueTransformer
@end

@interface LocationValueTransformers : BaseValueTransformer
@end

@interface AppController : NSObject

@property (assign) IBOutlet NSWindow* theWindow;
@property (assign) IBOutlet NSWindow* addWindow;
@property (assign) IBOutlet NSWindow* viewWindow;
@property (assign) IBOutlet NSWindow* compareWindow;
@property (assign) IBOutlet NSWindow* aboutWindow;
@property (assign) IBOutlet WebView* webView;
@property (assign) IBOutlet NSScrollView* scrollView;
@property (assign) IBOutlet NSScrollView* tableScrollView;
@property (assign) IBOutlet NSTableView* tableView;
@property (assign) IBOutlet NSProgressIndicator* loadingProgress;
@property (assign) IBOutlet NSButton* isPublicCheckbox;
@property (assign) IBOutlet NSButton* isOnsaleCheckbox;
@property (assign) IBOutlet NSPopUpButton* brandsPopup;
@property (assign) IBOutlet NSStepper* imageStepper;
@property (assign) IBOutlet SPPredicateEditor* editor;
@property (assign) IBOutlet NSView* bgView;
@property (assign) IBOutlet NSView* appView;
@property (assign) IBOutlet NSImageView* imageView;
@property (assign) IBOutlet NSArrayController* arrayController;
@property (assign) IBOutlet NSTextField* usPriceInfoLabel;
@property (assign) IBOutlet NSTextField* dateLabel;
@property (assign) IBOutlet WebView* adView;

- (IBAction)languageClicked:(id)sender;
- (IBAction)currencyClicked:(id)sender;
- (IBAction)systemClicked:(id)sender;
- (IBAction)refreshClicked:(id)sender;
- (IBAction)resetClicked:(id)sender;
- (IBAction)aboutClicked:(id)sender;
- (IBAction)downloadappClicked:(id)sender;
- (IBAction)corecodeClicked:(id)sender;
- (IBAction)viewcarClicked:(id)sender;
- (IBAction)imagespinnerClicked:(id)sender;
- (IBAction)updatecarClicked:(CPButton)sender;
- (IBAction)addcarClicked:(id)sender;
- (IBAction)submitcarClicked:(id)sender;
- (IBAction)compareClicked:(id)sender;

@end
