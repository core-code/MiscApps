//
//  AppDelegate.h
//  CarDB
//
//  Created by CoreCode on 07.02.14.
//  Copyright © 2018 CoreCode Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *theWindow;

@property (strong) NSDictionary *translation;
@property (strong) NSDictionary *detranslation;
@property (strong) NSDictionary *imageDict;
@property (strong) NSArray *images;
@property (strong) NSArray *data;
@property (assign) IBOutlet  NSWindow *addWindow;
@property (assign) IBOutlet  NSWindow *viewWindow;
@property (assign) IBOutlet  NSWindow *compareWindow;
@property (weak) IBOutlet  WebView *webView;
@property (weak) IBOutlet  NSScrollView *scrollView;
@property (weak) IBOutlet  NSScrollView *tableScrollView;
@property (weak) IBOutlet  NSTableView *tableView;
@property (weak) IBOutlet  NSProgressIndicator *loadingProgress;
@property (weak) IBOutlet  NSButton *isPublicCheckbox;
@property (weak) IBOutlet  NSButton *isOnsaleCheckbox;
@property (weak) IBOutlet  NSPopUpButton *brandsPopup;
@property (weak) IBOutlet  NSStepper *imageStepper;
@property (weak) IBOutlet  NSPredicateEditor *editor;
@property (weak) IBOutlet  NSView *bgView;
@property (weak) IBOutlet  NSView *appView;
@property (weak) IBOutlet  NSImageView *imageView;
@property (weak) IBOutlet  NSArrayController *arrayController;
@property (weak) IBOutlet  NSTextField *usPriceInfoLabel;
@property (weak) IBOutlet NSTextField *databaseDateLabel;
@property (weak) IBOutlet NSTextField *carcountLabel;

@end



@interface BaseValueTransformer : NSValueTransformer {}
@end
@interface EuroValueTransformer : BaseValueTransformer {}
@end
@interface DollarValueTransformer : BaseValueTransformer {}
@end
@interface CM3ValueTransformer : BaseValueTransformer {}
@end
@interface KGValueTransformer : BaseValueTransformer {}
@end
@interface LBSValueTransformer : BaseValueTransformer {}
@end
@interface SValueTransformer : BaseValueTransformer {}
@end
@interface KMHValueTransformer : BaseValueTransformer {}
@end
@interface MPHValueTransformer : BaseValueTransformer {}
@end
@interface NMValueTransformer : BaseValueTransformer {}
@end
@interface LBFTValueTransformer : BaseValueTransformer {}
@end
@interface MMValueTransformer : BaseValueTransformer {}
@end
@interface PSValueTransformer : BaseValueTransformer {}
@end
@interface BHPValueTransformer : BaseValueTransformer {}
@end
@interface LValueTransformer : BaseValueTransformer {}
@end
@interface MPGValueTransformer : BaseValueTransformer {}
@end
@interface INValueTransformer : BaseValueTransformer {}
@end
@interface FuelValueTransformer : BaseValueTransformer {}
@end
@interface FuelValueTransformers : BaseValueTransformer {}
@end
@interface PropValueTransformer : BaseValueTransformer {}
@end
@interface PropValueTransformers : BaseValueTransformer {}
@end
@interface TransmissionValueTransformer : BaseValueTransformer {}
@end
@interface TransmissionValueTransformers : BaseValueTransformer {}
@end
@interface LayoutValueTransformer : BaseValueTransformer {}
@end
@interface LayoutValueTransformers : BaseValueTransformer {}
@end
@interface EngineValueTransformer : BaseValueTransformer {}
@end
@interface EngineValueTransformers : BaseValueTransformer {}
@end
@interface LocationValueTransformer : BaseValueTransformer {}
@end
@interface LocationValueTransformers : BaseValueTransformer {}
@end
@interface MultipleValueTransformers : BaseValueTransformer {}
@end