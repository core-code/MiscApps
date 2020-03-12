// Copyright (c) 2013 Mutual Mobile (http://mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MMViewController.h"
#import "MMSpreadsheetView.h"
#import "MMGridCell.h"
#import "MMTopRowCell.h"
#import "NSIndexPath+MMSpreadsheetView.h"
#import "Car.h"
#import "PredicateEditorViewController.h"
#import "CarTableViewController.h"

NSArray *fuelNames;
NSArray *brandNames;
NSArray *propulsionNames;
NSArray *layoutNames;
NSArray *transmissionNames;
NSArray *engineNames;
NSArray *locationNames;

NSString *sys;

#define kKeys @[@"brand",@"modelname",@"weightEU",@"cylinderCount",@"displacementCCM",@"maxHorsepower",@"maxHorsepowerRRM",@"maxTorque",@"maxTorqueRPMLow",@"maxSpeed",@"accelerationTo100",@"elasticity80To120",@"fuelType",@"fuelConsumptionEUCombined",@"co2Emission",@"fuelTankSize",@"wheelsWidthFront",@"wheelsRatioFront",@"wheelsRadiusFront",@"wheelsWidthBack",@"wheelsRatioBack",@"wheelsRadiusBack",@"transmissionType",@"gearCount",@"engineLocation",@"poweredWheels",@"maxSeatCount",@"minPriceEU",@"adaptiveSuspension",@"doorCount",@"luggageSpaceMin",@"luggageSpaceMax",@"engineAspiration",@"cylinderLayout",@"widthMM",@"heightMM",@"lengthMM",@"wheelDistanceMM",@"minPriceUS"]
CONST_KEY(DataDate)


