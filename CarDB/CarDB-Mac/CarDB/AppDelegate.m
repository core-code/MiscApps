//
//  AppDelegate.m
//  CarDB
//
//  Created by CoreCode on 07.02.14.
//  Copyright © 2018 CoreCode Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "Car.h"

NSArray *fuelNames;
NSArray *brandNames;
NSArray *propulsionNames;
NSArray *layoutNames;
NSArray *transmissionNames;
NSArray *engineNames;
NSArray *locationNames;

#define kKeys @[@"brand",@"modelname",@"weightEU",@"cylinderCount",@"displacementCCM",@"maxHorsepower",@"maxHorsepowerRRM",@"maxTorque",@"maxTorqueRPMLow",@"maxSpeed",@"accelerationTo100",@"elasticity80To120",@"fuelType",@"fuelConsumptionEUCombined",@"co2Emission",@"fuelTankSize",@"wheelsWidthFront",@"wheelsRatioFront",@"wheelsRadiusFront",@"wheelsWidthBack",@"wheelsRatioBack",@"wheelsRadiusBack",@"transmissionType",@"gearCount",@"engineLocation",@"poweredWheels",@"maxSeatCount",@"minPriceEU",@"adaptiveSuspension",@"doorCount",@"luggageSpaceMin",@"luggageSpaceMax",@"engineAspiration",@"cylinderLayout",@"widthMM",@"heightMM",@"lengthMM",@"wheelDistanceMM",@"minPriceUS"]

@interface MyRowTemplate : NSPredicateEditorRowTemplate
@end

@implementation MyRowTemplate
- (NSArray *)templateViews
{
    NSArray * views = [super templateViews];
    NSView *lastView = [views lastObject];
    NSRect viewFrame = lastView.frame;
    viewFrame.size.width = 80.0f;
    lastView.frame = viewFrame;
	return views;
}
@end