@implementation EuroValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" €"]; }
@end
@implementation DollarValueTransformer
+ (id)transformedValue:(id)aValue { return ([aValue floatValue] == [aValue intValue]) ? [[aValue stringValue] stringByAppendingString:@" $"] : makeString(@"~ %i $", [aValue intValue]); }
@end
@implementation CM3ValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" cm³"]; }
@end
@implementation KGValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" kg"]; }
@end
@implementation LBSValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" lbs"]; }
@end
@implementation SValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" s"]; }
@end
@implementation KMHValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" km/h"]; }
@end
@implementation MPHValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" mph"]; }
@end
@implementation NMValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" nm"]; }
@end
@implementation LBFTValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" lb-ft"]; }
@end
@implementation MMValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" mm"]; }
@end
@implementation PSValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" ps"]; }
@end
@implementation BHPValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" bhp"]; }
@end
@implementation LValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" l"]; }
@end
@implementation MPGValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" mpg"]; }
@end
@implementation INValueTransformer
+ (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" in"]; }
@end
@implementation FuelValueTransformer
+ (id)transformedValue:(id)aValue { return fuelNames[[aValue intValue]]; }
@end
@implementation FuelValueTransformers
+ (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", fuelNames[[bla intValue]]]; } return ret.trimmedOfWhitespace; }
@end
@implementation PropValueTransformer
+ (id)transformedValue:(id)aValue { return propulsionNames[[aValue intValue]]; }
@end
@implementation PropValueTransformers
+ (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", propulsionNames[[bla intValue]]]; } return ret.trimmedOfWhitespace; }
@end
@implementation TransmissionValueTransformer
+ (id)transformedValue:(id)aValue { return transmissionNames[[aValue intValue]]; }
@end
@implementation TransmissionValueTransformers
+ (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", transmissionNames[[bla intValue]]]; } return ret.trimmedOfWhitespace; }
@end
@implementation LayoutValueTransformer
+ (id)transformedValue:(id)aValue { return layoutNames[[aValue intValue]]; }
@end
@implementation LayoutValueTransformers
+ (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", layoutNames[[bla intValue]]]; } return ret.trimmedOfWhitespace; }
@end
@implementation EngineValueTransformer
+ (id)transformedValue:(id)aValue { return engineNames[[aValue intValue]]; }
@end
@implementation EngineValueTransformers
+ (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", engineNames[[bla intValue]]]; } return ret.trimmedOfWhitespace; }
@end
@implementation LocationValueTransformer
+ (id)transformedValue:(id)aValue { return locationNames[[aValue intValue]]; }
@end
@implementation LocationValueTransformers
+ (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", locationNames[[bla intValue]]]; } return ret.trimmedOfWhitespace; }
@end
@implementation MultipleValueTransformers
+ (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", bla]; } return ret.trimmedOfWhitespace; }
@end



@interface MMViewController () <MMSpreadsheetViewDataSource, MMSpreadsheetViewDelegate>

@property (nonatomic, strong) NSMutableSet *selectedGridCells;
@property (nonatomic, strong) NSString *cellDataBuffer;
@property (nonatomic, strong) MMSpreadsheetView *spreadSheetView;
@property (nonatomic, weak) UIButton *button;



@property (strong) NSDictionary *translation;
@property (strong) NSDictionary *detranslation;
@property (strong) NSDictionary *imageDict;
@property (strong) NSArray *images;
@property (strong) NSArray *data;
@property (strong) NSArray *origData;
@property (strong) NSArray *columns;
@property (strong) NSPredicate *predicate;

@end

@implementation MMViewController

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{kDataDateKey : [NSDate dateWithString:@"2013" format:@"yyyy"]}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
	UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
	[b setTitle:@" CarDB" forState:UIControlStateNormal];
	[b setBackgroundColor:[UIColor lightGrayColor]];
	[b setImage:@"mini".namedImage forState:UIControlStateNormal];
	[b addTarget:self action:@selector(title:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.titleView = b;


	UIBarButtonItem *view = [[UIBarButtonItem alloc] initWithTitle:@"View"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
															action:@selector(view:)];

	UIBarButtonItem *filter = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
														   action:@selector(filter:)];

	self.navigationItem.rightBarButtonItem = view;
	self.navigationItem.leftBarButtonItem = filter;


 	[self performSelector:@selector(loadData) withObject:nil afterDelay:0.1];
}

- (void)view:(id)sender
{
	if (!self.selectedGridCells.count)
	{
		[[[UIAlertView alloc] initWithTitle:@"Warning" message:@"No cars to view selected" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		return;
	}



	NSMutableArray <Car *> *cars = makeMutableArray();

	for (NSIndexPath *index in self.selectedGridCells.allObjects)
	{
		Car *c = self.data[index.section-1];
		[cars addNewObject:c];
	}


	NSArray <NSString *> *usernames = [kKeys mapped:^(NSString *input)
	{
		return self.translation[input];
	}];

	NSArray <NSString *> *cardata = [kKeys mapped:^(NSString *key)
	{
		NSString *value = [[cars[0] valueForKey:key] stringValue];

		if ([key isEqualToString:@"minPriceEU"]) value = [EuroValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"minPriceUS"]) value = [DollarValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"displacementCCM"]) value = [CM3ValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"maxHorsepower"]) value = ([sys isEqualToString:@"us"]) ? [BHPValueTransformer transformedValue:value] : [PSValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"maxTorque"]) value = ([sys isEqualToString:@"us"]) ? [LBFTValueTransformer transformedValue:value] : [NMValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"maxSpeed"]) value = ([sys isEqualToString:@"us"]) ? [MPHValueTransformer transformedValue:value] : [KMHValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"accelerationTo100"]) value = [SValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"weightEU"]) value = ([sys isEqualToString:@"us"]) ? [LBSValueTransformer transformedValue:value] : [KGValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"fuelConsumptionEUCombined"]) value = ([sys isEqualToString:@"us"]) ? [MPGValueTransformer transformedValue:value] : [LValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"luggageSpaceMin"]) value = [LValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"fuelType"]) value = [FuelValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"poweredWheels"]) value = [PropValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"fuelTankSize"]) value = [LValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"transmissionType"]) value = [TransmissionValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"engineLocation"]) value = [LocationValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"cylinderLayout"]) value = [LayoutValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"engineAspiration"]) value = [EngineValueTransformer transformedValue:value];
		else if ([key hasSuffix:@"MM"]) value = ([sys isEqualToString:@"us"]) ? [INValueTransformer transformedValue:value] : [MMValueTransformer transformedValue:value];


		return value;
	}];
	NSArray <NSString *> *cardata2 = nil;
	if (cars.count > 1)
		cardata2 = [kKeys mapped:^(NSString *key)
		{
			   NSString *value = [[cars[1] valueForKey:key] stringValue];

			   if ([key isEqualToString:@"minPriceEU"]) value = [EuroValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"minPriceUS"]) value = [DollarValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"displacementCCM"]) value = [CM3ValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"maxHorsepower"]) value = ([sys isEqualToString:@"us"]) ? [BHPValueTransformer transformedValue:value] : [PSValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"maxTorque"]) value = ([sys isEqualToString:@"us"]) ? [LBFTValueTransformer transformedValue:value] : [NMValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"maxSpeed"]) value = ([sys isEqualToString:@"us"]) ? [MPHValueTransformer transformedValue:value] : [KMHValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"accelerationTo100"]) value = [SValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"weightEU"]) value = ([sys isEqualToString:@"us"]) ? [LBSValueTransformer transformedValue:value] : [KGValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"fuelConsumptionEUCombined"]) value = ([sys isEqualToString:@"us"]) ? [MPGValueTransformer transformedValue:value] : [LValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"luggageSpaceMin"]) value = [LValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"fuelType"]) value = [FuelValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"poweredWheels"]) value = [PropValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"fuelTankSize"]) value = [LValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"transmissionType"]) value = [TransmissionValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"engineLocation"]) value = [LocationValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"cylinderLayout"]) value = [LayoutValueTransformer transformedValue:value];
			   else if ([key isEqualToString:@"engineAspiration"]) value = [EngineValueTransformer transformedValue:value];
			   else if ([key hasSuffix:@"MM"]) value = ([sys isEqualToString:@"us"]) ? [INValueTransformer transformedValue:value] : [MMValueTransformer transformedValue:value];
			   
			   
			   return value;
		}];




	CarTableViewController *vc = [[CarTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
	vc.titles = usernames;
	vc.details = cardata;
	vc.details2 = cardata2;
	vc.url = makeString(@"http://www.bing.com/images/search?adlt=strict&q=%@ %@", [cars[0] brand], [cars[0] modelname]);
	if (cars.count > 1)
		vc.url2 = makeString(@"http://www.bing.com/images/search?adlt=strict&q=%@ %@", [cars[1] brand], [cars[1] modelname]);

	vc.images = [self.imageDict objectForKey:[cars[0] modelname]];
	if (cars.count > 1)
		vc.images2 = [self.imageDict objectForKey:[cars[1] modelname]];

	[self.navigationController pushViewController:vc animated:YES];

}

- (void)filter:(id)sender
{
	PredicateEditorViewController *vc = [[PredicateEditorViewController alloc] initWithStyle:UITableViewStyleGrouped];
	NSString *currency = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"US"] ? @"usd" : @"eur";
	NSString *priceKey = ([currency isEqualToString:@"usd"]) ? @"minPriceUS" : @"minPriceEU";

	vc.predicateArray = @[
@{PROPERTY_STR(leftExpression) : @"modelname", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"modelname"], PROPERTY_STR(rightExpression) : @(StringAttributeType), PROPERTY_STR(options) : @0},
@{PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"brand", PROPERTY_STR(rightExpression) : brandNames, PROPERTY_STR(leftExpressionLocalized) : self.translation[@"brand"]},
@{PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"fuelType", PROPERTY_STR(rightExpression) : [fuelNames subarrayWithRange:NSMakeRange(1, [fuelNames count]-1)], PROPERTY_STR(leftExpressionLocalized) : self.translation[@"fuelType"]},
@{PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"engineAspiration", PROPERTY_STR(rightExpression) : [engineNames subarrayWithRange:NSMakeRange(1, [engineNames count]-1)], PROPERTY_STR(leftExpressionLocalized) : self.translation[@"engineAspiration"]},
@{PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"poweredWheels", PROPERTY_STR(rightExpression) : [propulsionNames subarrayWithRange:NSMakeRange(1, [propulsionNames count]-1)], PROPERTY_STR(leftExpressionLocalized) : self.translation[@"poweredWheels"]},
@{PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"transmissionType", PROPERTY_STR(rightExpression) : [transmissionNames subarrayWithRange:NSMakeRange(1, [transmissionNames count]-1)], PROPERTY_STR(leftExpressionLocalized) : self.translation[@"transmissionType"]},
@{PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"cylinderLayout", PROPERTY_STR(rightExpression) : [layoutNames subarrayWithRange:NSMakeRange(1, [layoutNames count]-1)], PROPERTY_STR(leftExpressionLocalized) : self.translation[@"cylinderLayout"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"maxHorsepower", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"maxHorsepower"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"maxTorque", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"maxTorque"]},
@{PROPERTY_STR(rightExpression) : @(FloatAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"maxSpeed", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"maxSpeed"]},
@{PROPERTY_STR(rightExpression) : @(FloatAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"accelerationTo100", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"accelerationTo100"]},
@{PROPERTY_STR(rightExpression) : @(FloatAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"elasticity80To120", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"elasticity80To120"]},
@{PROPERTY_STR(rightExpression) : @(FloatAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"fuelConsumptionEUCombined", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"fuelConsumptionEUCombined"]},
@{PROPERTY_STR(rightExpression) : @(FloatAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"heightToWidth", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"heightToWidth"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"gearCount", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"gearCount"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"doorCount", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"doorCount"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"maxSeatCount", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"maxSeatCount"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"luggageSpaceMin", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"luggageSpaceMin"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"fuelTankSize", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"fuelTankSize"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"co2Emission", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"co2Emission"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"weightEU", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"weightEU"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"cylinderCount", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"cylinderCount"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"displacementCCM", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"displacementCCM"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"widthMM", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"widthMM"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"heightMM", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"heightMM"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"lengthMM", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"lengthMM"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"wheelDistanceMM", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"wheelDistanceMM"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"horsepowerPerTonne", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"horsepowerPerTonne"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : @"horsepowerPerDisplacement", PROPERTY_STR(leftExpressionLocalized) : self.translation[@"horsepowerPerDisplacement"]},
@{PROPERTY_STR(rightExpression) : @(IntegerAttributeType), PROPERTY_STR(options) : @0, PROPERTY_STR(leftExpression) : priceKey, PROPERTY_STR(leftExpressionLocalized) : self.translation[priceKey]}
 ];


#pragma warning fix problem with wrong selection to view for second time, fix column headers unclickable
	vc.finishBlock = ^(NSPredicate *pred)
	{
		id text = [pred predicateFormat];

		LOG(text);

		for (int i = 0; i < [fuelNames count]; i++)
		{
			text = [text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"", fuelNames[i]] withString:@(i).stringValue];
		}
		for (int i = 0; i < [engineNames count]; i++)
		{
			text = [text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"", engineNames[i]] withString:@(i).stringValue];
		}
		for (int i = 0; i < [propulsionNames count]; i++)
		{
			text = [text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"", propulsionNames[i]] withString:@(i).stringValue];
		}
		for (int i = 0; i < [transmissionNames count]; i++)
		{
			text = [text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"", transmissionNames[i]] withString:@(i).stringValue];
		}
		for (int i = 0; i < [layoutNames count]; i++)
		{
			text = [text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"", layoutNames[i]] withString:@(i).stringValue];
		}
		text = [text stringByReplacingOccurrencesOfString:@"CONTAINS[cd] 0" withString:@"!= 0"];
		LOG(text);

		pred = [NSPredicate predicateWithFormat:text];
		self.predicate = pred;


		self.data = [self.origData filteredArrayUsingPredicate:pred];

		if (!self.data.count)
		{
			[[[UIAlertView alloc] initWithTitle:@"Warning" message:@"No cars match your critera. The filter was reset" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
			self.predicate = nil;
			self.data = self.origData;
		}
		[self.spreadSheetView reloadData];
		[self.spreadSheetView fix];
	};

	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MMSpreadsheetViewDataSource

- (CGSize)spreadsheetView:(MMSpreadsheetView *)spreadsheetView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	int widthsDE[] = {80,230,60,52,58,45,78,68,65,55,55,75,60,65,70,65,60,70,45,40,40,40,70,45,40,65,60,60,60,70};
	int widthsEN[] = {80,230,60,60,80,50,78,68,65,55,55,90,60,80,70,65,60,70,45,40,40,45,85,50,45,65,60,60,60,70};
	NSString *browserLanguage = [[NSLocale preferredLanguages][0] isEqualToString:@"de"] ? @"de" : @"us";



	int height;
	if 	([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		height = indexPath.mmSpreadsheetRow == 0 ? 20 : 14;
	else
		height = indexPath.mmSpreadsheetRow == 0 ? 16 : 12;

	int width = ([browserLanguage isEqualToString:@"de"]) ? widthsDE[indexPath.mmSpreadsheetColumn] : widthsEN[indexPath.mmSpreadsheetColumn];


    return CGSizeMake(width * (([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 1.05 : 0.85), height);
}

- (NSInteger)numberOfRowsInSpreadsheetView:(MMSpreadsheetView *)spreadsheetView {
    NSInteger rows = self.data.count+1;
    return rows;
}

- (NSInteger)numberOfColumnsInSpreadsheetView:(MMSpreadsheetView *)spreadsheetView {
    NSInteger columns = self.columns.count;
	return columns;
}

- (UICollectionViewCell *)spreadsheetView:(MMSpreadsheetView *)spreadsheetView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
   /* if (indexPath.mmSpreadsheetRow == 0 && indexPath.mmSpreadsheetColumn == 0) {
        // Upper left.
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
        MMGridCell *gc = (MMGridCell *)cell;
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mm_logo"]];
        [gc.contentView addSubview:logo];
        logo.center = gc.contentView.center;
        gc.textLabel.numberOfLines = 0;
        cell.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    }
    else*/
        if (indexPath.mmSpreadsheetRow == 0 /*&& indexPath.mmSpreadsheetColumn > 0*/) {
        // Upper right.
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"TopRowCell" forIndexPath:indexPath];
        MMTopRowCell *tr = (MMTopRowCell *)cell;
		NSString *rowStr = [self.columns objectAtIndex:indexPath.mmSpreadsheetColumn];

		tr.textLabel.text = [self.translation valueForKey:rowStr];
        cell.backgroundColor = [UIColor whiteColor];
    }
//    else if (indexPath.mmSpreadsheetRow > 0 && indexPath.mmSpreadsheetColumn == 0) {
//        // Lower left.
//        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"LeftColumnCell" forIndexPath:indexPath];
//        MMLeftColumnCell *lc = (MMLeftColumnCell *)cell;
//        lc.textLabel.text = [NSString stringWithFormat:@"Left Column: %i", indexPath.mmSpreadsheetRow];
//        BOOL isDarker = indexPath.mmSpreadsheetRow % 2 == 0;
//        if (isDarker) {
//            cell.backgroundColor = [UIColor colorWithRed:222.0f / 255.0f green:243.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];
//        } else {
//            cell.backgroundColor = [UIColor colorWithRed:233.0f / 255.0f green:247.0f / 255.0f blue:252.0f / 255.0f alpha:1.0f];
//        }
//    }
    else {
        // Lower right.
        cell = [spreadsheetView dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
        MMGridCell *gc = (MMGridCell *)cell;
        Car *car = [self.data objectAtIndex:indexPath.mmSpreadsheetRow-1];
        NSString *key = [self.columns objectAtIndex:indexPath.mmSpreadsheetColumn];
		NSString *value = [[car valueForKey:key] stringValue];

		if ([key isEqualToString:@"minPriceEU"]) value = [EuroValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"minPriceUS"]) value = [DollarValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"displacementCCM"]) value = [CM3ValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"maxHorsepower"]) value = ([sys isEqualToString:@"us"]) ? [BHPValueTransformer transformedValue:value] : [PSValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"maxTorque"]) value = ([sys isEqualToString:@"us"]) ? [LBFTValueTransformer transformedValue:value] : [NMValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"maxSpeed"]) value = ([sys isEqualToString:@"us"]) ? [MPHValueTransformer transformedValue:value] : [KMHValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"accelerationTo100"]) value = [SValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"weightEU"]) value = ([sys isEqualToString:@"us"]) ? [LBSValueTransformer transformedValue:value] : [KGValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"fuelConsumptionEUCombined"]) value = ([sys isEqualToString:@"us"]) ? [MPGValueTransformer transformedValue:value] : [LValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"luggageSpaceMin"]) value = [LValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"fuelType"]) value = [FuelValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"poweredWheels"]) value = [PropValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"fuelTankSize"]) value = [LValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"transmissionType"]) value = [TransmissionValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"engineLocation"]) value = [LocationValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"cylinderLayout"]) value = [LayoutValueTransformer transformedValue:value];
		else if ([key isEqualToString:@"engineAspiration"]) value = [EngineValueTransformer transformedValue:value];
		else if ([key hasSuffix:@"MM"]) value = ([sys isEqualToString:@"us"]) ? [INValueTransformer transformedValue:value] : [MMValueTransformer transformedValue:value];

        gc.textLabel.text = value;
        BOOL isDarker = indexPath.mmSpreadsheetRow % 2 == 0;
        if (isDarker) {
            cell.backgroundColor = [UIColor colorWithRed:242.0f / 255.0f green:242.0f / 255.0f blue:242.0f / 255.0f alpha:1.0f];
        } else {
            cell.backgroundColor = [UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];
        }
    }

    return cell;
}

#pragma mark - MMSpreadsheetViewDelegate

- (void)spreadsheetView:(MMSpreadsheetView *)spreadsheetView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.selectedGridCells containsObject:indexPath])
//	{
//        [self.selectedGridCells removeObject:indexPath];
//        [spreadsheetView deselectItemAtIndexPath:indexPath animated:YES];
//    }
//	else
	{
//        [self.selectedGridCells removeAllObjects];
		if (indexPath.section == 0) // sort
		{
			static int clicktimes = 0;

			clicktimes ++;
			NSString *key = [self.columns objectAtIndex:indexPath.mmSpreadsheetColumn];

			self.data = [self.data sortedArrayByKey:key ascending:clicktimes % 2 == 0 ? YES : NO];
			[self.spreadSheetView reloadData];
		}
		else
			[self.selectedGridCells addObject:indexPath];

//		for (int i = 0; i < [self numberOfRowsInSpreadsheetView:nil]; i++)
//		{
////			UICollectionViewCell *c = [self spreadsheetView:nil cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[indexPath item] inSection:i]];
//			[spreadsheetView selectItemAtIndexPath:[NSIndexPath indexPathForItem:[indexPath item] inSection:i] animated:NO];
//		}
    }
}
- (void)spreadsheetView:(MMSpreadsheetView *)spreadsheetView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
	[self.selectedGridCells removeObject:indexPath];
}