@implementation BaseValueTransformer
+ (BOOL)allowsReverseTransformation { return NO; }
+ (Class)transformedValueClass { return [NSString class]; }
@end
@implementation EuroValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" €"]; }
@end
@implementation DollarValueTransformer
- (id)transformedValue:(id)aValue { return ([aValue floatValue] == [aValue intValue]) ? [[aValue stringValue] stringByAppendingString:@" $"] : makeString(@"~ %i $", [aValue intValue]); }
@end
@implementation CM3ValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" cm³"]; }
@end
@implementation KGValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" kg"]; }
@end
@implementation LBSValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" lbs"]; }
@end
@implementation SValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" s"]; }
@end
@implementation KMHValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" km/h"]; }
@end
@implementation MPHValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" mph"]; }
@end
@implementation NMValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" nm"]; }
@end
@implementation LBFTValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" lb-ft"]; }
@end
@implementation MMValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" mm"]; }
@end
@implementation PSValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" ps"]; }
@end
@implementation BHPValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" bhp"]; }
@end
@implementation LValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" l"]; }
@end
@implementation MPGValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" mpg"]; }
@end
@implementation INValueTransformer
- (id)transformedValue:(id)aValue { return [[aValue stringValue] stringByAppendingString:@" in"]; }
@end
@implementation FuelValueTransformer
- (id)transformedValue:(id)aValue { return fuelNames[[aValue intValue]]; }
@end
@implementation FuelValueTransformers
- (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", fuelNames[[bla intValue]]]; } return ret.trimmedOfWhitespace; }
@end
@implementation PropValueTransformer
- (id)transformedValue:(id)aValue { return propulsionNames[[aValue intValue]]; }
@end
@implementation PropValueTransformers
- (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", propulsionNames[[bla intValue]]]; } return ret.trimmedOfWhitespace; }
@end
@implementation TransmissionValueTransformer
- (id)transformedValue:(id)aValue { return transmissionNames[[aValue intValue]]; }
@end
@implementation TransmissionValueTransformers
- (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", transmissionNames[[bla intValue]]]; } return ret.trimmedOfWhitespace; }
@end
@implementation LayoutValueTransformer
- (id)transformedValue:(id)aValue { return layoutNames[[aValue intValue]]; }
@end
@implementation LayoutValueTransformers
- (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", layoutNames[[bla intValue]]]; } return ret.trimmedOfWhitespace; }
@end
@implementation EngineValueTransformer
- (id)transformedValue:(id)aValue { return engineNames[[aValue intValue]]; }
@end
@implementation EngineValueTransformers
- (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", engineNames[[bla intValue]]]; } return ret.trimmedOfWhitespace; }
@end
@implementation LocationValueTransformer
- (id)transformedValue:(id)aValue { return locationNames[[aValue intValue]]; }
@end
@implementation LocationValueTransformers
- (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", locationNames[[bla intValue]]]; } return ret.trimmedOfWhitespace; }
@end
@implementation MultipleValueTransformers
- (id)transformedValue:(NSArray *)aValue { NSString *ret = @""; for (NSString *bla in aValue) { ret = [ret stringByAppendingFormat:@" %@", bla]; } return ret.trimmedOfWhitespace; }
@end



CONST_KEY(DataDate)


@implementation AppDelegate

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{kDataDateKey : [NSDate dateWithString:@"2013" format:@"yyyy"]}];
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPredicate) name:@"squirrelsarefunny" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rowsDidChange:) name:NSRuleEditorRowsDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:) name:NSTableViewSelectionDidChangeNotification object:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	cc = [CoreLib new];
	//[self rowsDidChange:nil];
	[self performSelector:@selector(loadData) withObject:nil afterDelay:0.1];

	[self.loadingProgress startAnimation:self];
}

- (void)loadData
{
	NSString *browserLanguage = [[NSLocale preferredLanguages][0] isEqualToString:@"de"] ? @"de" : @"us";
	NSString *currency = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"US"] ? @"usd" : @"eur";
	NSString *system = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"US"] ? @"us" : @"me";
	NSMutableSet *tmpBrands = [NSMutableSet set];

	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userLanguage"])
		browserLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLanguage"];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userCurrency"])
		currency = [[NSUserDefaults standardUserDefaults] objectForKey:@"userCurrency"];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userSystem"])
		system = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSystem"];

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

	if ([browserLanguage isEqualToString:@"de"])
	{
		NSArray * titles = @[@"Filtern", @"Standard", @"Einstellungen", @"Details", @"Vergleichen", @"Hinzufügen"];
		for (int i = 10; i < 16; i++)
		{
			id view = [[self.theWindow contentView] viewWithTag:i];
			[view setTitle:titles[i-10]];
		}
	}


	NSString *dataFilePath = [cc.suppDir stringByAppendingPathComponent:@"data.csv"];
	NSString *picturesFilePath = [cc.suppDir stringByAppendingPathComponent:@"pictures.txt"];
	NSString *databaseUpdateDate = [((NSDate *)kDataDateKey.defaultObject) stringUsingDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
	self.databaseDateLabel.stringValue = makeString(@"DataBase update: %@", databaseUpdateDate);

	const BOOL forceLocal = FALSE;
#ifndef DEBUG
	assert(!forceLocal);
#else
	if (forceLocal)
		cc_log(@"Warning: forceLocal ON");
#endif
	NSString *answer = (dataFilePath.fileExists && !forceLocal) ? dataFilePath.contents.string : @"data.csv".resourceURL.contents.string;
	NSArray <NSString *>*lines = answer.lines;
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

	if ([system isEqualToString:@"us"])
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

		NSArray *subviews1 = [[self.compareWindow contentView] subviews];
		NSArray *subviews2 = [[self.viewWindow contentView] subviews];
		NSArray *subviews = [subviews1 arrayByAddingObjectsFromArray:subviews2];
		for (int i = 0; i < [subviews count]; i++)
		{
			NSTextField *view = subviews[i];

			id repl = @{@"millimeter" : @"inch", @"kilogramm" : @"lbs", @"liter / 100km" : @"mpg"};

			if ([view isKindOfClass:[NSTextField class]] && [repl objectForKey:[view stringValue]])
				[view setStringValue:[repl objectForKey:[view stringValue]]];
		}
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
	[self setData:tmpCars];




	id templates = [NSMutableArray array];
	[templates addObject:[self compoundRowTemplate]];
	[templates addObject:[self rowTemplateWithStringEditorAndLeftKeys:@[[_translation objectForKey:@"modelname"]] options:NSCaseInsensitivePredicateOption|NSDiacriticInsensitivePredicateOption]];
	[templates addObject:[self rowTemplateWithLeftKeys:@[[_translation objectForKey:@"brand"]] rightConstants:brandNames]];
	[templates addObject:[self rowTemplateWithLeftKeys:@[[_translation objectForKey:@"fuelType"]] rightConstants:[fuelNames subarrayWithRange:NSMakeRange(1, [fuelNames count]-1)]]];
	[templates addObject:[self rowTemplateWithLeftKeys:@[[_translation objectForKey:@"engineAspiration"]] rightConstants:[engineNames subarrayWithRange:NSMakeRange(1, [engineNames count]-1)]]];
	[templates addObject:[self rowTemplateWithLeftKeys:@[[_translation objectForKey:@"poweredWheels"]] rightConstants:[propulsionNames subarrayWithRange:NSMakeRange(1, [propulsionNames count]-1)]]];
	[templates addObject:[self rowTemplateWithLeftKeys:@[[_translation objectForKey:@"transmissionType"]] rightConstants:[transmissionNames subarrayWithRange:NSMakeRange(1, [transmissionNames count]-1)]]];
	[templates addObject:[self rowTemplateWithLeftKeys:@[[_translation objectForKey:@"cylinderLayout"]] rightConstants:[layoutNames subarrayWithRange:NSMakeRange(1, [layoutNames count]-1)]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"maxHorsepower"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"maxTorque"]]]];
	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:@[[_translation objectForKey:@"maxSpeed"]]]];
	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:@[[_translation objectForKey:@"accelerationTo100"]]]];
	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:@[[_translation objectForKey:@"elasticity80To120"]]]];
	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:@[[_translation objectForKey:@"fuelConsumptionEUCombined"]]]];
	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:@[[_translation objectForKey:@"heightToWidth"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"gearCount"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"doorCount"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"maxSeatCount"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"luggageSpaceMin"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"fuelTankSize"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"co2Emission"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"weightEU"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"cylinderCount"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"displacementCCM"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:([currency isEqualToString:@"usd"]) ? @"minPriceUS" : @"minPriceEU"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"widthMM"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"heightMM"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"lengthMM"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"wheelDistanceMM"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"horsepowerPerTonne"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:@[[_translation objectForKey:@"horsepowerPerDisplacement"]]]];
	[_editor setNestingMode:NSRuleEditorNestingModeList];
	[_editor setRowTemplates:templates];
	while ([_editor numberOfRows]) [_editor removeRowAtIndex:0];
	[_editor addRow:self];


	id priceKey = @"minPriceEU";
	if ([currency isEqualToString:@"usd"])
	{
		priceKey = @"minPriceUS";
		[self.usPriceInfoLabel setHidden:NO];
	}

	id columns = @[@"brand",@"modelname",priceKey,@"cylinderCount",@"displacementCCM",@"maxHorsepower",@"maxTorque",@"maxSpeed",@"accelerationTo100", @"horsepowerPerTonne", @"horsepowerPerDisplacement", @"heightToWidth", @"weightEU", @"fuelConsumptionEUCombined", @"luggageSpaceMin", @"fuelType", @"poweredWheels", @"engineLocation", @"doorCount",@"maxSeatCount", @"co2Emission",@"fuelTankSize",@"transmissionType",@"gearCount",@"cylinderLayout", @"engineAspiration" ,@"widthMM",@"heightMM",@"lengthMM",@"wheelDistanceMM"];
	int widthsDE[] = {80,230,60,52,58,45,78,68,65,55,55,75,60,65,70,65,60,70,45,40,40,40,70,45,40,65,60,60,60,70};
	int widthsEN[] = {80,230,80,60,80,50,78,68,65,55,55,90,60,80,70,65,60,70,45,40,40,45,85,50,45,65,60,60,60,70};

	while ([_tableView tableColumns].count)
		[_tableView removeTableColumn:[_tableView tableColumns][0]];

	for (int i = 0; i < [columns count]; i++)
	{
		id key = columns[i];


		NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:key];
		int num = ([browserLanguage isEqualToString:@"de"]) ? widthsDE[i] : widthsEN[i];
		if (num > 0)
			[column setWidth:(float)num*1.1];

		//	[column setMinWidth:50];
		//	[column setMaxWidth:50];
		//	[column setSortDescriptorPrototype:[[NSSortDescriptor alloc] initWithKey:key ascending:YES selector:@selector(compare:)]];
		[[column headerCell] setStringValue:[_translation objectForKey:key]];

		[_tableView addTableColumn:column];

		NSDictionary *dict = nil;


		if ([key isEqualToString:@"minPriceEU"]) dict = @{NSValueTransformerNameBindingOption : @"EuroValueTransformer"};
		if ([key isEqualToString:@"minPriceUS"]) dict = @{NSValueTransformerNameBindingOption : @"DollarValueTransformer"};
		if ([key isEqualToString:@"displacementCCM"]) dict = @{NSValueTransformerNameBindingOption : @"CM3ValueTransformer"};
		if ([key isEqualToString:@"maxHorsepower"]) dict = @{NSValueTransformerNameBindingOption : ([system isEqualToString:@"us"]) ? @"BHPValueTransformer" : @"PSValueTransformer"};
		if ([key isEqualToString:@"maxTorque"]) dict = @{NSValueTransformerNameBindingOption : ([system isEqualToString:@"us"]) ? @"LBFTValueTransformer" : @"NMValueTransformer"};
		if ([key isEqualToString:@"maxSpeed"]) dict = @{NSValueTransformerNameBindingOption : ([system isEqualToString:@"us"]) ? @"MPHValueTransformer" : @"KMHValueTransformer"};
		if ([key isEqualToString:@"accelerationTo100"]) dict = @{NSValueTransformerNameBindingOption : @"SValueTransformer"};
		if ([key isEqualToString:@"weightEU"]) dict = @{NSValueTransformerNameBindingOption : ([system isEqualToString:@"us"]) ? @"LBSValueTransformer" : @"KGValueTransformer"};
		if ([key isEqualToString:@"fuelConsumptionEUCombined"]) dict = @{NSValueTransformerNameBindingOption : ([system isEqualToString:@"us"]) ? @"MPGValueTransformer" : @"LValueTransformer"};
		if ([key isEqualToString:@"luggageSpaceMin"]) dict = @{NSValueTransformerNameBindingOption : @"LValueTransformer"};
		if ([key isEqualToString:@"fuelType"]) dict = @{NSValueTransformerNameBindingOption : @"FuelValueTransformer"};
		if ([key isEqualToString:@"poweredWheels"]) dict = @{NSValueTransformerNameBindingOption : @"PropValueTransformer"};
		if ([key isEqualToString:@"fuelTankSize"]) dict = @{NSValueTransformerNameBindingOption : @"LValueTransformer"};
		if ([key isEqualToString:@"transmissionType"]) dict = @{NSValueTransformerNameBindingOption : @"TransmissionValueTransformer"};
		if ([key isEqualToString:@"engineLocation"]) dict = @{NSValueTransformerNameBindingOption : @"LocationValueTransformer"};
		if ([key isEqualToString:@"cylinderLayout"]) dict = @{NSValueTransformerNameBindingOption : @"LayoutValueTransformer"};
		if ([key isEqualToString:@"engineAspiration"]) dict = @{NSValueTransformerNameBindingOption : @"EngineValueTransformer"};
		if ([key hasSuffix:@"MM"]) dict = @{NSValueTransformerNameBindingOption : ([system isEqualToString:@"us"]) ? @"INValueTransformer" : @"MMValueTransformer"};