- (BOOL)spreadsheetView:(MMSpreadsheetView *)spreadsheetView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)spreadsheetView:(MMSpreadsheetView *)spreadsheetView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    /*
     These are the selectors the sender (a UIMenuController) sends by default.
     
     _insertImage:
     cut:
     copy:
     select:
     selectAll:
     paste:
     delete:
     _promptForReplace:
     _showTextStyleOptions:
     _define:
     _addShortcut:
     _accessibilitySpeak:
     _accessibilitySpeakLanguageSelection:
     _accessibilityPauseSpeaking:
     makeTextWritingDirectionRightToLeft:
     makeTextWritingDirectionLeftToRight:
     
     We're only interested in 3 of them at this point
     */
    if (action == @selector(cut:) ||
        action == @selector(copy:) ||
        action == @selector(paste:)) {
        return YES;
    }
    return NO;
}

- (void)spreadsheetView:(MMSpreadsheetView *)spreadsheetView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    NSMutableArray *rowData = [self.tableData objectAtIndex:indexPath.mmSpreadsheetRow];
//    if (action == @selector(cut:)) {
//        self.cellDataBuffer = [rowData objectAtIndex:indexPath.row];
//        [rowData replaceObjectAtIndex:indexPath.row withObject:@""];
//        [spreadsheetView reloadData];
//    } else if (action == @selector(copy:)) {
//        self.cellDataBuffer = [rowData objectAtIndex:indexPath.row];
//    } else if (action == @selector(paste:)) {
//        if (self.cellDataBuffer) {
//            [rowData replaceObjectAtIndex:indexPath.row withObject:self.cellDataBuffer];
//            [spreadsheetView reloadData];
//        }
//    }
}

#pragma mark -


- (void)loadData
{
	NSString *browserLanguage = [[NSLocale preferredLanguages][0] isEqualToString:@"de"] ? @"de" : @"us";
	NSString *currency = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"US"] ? @"usd" : @"eur";
	sys = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"US"] ? @"us" : @"me";
	NSMutableSet *tmpBrands = [NSMutableSet set];

	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userLanguage"])
		browserLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLanguage"];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userCurrency"])
		currency = [[NSUserDefaults standardUserDefaults] objectForKey:@"userCurrency"];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userSystem"])
		sys = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSystem"];

	if ([browserLanguage isEqualToString:@"de"]) 	fuelNames = @[@"", @"Benzin", @"Diesel", @"Elektro"];
	else											fuelNames = @[@"", @"Petrol", @"Diesel", @"Electric"];
	if ([browserLanguage isEqualToString:@"de"]) 	propulsionNames = @[@"", @"Front", @"Heck", @"Allrad"];
	else											propulsionNames = @[@"", @"Front", @"Rear", @"AWD"];
	if ([browserLanguage isEqualToString:@"de"]) 	transmissionNames = @[@"", @"Manuell", @"Automatik", @"Auto. (DKG)"];
	else											transmissionNames = @[@"", @"Manual", @"Automatic", @"Auto. (DCT)"];
	if ([browserLanguage isEqualToString:@"de"]) 	engineNames = @[@"Saug", @"Saug", @"Turbo", @"Kompressor", @"Hybrid", @"Elektro"];
	else											engineNames = @[@"Natural", @"Natural", @"Turbo", @"Super", @"Hybrid", @"Electric"];
	if ([browserLanguage isEqualToString:@"de"]) 	locationNames = @[@"", @"Front", @"Mitte", @"Heck"];
	else											locationNames = @[@"", @"Front", @"Mid", @"Rear"];

	layoutNames = @[@"", @"R", @"V", @"B", @"W"];

	NSArray *carPropertyKeysStored = kKeys;
	NSArray * carPropertyKeysDerived = @[@"horsepowerPerTonne", @"horsepowerPerDisplacement", @"heightToWidth"];
	NSArray * keys = [carPropertyKeysStored arrayByAddingObjectsFromArray:carPropertyKeysDerived];
	NSArray * deTranslations = @[@"Marke", @"Modell", @"Gewicht", @"Zylinder", @"Hubraum", @"PS", @"RPM max. PS", @"Drehmoment", @"RPM max. DM", @"Max. km/h", @"0-100km/h", @"80-120km/h", @"Treibstoff", @"Verbrauch", @"CO2", @"Tank", @"Reifenbreite Vorne", @"Reifenverhältnis Vorne", @"Reifenradius Vorne", @"Reifenbreite Hinten", @"Reifenverhältnis Hinten", @"Reifenradius Hinten", @"Getriebe", @"Gänge", @"Motor", @"Antrieb", @"Sitze", @"Min. Preis", @"Adaptives Fahrwerk", @"Türen", @"Kofferraum", @"Kofferraum Max.", @"Aufladung", @"Art", @"Breite", @"Höhe", @"Länge", @"Radstand", @"Min. Preis", @"PS / kg", @"PS / cm³", @"Höhe / Breite"];
	NSArray * enTranslations = @[@"brand", @"modelname", @"weight", @"cylinders", @"displacement", @"power", @"max power RPM", @"torque", @"max torque rom", @"top speed", @"0-62mph", @"62-75mph", @"fuel", @"consumption", @"CO2", @"capacity", @"wheel width front", @"wheel ratio front", @"wheel radius front", @"wheel width back", @"wheel ratio back", @"wheel width back", @"transmission", @"gears", @"engine location", @"drivetrain", @"seats", @"price (EU)", @"adaptive suspension", @"doors", @"luggage", @"luggage max", @"aspiration", @"engine", @"width", @"height", @"length", @"wheelbase", @"price", @"P2W", @"HP / cm³", @"height / width"];

	if ([browserLanguage isEqualToString:@"de"])	[self setTranslation:[NSDictionary dictionaryWithObjects:deTranslations forKeys:keys]];
	else										[self setTranslation:[NSDictionary dictionaryWithObjects:enTranslations forKeys:keys]];
	if ([browserLanguage isEqualToString:@"de"])	[self setDetranslation:[NSDictionary dictionaryWithObjects:keys forKeys:deTranslations]];
	else										[self setDetranslation:[NSDictionary dictionaryWithObjects:keys forKeys:enTranslations]];


	// TODO: change 0-62mph if metric system is used, consumption in mpg

	NSString *dataFilePath = [cc.suppDir stringByAppendingPathComponent:@"data.csv"];
	NSString *picturesFilePath = [cc.suppDir stringByAppendingPathComponent:@"pictures.txt"];

	//	NSString *databaseUpdateDate = [((NSDate *)kDataDateKey.defaultObject) stringUsingDateStyle:NSDateFormatterMediumStyle andTimeStyle:NSDateFormatterNoStyle];
	//	self.databaseDateLabel.stringValue = makeString(@"DataBase update: %@", databaseUpdateDate);

	const BOOL forceLocal = FALSE;