#ifdef DEBUG
		dict = [dict dictionaryBySettingValue:@YES forKey:NSConditionallySetsEditableBindingOption];
#endif

		[column bind:NSValueBinding toObject:_arrayController withKeyPath:[@"arrangedObjects." stringByAppendingString:key] options:dict];
	}


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


	self.carcountLabel.stringValue = makeString(@"%lu cars", (unsigned long)[[_arrayController arrangedObjects] count]);
	[_tableView setDoubleAction:@selector(viewcarClicked:)];
	[_tableView setTarget:self];

	[self.appView setHidden:NO];
	[self.loadingProgress stopAnimation:self];

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
		NSError *err;
		NSString *answer = @"http://www.thecardb.net/data.csv".download.string;
		[answer writeToFile:dataFilePath atomically:YES encoding:NSUTF8StringEncoding error:&err];
		kDataDateKey.defaultObject = dataDate;
		[userDefaults synchronize];


		[@"http://www.thecardb.net/pictures.txt".download.string writeToFile:picturesFilePath atomically:YES encoding:NSUTF8StringEncoding error:&err];

		[self performSelectorOnMainThread:@selector(loadData) withObject:nil waitUntilDone:NO];
	}
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[self.theWindow makeKeyAndOrderFront:self];

	return FALSE;
}