#ifndef DEBUG
	assert(!forceLocal);
#else
	if (forceLocal)
		cc_log(@"Warning: forceLocal ON");
#endif
	NSString *answer = (dataFilePath.fileExists && !forceLocal) ? dataFilePath.contents.string : @"data.csv".resourceURL.contents.string;
	NSArray <NSString *> *lines = answer.lines;
    id tmpCars = [[NSMutableArray alloc] init];
    for (int i = 0; i < [lines count]; i++)
    {
		id car = [[Car alloc] init];
		id line = lines[i];
	    id components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
		if ([components count] > 30)
		{
			for (int b = 0; b < [components count] && b < 39; b++)
			{
	    		id component = components[b];
	    		id name = carPropertyKeysStored[b];
	    		if ([component length] == 0)
					[car setValue:[NSNumber numberWithFloat:0.0] forKey:name];
				else if ([component floatValue] > 0.0 && b >= 2)
					[car setValue:[NSNumber numberWithFloat:[component floatValue]] forKey:name];
				else
					[car setValue:component forKey:name];
			}
			if ([car engineLocation] == 0)
				[car setEngineLocation:1];


			if ([car minPriceUS] == 0)
				[car setMinPriceUS:(([car minPriceEU] / 1000) * 1000) + 0.1]; // rounds down but thats ok
			
			[tmpBrands addObject:[car brand]];
			[tmpCars addObject:car];
		}
	}
	brandNames = [tmpBrands sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];

	if ([sys isEqualToString:@"us"])
	{
		for (int i = 0; i < [tmpCars count]; i++)
		{
			id car = tmpCars[i];

			[car setMaxTorque:([car maxTorque] * 0.7375621483695506)];
			[car setMaxSpeed:([car maxSpeed] * 0.6214)];
			[car setWeightEU:(([car weightEU] - 75.0) * 2.20462262)];
			[car setMaxHorsepower:(([car maxHorsepower] / 1.014))];
			[car setFuelConsumptionEUCombined:(int)(235.0 / [car fuelConsumptionEUCombined])];


			[car setWidthMM:([car widthMM] * 0.0393700787)];
			[car setHeightMM:([car heightMM] * 0.0393700787)];
			[car setLengthMM:([car lengthMM] * 0.0393700787)];
			[car setWheelDistanceMM:([car wheelDistanceMM] * 0.0393700787)];
		}

		//		NSArray *subviews1 = [[self.compareWindow contentView] subviews];
		//		NSArray *subviews2 = [[self.viewWindow contentView] subviews];
		//		NSArray *subviews = [subviews1 arrayByAddingObjectsFromArray:subviews2];
		//		for (int i = 0; i < [subviews count]; i++)
		//		{
		//			NSTextField *view = subviews[i];
		//
		//			id repl = @{@"millimeter" : @"inch", @"kilogramm" : @"lbs", @"liter / 100km" : @"mpg"};
		//
		//			if ([view isKindOfClass:[NSTextField class]] && [repl objectForKey:[view stringValue]])
		//				[view setStringValue:[repl objectForKey:[view stringValue]]];
		//		}
	}
	for (int i = 0; i < [tmpCars count]; i++)
	{
		Car *car = tmpCars[i];

		float hp = [car maxHorsepower];
		float hppw = hp * 1000.0 / [car weightEU];
		float hppd = hp * 1000.0 / [car displacementCCM];
		float wth = [car widthMM] ? (float)[car heightMM] / (float)[car widthMM] : 0;
		[car setHorsepowerPerTonne:(hppw)];
		if (hppd > 10000 || hppd < 0)
			[car setHorsepowerPerDisplacement:0];
		else
			[car setHorsepowerPerDisplacement:(hppd)];

		[car setHeightToWidth:floorf(wth * 100 + 0.5) / 100];
	}

	[self setOrigData:tmpCars];
	[self setData:tmpCars];




	//	id templates = [NSMutableArray array];
	//	[templates addObject:[self compoundRowTemplate]];
	//	[templates addObject:[self rowTemplateWithStringEditorAndLeftKeys:@[[_translation objectForKey:@"modelname"]] options:NSCaseInsensitivePredicateOption|NSDiacriticInsensitivePredicateOption]];
	//	[templates addObject:[self rowTemplateWithLeftKeys:@[[_translation objectForKey:@"brand"]] rightConstants:brandNames]];
	//	[templates addObject:[self rowTemplateWithLeftKeys:@[[_translation objectForKey:@"fuelType"]] rightConstants:[fuelNames subarrayWithRange:NSMakeRange(1, [fuelNames count]-1)]]];
	//	[templates addObject:[self rowTemplateWithLeftKeys:@[[_translation objectForKey:@"engineAspiration"]] rightConstants:[engineNames subarrayWithRange:NSMakeRange(1, [engineNames count]-1)]]];
	//	[templates addObject:[self rowTemplateWithLeftKeys:@[[_translation objectForKey:@"poweredWheels"]] rightConstants:[propulsionNames subarrayWithRange:NSMakeRange(1, [propulsionNames count]-1)]]];
	//	[templates addObject:[self rowTemplateWithLeftKeys:@[[_translation objectForKey:@"transmissionType"]] rightConstants:[transmissionNames subarrayWithRange:NSMakeRange(1, [transmissionNames count]-1)]]];
	//	[templates addObject:[self rowTemplateWithLeftKeys:@[[_translation objectForKey:@"cylinderLayout"]] rightConstants:[layoutNames subarrayWithRange:NSMakeRange(1, [layoutNames count]-1)]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"maxHorsepower"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"maxTorque"]]]];
	//	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:@[[_translation objectForKey:@"maxSpeed"]]]];
	//	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:@[[_translation objectForKey:@"accelerationTo100"]]]];
	//	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:@[[_translation objectForKey:@"elasticity80To120"]]]];
	//	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:@[[_translation objectForKey:@"fuelConsumptionEUCombined"]]]];
	//	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:@[[_translation objectForKey:@"heightToWidth"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"gearCount"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"doorCount"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"maxSeatCount"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"luggageSpaceMin"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"fuelTankSize"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"co2Emission"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"weightEU"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"cylinderCount"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"displacementCCM"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:([currency isEqualToString:@"usd"]) ? @"minPriceUS" : @"minPriceEU"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"widthMM"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"heightMM"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"lengthMM"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"wheelDistanceMM"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"horsepowerPerTonne"]]]];
	//	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"horsepowerPerDisplacement"]]]];
	//	[_editor setNestingMode:NSRuleEditorNestingModeList];
	//	[_editor setRowTemplates:templates];
	//	[_editor addRow:self];


	id priceKey = @"minPriceEU";
	if ([currency isEqualToString:@"usd"])
	{
		priceKey = @"minPriceUS";
		//		[self.usPriceInfoLabel setHidden:NO];
	}

	self.columns = @[@"brand",@"modelname",priceKey,@"cylinderCount",@"displacementCCM",@"maxHorsepower",@"maxTorque",@"maxSpeed",@"accelerationTo100", @"horsepowerPerTonne", @"horsepowerPerDisplacement", @"heightToWidth", @"weightEU", @"fuelConsumptionEUCombined", @"luggageSpaceMin", @"fuelType", @"poweredWheels", @"engineLocation", @"doorCount",@"maxSeatCount", @"co2Emission",@"fuelTankSize",@"transmissionType",@"gearCount",@"cylinderLayout", @"engineAspiration" ,@"widthMM",@"heightMM",@"lengthMM",@"wheelDistanceMM"];




	NSMutableDictionary *dict = [NSMutableDictionary new];
	answer = picturesFilePath.fileExists ? picturesFilePath.contents.string : @"pictures.txt".resourceURL.contents.string;
	lines = answer.lines;
    for (int i = 0; i < lines.count; i++)
    {
		NSString *line = lines[i];

		if ([line length] > 10)
		{
			id comp1 = [line componentsSeparatedByString:@"||"];
			id carnames = [comp1[0] componentsSeparatedByString:@"|"];


			for (int v = 0; v < [carnames count]; v++)
			{
			 	NSString *carname = carnames[v];


			 	id pics = [comp1[1] componentsSeparatedByString:@" "];

			 	[dict setObject:pics forKey:carname];
			}
		}
	}
	self.imageDict = [NSDictionary dictionaryWithDictionary:dict];





	if (!self.selectedGridCells) // first time
	{
		self.selectedGridCells = [NSMutableSet set];

		// Create the spreadsheet in code.
		self.spreadSheetView = [[MMSpreadsheetView alloc] initWithNumberOfHeaderRows:1 numberOfHeaderColumns:0 frame:CGRectMake(0,40,self.view.bounds.size.width, self.view.bounds.size.height)];

		self.spreadSheetView.bounces = NO;
		// Register your cell classes.
		[self.spreadSheetView registerCellClass:[MMGridCell class] forCellWithReuseIdentifier:@"GridCell"];
		[self.spreadSheetView registerCellClass:[MMTopRowCell class] forCellWithReuseIdentifier:@"TopRowCell"];

		// Set the delegate & datasource for the spreadsheet view.
		self.spreadSheetView.delegate = self;
		self.spreadSheetView.dataSource = self;

		// Add the spreadsheet view as a subview. 
		[self.view addSubview:self.spreadSheetView];

		UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-20,self.view.bounds.size.width, 20)];
		[self.view addSubview:b];
		self.button = b;
		[self.button addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
		[self.button setBackgroundColor:[UIColor lightGrayColor]];
		[self.button setTitle:@"   All trademarks are the property of their respective owners" forState:UIControlStateNormal];
		[self.button setImage:@"close".namedImage forState:UIControlStateNormal];
		self.button.titleLabel.font = [UIFont systemFontOfSize:9];
		//b.tintColor = [UIColor lightGrayColor];
	}
	else
		[self.spreadSheetView reloadData]; // second time

	[self performSelectorInBackground:@selector(updateFromNet) withObject:nil];
}

- (void)updateFromNet
{
	NSString *dataFilePath = [cc.suppDir stringByAppendingPathComponent:@"data.csv"];
	NSString *picturesFilePath = [cc.suppDir stringByAppendingPathComponent:@"pictures.txt"];
	NSString *dateString = @"http://www.thecardb.net/date.txt".download.string;
	NSDate *dataDate = [NSDate dateWithString:dateString format:@"yyyy.MM.dd"];

	if ([kDataDateKey.defaultObject timeIntervalSinceDate:dataDate] < 0)
	{
		NSString *answer = @"http://www.thecardb.net/data.csv".download.string;
		[answer writeToFile:dataFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
		kDataDateKey.defaultObject = dataDate;
		[userDefaults synchronize];


		[@"http://www.thecardb.net/pictures.txt".download.string writeToFile:picturesFilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];

		[self performSelectorOnMainThread:@selector(loadData) withObject:nil waitUntilDone:NO];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.spreadSheetView fix];

	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)button:(UIButton *)sender
{
	[sender removeFromSuperview];

}

- (void)title:(UIButton *)sender
{
	[[[UIAlertView alloc] initWithTitle:@"CarDB" message:@"CarDB for iOS v1.0.1  © 2018 CoreCode Limited. Submit new/updated cars on www.thecardb.net." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

}


@end