- (IBAction)openWebsite:(id)sender
{
#ifdef DEBUG
	[self resetClicked:nil];
	NSMutableString *tmp = [NSMutableString new];
	for (Car *car in [_arrayController arrangedObjects])
	{
		for (NSString *key in kKeys)
		{
			id value = [car valueForKey:key];
			[tmp appendString:[value isKindOfClass:[NSNumber class]] ? [value stringValue] : value];
			[tmp appendString:@","];
		}
		[tmp appendString:@"\n"];
	}
	[tmp writeToFile:@"~/Desktop/out.csv".expanded atomically:YES encoding:NSUTF8StringEncoding error:NULL];
#else
	[@"http://www.thecardb.net".URL open];
#endif
}

- (void)rowsDidChange:(NSNotification *)notification
{
	NSRect rectA = [_appView frame];
	NSRect rect = [_scrollView frame];
	NSRect newRect = CGRectMake(rect.origin.x, rectA.size.height - 9 - ([_editor numberOfRows] * 25),
								rect.size.width, [_editor numberOfRows] * 25 + 1);
	[_scrollView setFrame:newRect];


	NSRect rectT = [_tableScrollView frame];
	NSRect newRectT = CGRectMake(rectT.origin.x, rectT.origin.y,
							  rectT.size.width, rectA.size.height - 8 - ([_editor numberOfRows] * 25));
	[_tableScrollView setFrame:newRectT];

	//[self refreshPredicate];
}

- (void)refreshPredicate
{
	[_editor reloadPredicate];
	id pred = [_editor predicate];
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

	NSArray *keys = [_detranslation allKeys];
	keys = [keys sortedArrayByKey:@"length" ascending:NO];


	for (int i = 0; i < keys.count; i++)
	{
		id key = keys[i];
		id value = [_detranslation objectForKey:key];
		text = [text stringByReplacingOccurrencesOfString:[key stringByAppendingString:@" "] withString:[value stringByAppendingString:@" "]];
	}

	text = [text stringByReplacingOccurrencesOfString:@"CONTAINS[cd] 0" withString:@"!= 0"];
	LOG(text);
	//[arrayController setFilterPredicate:pred];
	[_arrayController setFilterPredicate:[NSPredicate predicateWithFormat:text]];

	//	[arrayController rearrangeObjects];
	/*	for (int i = 0, count = [[arrayController arrangedObjects] count]; i < count; i++)
	 {
	 id obj = [arrayController arrangedObjects][i];
	 text = text + [obj modelname];

	 [predicateField setStringValue:text];
	 }*/

	self.carcountLabel.stringValue = makeString(@"%lu cars", (unsigned long)[[_arrayController arrangedObjects] count]);
}

#pragma mark - IBAction

- (IBAction)languageClicked:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:(@[@"",@"en",@"de"][[sender tag]]) forKey:@"userLanguage"];

	alert_apptitled(@"Changes will take effect on next load of the Car Database", @"OK", nil, nil);

}

- (IBAction)currencyClicked:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:@[@"",@"usd",@"eur"][[sender tag]] forKey:@"userCurrency"];


	alert_apptitled(@"Changes will take effect on next load of the Car Database", @"OK", nil, nil);
}

- (IBAction)systemClicked:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:@[@"",@"us",@"me"][[sender tag]] forKey:@"userSystem"];
	alert_apptitled(@"Changes will take effect on next load of the Car Database", @"OK", nil, nil);
}

- (IBAction)refreshClicked:(id)sender
{
	[self refreshPredicate];
}

- (IBAction)resetClicked:(id)sender
{
	while ([_editor numberOfRows] > 1)
		[_editor removeRowAtIndex:0];
	[_editor addRow:nil];
	[_editor removeRowAtIndex:0];

	[_arrayController setFilterPredicate:nil];
	
	self.carcountLabel.stringValue = makeString(@"%lu cars", (unsigned long)[[_arrayController arrangedObjects] count]);
}

- (IBAction)openURL:(id)sender
{
	[cc openURL:(openChoice)[[sender valueForKey:@"tag"] intValue]];
}


#pragma mark - View Car

- (void)selectionDidChange:(NSNotification *)notificatio
{
	[self updateImage];
}

- (IBAction)viewcarClicked:(id)sender
{
	[self.arrayController setSelectionIndex:[self.arrayController selectionIndex]];

	// reset view
	for (int i = 3; i <= 39; i++)
	{
		id view = [[self.viewWindow contentView] viewWithTag:i];

		[view setEnabled:NO];
		//[view unbind:NSValueBinding];
	}
	id button = [[self.viewWindow contentView] viewWithTag:90];
	[button setTitle:@"Update Car"];

	[self.viewWindow makeKeyAndOrderFront:self];

	[self updateImage];
}

- (IBAction)imagespinnerClicked:(id)sender
{
	[self updateImage];
}

- (void)updateImage
{
	if (![self.viewWindow isVisible])
		return;

	Car *car = [_arrayController selectedObjects][0];
	self.images = [self.imageDict objectForKey:[car modelname]];

	if (!self.images)
	{
		NSURLRequest *r = makeString(@"https://www.bing.com/images/search?q=%@ %@", [car brand], [car modelname]).escaped.URL.request;
		[[self.webView mainFrame] loadRequest:r];
		[self.imageView setHidden:YES];
		[self.webView setHidden:NO];

	}
	else
	{
		unsigned long indexCount = ([self.imageStepper integerValue]) % [self.images count];
		NSImage *image = [[NSImage alloc] initWithContentsOfURL:[self.images[indexCount] URL]];
		[self.imageView setImage:image];
		[self.imageView setHidden:NO];
		[self.webView setHidden:YES];
	}
}

- (IBAction)updatecarClicked:(NSButton *)sender
{
	NSNumberFormatter *numberFormatterEN = [[NSNumberFormatter alloc] init];
	[numberFormatterEN setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatterEN setUsesGroupingSeparator:NO];
	[numberFormatterEN setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];

	NSNumberFormatter *numberFormatterNative = [[NSNumberFormatter alloc] init];
	[numberFormatterNative setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatterNative setLocale:[NSLocale currentLocale]];

	if ([[sender title] isEqualToString:@"Submit Car"])
	{
		NSString *str = @"mailto:feedback@corecode.io?subject=CarDB-UpdateCar&body=";
		for (int i = 1; i <= 39; i++)
		{
			id view = [[self.viewWindow contentView] viewWithTag:i];

			if ([view isKindOfClass:[NSTextField class]])
			{
				if (i<=2)
					str = [str stringByAppendingString:[view stringValue]];
				else
				{
					NSString *numstrIn = [view stringValue];
					NSNumber *num = [numberFormatterNative numberFromString:numstrIn];
					NSString *numstrOut = [numberFormatterEN stringFromNumber:num];

					str = [str stringByAppendingString:numstrOut];
				}
			}
			else if ([view isKindOfClass:[NSPopUpButton class]])
				str = [str stringByAppendingString:@([view indexOfSelectedItem]).stringValue];
			else if ([view isKindOfClass:[NSButton class]])
			{
				if ([view state] == NSOffState)
					str = [str stringByAppendingString:@"0"];
				else
					str = [str stringByAppendingString:@"1"];
			}
			str = [str stringByAppendingString:@","];
		}
		if (![[NSWorkspace sharedWorkspace] openURL:str.escaped.URL])
		{
			id msg = [@"Could not open your mail client. Please send the following information to feedback@corecode.io to have the car added:\n" stringByAppendingString: str];

			alert_apptitled(msg, @"OK", nil, nil);

			return;
		}

		[self.viewWindow orderOut:self];

		alert_apptitled(@"Thanks we will process the e-mail with your updates as soon as possible.", @"OK", nil, nil);

	}
	else
	{
		[sender setTitle:@"Submit Car"];

		for (int i = 3; i <= 39; i++)
		{
			id view = [[self.viewWindow contentView] viewWithTag:i];

			[view setEnabled:YES];
			if ([view isKindOfClass:[NSTextField class]])
				[view setEditable:YES];
		}
	}
}

#pragma mark - Add Car

- (IBAction)addcarClicked:(id)sender
{
	[self.addWindow makeKeyAndOrderFront:self];


	for (unsigned long i = 0, count = [brandNames count]; i < count; i++)
	{
		[self.brandsPopup addItemWithTitle:brandNames[i]];
	}
}

- (IBAction)submitcarClicked:(id)sender
{
	if ([self.isPublicCheckbox state] == NSOffState)
	{
		alert_apptitled(@"Sorry we can only accept contributions in the public domain", @"OK", nil, nil);
		return;
	}
	if ([self.isOnsaleCheckbox state] == NSOffState)
	{
		alert_apptitled(@"Sorry this database is only for cars currently on sale", @"OK", nil, nil);
		return;
	}

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[numberFormatter setUsesGroupingSeparator:NO];
	[numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];


    NSString * str = @"mailto:feedback@corecode.io?subject=CarDB-NewCar&body=";
    str = [str stringByAppendingString:[self.brandsPopup titleOfSelectedItem]];
	for (int i = 2; i <= 39; i++)
	{
		str = [str stringByAppendingString:@","];
		id view = [[self.addWindow contentView] viewWithTag:i];

		if ([view isKindOfClass:[NSTextField class]])
		{
			str = [str stringByAppendingString:i > 2 ? [numberFormatter stringFromNumber:@([view floatValue])] : [view stringValue]];
		}
		else if ([view isKindOfClass:[NSPopUpButton class]])
			str = [str stringByAppendingString:@([view indexOfSelectedItem]).stringValue];
		else if ([view isKindOfClass:[NSButton class]])
		{
			if ([view state] == NSOffState)
				str = [str stringByAppendingString:@"0"];
			else
				str = [str stringByAppendingString:@"1"];
		}
	}
	if (![[NSWorkspace sharedWorkspace] openURL:str.escaped.URL])
	{
		id msg = [@"Could not open your mail client. Please send the following information to feedback@corecode.io to have the car added:\n" stringByAppendingString:str];
		alert_apptitled(msg, @"OK", nil, nil);

		return;
	}


	[self.addWindow orderOut:self];

	alert_apptitled(@"Thanks we will process the e-mail with your updates as soon as possible.", @"OK", nil, nil);
}

#pragma mark - Compare Car

- (IBAction)compareClicked:(id)sender
{
	[self.compareWindow makeKeyAndOrderFront:self];
}

#pragma mark - SPPredicateEditor helpers

- (NSPredicateEditorRowTemplate *)compoundRowTemplate
{
	return [[NSPredicateEditorRowTemplate alloc] initWithCompoundTypes:@[@1,@2,@0]];
}

- (NSPredicateEditorRowTemplate *)rowTemplateWithStringEditorAndLeftKeys:(NSArray *)leftKeys options:(NSInteger)options
{
	if(!leftKeys)
		return nil;

	id operators = @[
					 @(NSContainsPredicateOperatorType),
					 @(NSEqualToPredicateOperatorType),
					 @(NSNotEqualToPredicateOperatorType),
					 @(NSBeginsWithPredicateOperatorType),
					 @(NSEndsWithPredicateOperatorType)
					 ];

	id leftExpressions = [NSMutableArray array];
	for(int i = 0;i<[leftKeys count];i++)
		[leftExpressions addObject:[NSExpression expressionForKeyPath:leftKeys[i]]];

	return [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:leftExpressions
											rightExpressionAttributeType:NSStringAttributeType
																modifier:0
															   operators:operators
																 options:options];
}

- (NSPredicateEditorRowTemplate *)rowTemplateWithLeftKeys:(NSArray *)leftKeys rightConstants:(NSArray *)rightConstants
{
	id operators = @[@(NSEqualToPredicateOperatorType),@(NSNotEqualToPredicateOperatorType)];

	id leftExpressions = [NSMutableArray array];
	for(int i = 0;i<[leftKeys count];i++)
		[leftExpressions addObject:[NSExpression expressionForKeyPath:leftKeys[i]]];

	id constants = [NSMutableArray array];
	for(int i = 0;i<[rightConstants count];i++)
		[constants addObject:[NSExpression expressionForConstantValue:rightConstants[i]]];

	return [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:leftExpressions
														rightExpressions:constants
																modifier:0
															   operators:operators
																 options:0];
}

- (NSPredicateEditorRowTemplate *)rowTemplateWithBooleanEditorAndLeftKeys:(NSArray *)leftKeys
{
	id operators = @[@(NSEqualToPredicateOperatorType), @(NSNotEqualToPredicateOperatorType)];

	id leftExpressions = [NSMutableArray array];
	for(int i = 0;i<[leftKeys count];i++)
		[leftExpressions addObject:[NSExpression expressionForKeyPath:leftKeys[i]]];

	return [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:leftExpressions
											rightExpressionAttributeType:NSBooleanAttributeType
																modifier:0
															   operators:operators
																 options:0];
}

- (NSPredicateEditorRowTemplate *)rowTemplateWithFloatEditorAndLeftKeys:(NSArray *)leftKeys
{
	id operators = @[
					 @(NSGreaterThanOrEqualToPredicateOperatorType),
					 @(NSLessThanOrEqualToPredicateOperatorType),
					 @(NSEqualToPredicateOperatorType),
					 @(NSNotEqualToPredicateOperatorType)
					 ];

	id leftExpressions = [NSMutableArray array];
	for(int i = 0;i<[leftKeys count];i++)
		[leftExpressions addObject:[NSExpression expressionForKeyPath:leftKeys[i]]];

	return [[MyRowTemplate alloc] initWithLeftExpressions:leftExpressions
											rightExpressionAttributeType:NSDoubleAttributeType
																modifier:0
															   operators:operators
																 options:0];
}

- (NSPredicateEditorRowTemplate *)rowTemplateWithIntegerEditorAndLeftKeys:(NSArray *)leftKeys
{
	id operators = @[
					 @(NSGreaterThanOrEqualToPredicateOperatorType),
					 @(NSGreaterThanPredicateOperatorType),
					 @(NSLessThanOrEqualToPredicateOperatorType),
					 @(NSLessThanPredicateOperatorType),
					 @(NSEqualToPredicateOperatorType),
					 @(NSNotEqualToPredicateOperatorType)
					 ];

	id leftExpressions = [NSMutableArray array];
	for(int i = 0;i<[leftKeys count];i++)
		[leftExpressions addObject:[NSExpression expressionForKeyPath:leftKeys[i]]];

	return [[MyRowTemplate alloc] initWithLeftExpressions:leftExpressions
											rightExpressionAttributeType:NSInteger64AttributeType
																modifier:0
															   operators:operators
																 options:0];
}

- (IBAction)openReadMe:(id)sender
{
	[@"Read Me.rtf".resourceURL open];
}

@end

// TODO: fix 0-62mph not renamed in english by switch to metric system

@interface JMApplication : NSApplication
@end

@implementation JMApplication

- (void)sendEvent:(NSEvent *)event
{
    if (([event type] == NSEventTypeKeyDown) &&
        (([event keyCode] == 36 && ([event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask) == 0) ||
         ([event keyCode] == 76 &&([event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask) == NSEventModifierFlagNumericPad)))
	{
		NSView *view = (NSTextView *)[[event window] firstResponder];

		if ([view isKindOfClass:[NSTextView class]])
		{
			while (view)
			{
				view = [view superview];

				if ([view isKindOfClass:[NSPredicateEditor class]])
				{
					[notificationCenter postNotificationName:@"squirrelsarefunny" object:nil userInfo:nil];
				}
			}
		}
	}

    [super sendEvent:event];
}
@end


#if !defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && !defined(DEBUG)
#warning Time-Limited Release-Beta build
#elif !defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && defined(DEBUG)
#warning Time-Limited Debug-Beta build
#elif !defined(APPSTORE_VALIDATERECEIPT) && defined(TRYOUT) && !defined(DEBUG)
#warning Tryout build
#elif !defined(APPSTORE_VALIDATERECEIPT) && defined(TRYOUT) && defined(DEBUG)
#error invalid_config
#elif defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && !defined(DEBUG)
#warning MacAppStore build
#elif defined(APPSTORE_VALIDATERECEIPT) && !defined(TRYOUT) && defined(DEBUG)
#error invalid_config
#elif defined(APPSTORE_VALIDATERECEIPT) && defined(TRYOUT) && !defined(DEBUG)
#error invalid_config
#elif defined(APPSTORE_VALIDATERECEIPT) && defined(TRYOUT) && defined(DEBUG)
#error invalid_config
#endif
