/*
 * AppController.j
 * CarDB
 *
 * Created by CoreCode on December 1, 2012.
 * Copyright 2012 - 2014, CoreCode All rights reserved.
 */

// TODO: cw, cwa, weightdistribution, nordschleife, hockenheim, cabriotype?
@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>
@import <AppKit/CPScrollView.j>
@import <AppKit/CPSegmentedControl.j>
@import <AppKit/CPTableColumn.j>
@import <AppKit/CPRuleEditor_Constants.j>
@import <SPPredicateEditor/SPPredicateEditor.j>
@import "Car.j"

var fuelNames = [""];
var brandNames = [""];
var propulsionNames = [""];
var layoutNames = [""];
var transmissionNames = [""];
var engineNames = [""];
var locationNames = [""];


@implementation BaseValueTransformer : CPValueTransformer { }
+ (BOOL)allowsReverseTransformation { return NO; }
+ (Class)transformedValueClass { return [CPString class]; }
@end
@implementation EuroValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " €"; }
@end
@implementation DollarValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue {  return (aValue == Math.round(aValue)) ? (aValue + " $") : ("~" + Math.round(aValue) + " $");}
@end
@implementation CM3ValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " cm³"; }
@end
@implementation KGValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " kg"; }
@end
@implementation LBSValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " lbs"; }
@end
@implementation SValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " s"; }
@end
@implementation KMHValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " km/h"; }
@end
@implementation MPHValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " mph"; }
@end
@implementation NMValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " nm"; }
@end
@implementation LBFTValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " lb-ft"; }
@end
@implementation MMValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " mm"; }
@end
@implementation PSValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " ps"; }
@end
@implementation BHPValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " bhp"; }
@end
@implementation LValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " l"; }
@end
@implementation MPGValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " mpg"; }
@end
@implementation INValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return aValue + " in"; }
@end
@implementation FuelValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return fuelNames[aValue]; }
@end
@implementation FuelValueTransformers : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { var ret = ""; for (var i=0; i<aValue.length; i++) { ret += fuelNames[aValue[i]] + " "; } return ret; }
@end
@implementation PropValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return propulsionNames[aValue]; }
@end
@implementation PropValueTransformers : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { var ret = ""; for (var i=0; i<aValue.length; i++) { ret += propulsionNames[aValue[i]] + " "; } return ret; }
@end
@implementation TransmissionValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return transmissionNames[aValue]; }
@end
@implementation TransmissionValueTransformers : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { var ret = ""; for (var i=0; i<aValue.length; i++) { ret += transmissionNames[aValue[i]] + " "; } return ret; }
@end
@implementation LayoutValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return layoutNames[aValue]; }
@end
@implementation LayoutValueTransformers : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { var ret = ""; for (var i=0; i<aValue.length; i++) { ret += layoutNames[aValue[i]] + " "; } return ret; }
@end
@implementation EngineValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return engineNames[aValue]; }
@end
@implementation EngineValueTransformers : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { var ret = ""; for (var i=0; i<aValue.length; i++) { ret += engineNames[aValue[i]] + " "; } return ret; }
@end
@implementation LocationValueTransformer : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { return locationNames[aValue]; }
@end
@implementation LocationValueTransformers : BaseValueTransformer { }
- (id)transformedValue:(id)aValue { var ret = ""; for (var i=0; i<aValue.length; i++) { ret += locationNames[aValue[i]] + " "; } return ret; }
@end

@implementation AppController : CPObject
{
   	@outlet CPWindow theWindow; //this "outlet" is connected automatically by the Cib
   	@outlet CPWindow addWindow;
   	@outlet CPWindow viewWindow;
   	@outlet CPWindow compareWindow;
   	@outlet CPWindow aboutWindow;
	@outlet CPWebView webView;
	@outlet CPScrollView scrollView;
	@outlet CPScrollView tableScrollView;
	@outlet CPTableView tableView;
	@outlet CPProgressIndicator loadingProgress;
	@outlet CPButton isPublicCheckbox;
	@outlet CPButton isOnsaleCheckbox;
	@outlet CPPopUpButton brandsPopup;
  	@outlet CPStepper imageStepper;
 	@outlet SPPredicateEditor editor;
	@outlet CPView bgView;
	@outlet CPView appView;
	@outlet CPImageView imageView;
	@outlet CPArrayController arrayController;
	@outlet CPTextField usPriceInfoLabel;
	@outlet CPTextField dateLabel;
	@outlet CPWebView adView;

	CPDictionary translation @accessors;
	CPDictionary detranslation @accessors;
	CPDictionary imageDict @accessors;
	CPArray images @accessors;
	CPArray data @accessors;
}

- (void)awakeFromCib
{
	[theWindow setFullPlatformWindow:YES];

	[CPScrollView setGlobalScrollerStyle:CPScrollerStyleOverlay];
	[scrollView setBackgroundColor:[CPColor colorWithHexString:"ededed"]];
   	[[theWindow contentView] setBackgroundColor:[CPColor colorWithHexString:"ededed"]];
    //[bgView setBackgroundColor:[CPColor colorWithHexString:"777777"]];
    //[appView setBackgroundColor:[CPColor colorWithHexString:"ededed"]];

	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPredicate) name:"squirrelsarefunny" object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(rowsDidChange:) name:SPRuleEditorRowsDidChangeNotification object:nil];
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:) name:CPTableViewSelectionDidChangeNotification object:nil];
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var dom = appView._DOMElement;
    dom.style.borderRadius = "10px";
    dom.style.boxShadow = "rgba(0, 0, 0, 0.5) 0px 0px 30px";
    dom.style.mozBoxShadow = "rgba(0, 0, 0, 0.5) 0px 0px 30px";
	dom.style.webkitBoxShadow = "rgba(0, 0, 0, 0.5) 0px 0px 30px";

	//[self rowsDidChange:nil];


	[self performSelector:@selector(loadData) withObject:nil afterDelay:0.1];

	[self.loadingProgress startAnimation:self];

	[self.adView setMainFrameURL:[CPURL URLWithString:"http://thecardb.net/ads.html"]];
    [self.adView setScrollMode:CPWebViewScrollNone];
}

- (void)loadData
{
	var fullbrowserLanguage = (navigator.language) ? navigator.language : navigator.userLanguage;
	var browserLanguage = fullbrowserLanguage.substring(0,2);
	var currency = fullbrowserLanguage == "en-US" ? "usd" : "eur";
	var system = fullbrowserLanguage == "en-US" ? "us" : "me";
	var tmpBrands = [CPSet set];

	if ([[CPUserDefaults standardUserDefaults] objectForKey:"userLanguage"])
		browserLanguage = [[CPUserDefaults standardUserDefaults] objectForKey:"userLanguage"];
	if ([[CPUserDefaults standardUserDefaults] objectForKey:"userCurrency"])
		currency = [[CPUserDefaults standardUserDefaults] objectForKey:"userCurrency"];
	if ([[CPUserDefaults standardUserDefaults] objectForKey:"userSystem"])
		system = [[CPUserDefaults standardUserDefaults] objectForKey:"userSystem"];

	if (browserLanguage == "de") 	fuelNames = ["", "Benzin", "Diesel", "Elektro"];
	else							fuelNames = ["", "Petrol", "Diesel", "Electric"];
	if (browserLanguage == "de") 	propulsionNames = ["", "Front", "Heck", "Allrad"];
	else							propulsionNames = ["", "Front", "Rear", "AWD"];
	if (browserLanguage == "de") 	transmissionNames = ["", "Manuell", "Automatik", "Auto. (DKG)"];
	else							transmissionNames = ["", "Manual", "Automatic", "Auto. (DCT)"];
	if (browserLanguage == "de") 	engineNames = ["Saug", "Saug", "Turbo", "Kompressor", "Hybrid", "Elektro"];
	else							engineNames = ["Natural", "Natural", "Turbo", "Super", "Hybrid", "Electric"];
	if (browserLanguage == "de") 	locationNames = ["", "Front", "Mitte", "Heck"];
	else							locationNames = ["", "Front", "Mid", "Rear"];

	layoutNames =  ["", "R", "V", "B", "W"];

	var carPropertyKeysStored = ["brand","modelname","weightEU","cylinderCount","displacementCCM","maxHorsepower","maxHorsepowerRRM","maxTorque","maxTorqueRPMLow","maxSpeed","accelerationTo100","elasticity80To120","fuelType","fuelConsumptionEUCombined","co2Emission","fuelTankSize","wheelsWidthFront","wheelsRatioFront","wheelsRadiusFront","wheelsWidthBack","wheelsRatioBack","wheelsRadiusBack","transmissionType","gearCount","engineLocation","poweredWheels","maxSeatCount","minPriceEU","adaptiveSuspension","doorCount","luggageSpaceMin","luggageSpaceMax","engineAspiration","cylinderLayout","widthMM","heightMM","lengthMM","wheelDistanceMM","minPriceUS"];
	var carPropertyKeysDerived = ["horsepowerPerTonne", "horsepowerPerDisplacement", "heightToWidth"]
	var keys = carPropertyKeysStored.concat(carPropertyKeysDerived);
	var deTranslations = ["Marke", "Modell", "Gewicht", "Zylinder", "Hubraum", "PS", "RPM max. PS", "Drehmoment", "RPM max. DM", "Max. km/h", "0-100km/h", "80-120km/h", "Treibstoff", "Verbrauch", "CO2", "Tank", "Reifenbreite Vorne", "Reifenverhältnis Vorne", "Reifenradius Vorne", "Reifenbreite Hinten", "Reifenverhältnis Hinten", "Reifenradius Hinten", "Getriebe", "Gänge", "Motorplatzierung", "Antrieb", "Sitze", "Min. Preis", "Adaptives Fahrwerk", "Türen", "Kofferraum", "Kofferraum Max.", "Aufladung", "Motor", "Breite", "Höhe", "Länge", "Radstand", "Min. Preis", "PS / kg", "PS / cm³", "Höhe / Breite"];
	var enTranslations = ["brand", "modelname", "weight", "cylinders", "displacement", "power", "max power RPM", "torque", "max torque rom", "top speed", "0-62mph", "62-75mph", "fuel", "consumption", "CO2", "capacity", "wheel width front", "wheel ratio front", "wheel radius front", "wheel width back", "wheel ratio back", "wheel width back", "transmission", "gears", "engine location", "drivetrain", "seats", "price (EU)", "adaptive suspension", "doors", "luggage", "luggage max", "aspiration", "engine", "width", "height", "length", "wheelbase", "price", "P2W", "HP / cm³", "height / width"];

	if (browserLanguage == "de")	[self setTranslation:[CPDictionary dictionaryWithObjects:deTranslations forKeys:keys]];
	else										[self setTranslation:[CPDictionary dictionaryWithObjects:enTranslations forKeys:keys]];
	if (browserLanguage == "de")	[self setDetranslation:[CPDictionary dictionaryWithObjects:keys forKeys:deTranslations]];
	else										[self setDetranslation:[CPDictionary dictionaryWithObjects:keys forKeys:enTranslations]];

	if (browserLanguage == "de")
	{
		var titles =  ["Filtern", "Standard", "Einstellungen", "Details", "Vergleichen", "Hinzufügen"];
		for (var i = 10; i < 16; i++)
		{
			var view = [[self.theWindow contentView] viewWithTag:i];
			[view setTitle:titles[i-10]];
		}
	}



	var urldata = [CPURLConnection sendSynchronousRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:"http://www.thecardb.net/data.csv"]] returningResponse:nil];
	var answer = [urldata rawString];
	var lines = [answer componentsSeparatedByCharactersInSet:[CPCharacterSet characterSetWithCharactersInString:"\r\n"]];
    var tmpCars = [[CPMutableArray alloc] init];
    for (var i = 0, count = [lines count]; i < count; i++)
    {
		var car = [[Car alloc] init];
		var line = lines[i];
	    var components = [line componentsSeparatedByCharactersInSet:[CPCharacterSet characterSetWithCharactersInString:","]];
		if ([components count] > 30)
		{
			for (var b = 0, c = [components count]; b < c, b < 39; b++)
			{
	    		var component = components[b];
	    		var name = carPropertyKeysStored[b];
	    		if ([component length] == 0)
					[car setValue:[CPNumber numberWithFloat:0.0] forKey:name];
				else if ([component floatValue] > 0.0 && b >= 2)
					[car setValue:[CPNumber numberWithFloat:[component floatValue]] forKey:name];
				else
					[car setValue:component forKey:name];
			}


			if ([car minPriceUS] == 0)
				[car setMinPriceUS:(([car minPriceEU] / 1000) * 1000) + 0.1]; // rounds down but thats ok
			[tmpBrands addObject:[car brand]];
			[tmpCars addObject:car];

		}
	}
	brandNames = [tmpBrands sortedArrayUsingDescriptors:@[[CPSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];

	if (system == "us")
	{
		for (var i = 0, count = [tmpCars count]; i < count; i++)
		{
			var car = tmpCars[i];

			[car setMaxTorque:Math.round([car maxTorque] * 0.7375621483695506)];
			[car setMaxSpeed:Math.round([car maxSpeed] * 0.6214)];
			[car setWeightEU:Math.round(([car weightEU] - 75.0) * 2.20462262)];
			[car setMaxHorsepower:Math.round(([car maxHorsepower] / 1.014))];
			[car setFuelConsumptionEUCombined:Math.round(235.0 / [car fuelConsumptionEUCombined])];
			[car setWidthMM:Math.round([car widthMM] * 0.0393700787)];
			[car setHeightMM:Math.round([car heightMM] * 0.0393700787)];
			[car setLengthMM:Math.round([car lengthMM] * 0.0393700787)];
			[car setWheelDistanceMM:Math.round([car wheelDistanceMM] * 0.0393700787)];
		}

		var subviews1 = [[self.compareWindow contentView] subviews];
		var subviews2 = [[self.viewWindow contentView] subviews];
		var subviews = subviews1.concat(subviews2);
		for (var i = 0, c = [subviews count]; i < c; i++)
		{
			var view = subviews[i]

			var repl = @{"millimeter" : "inch", "kilogramm" : "lbs", "liter / 100km" : "mpg"};

			if ([view isKindOfClass:[CPTextField class]] && [repl objectForKey:[view stringValue]])
				[view setStringValue:[repl objectForKey:[view stringValue]]];
		}
	}
	for (var i = 0, count = [tmpCars count]; i < count; i++)
	{
		var car = tmpCars[i];

		var hp = [car maxHorsepower];
		var hppw = hp * 1000.0 / [car weightEU];
		var hppd = hp * 1000.0 / [car displacementCCM];
		var wth = [car heightMM] / [car widthMM];
		[car setHorsepowerPerTonne:Math.round(hppw)];
		[car setHorsepowerPerDisplacement:Math.round(hppd)];
		[car setHeightToWidth:wth.toFixed(2)];
	}
	[self setData:tmpCars];




	var templates = [CPMutableArray array];
	[templates addObject:[self compoundRowTemplate]];
	[templates addObject:[self rowTemplateWithStringEditorAndLeftKeys:[[translation objectForKey:"modelname"]] options:CPCaseInsensitivePredicateOption|CPDiacriticInsensitivePredicateOption]];
	[templates addObject:[self rowTemplateWithLeftKeys:[[translation objectForKey:"brand"]] rightConstants:brandNames]];
	[templates addObject:[self rowTemplateWithLeftKeys:[[translation objectForKey:"fuelType"]] rightConstants:[fuelNames subarrayWithRange:CPMakeRange(1, [fuelNames count]-1)]]];
	[templates addObject:[self rowTemplateWithLeftKeys:[[translation objectForKey:"engineAspiration"]] rightConstants:[engineNames subarrayWithRange:CPMakeRange(1, [engineNames count]-1)]]];
	[templates addObject:[self rowTemplateWithLeftKeys:[[translation objectForKey:"poweredWheels"]] rightConstants:[propulsionNames subarrayWithRange:CPMakeRange(1, [propulsionNames count]-1)]]];
	[templates addObject:[self rowTemplateWithLeftKeys:[[translation objectForKey:"transmissionType"]] rightConstants:[transmissionNames subarrayWithRange:CPMakeRange(1, [transmissionNames count]-1)]]];
	[templates addObject:[self rowTemplateWithLeftKeys:[[translation objectForKey:"cylinderLayout"]] rightConstants:[layoutNames subarrayWithRange:CPMakeRange(1, [layoutNames count]-1)]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"maxHorsepower"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"maxTorque"]]]];
	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:[[translation objectForKey:"maxSpeed"]]]];
	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:[[translation objectForKey:"accelerationTo100"]]]];
	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:[[translation objectForKey:"elasticity80To120"]]]];
	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:[[translation objectForKey:"fuelConsumptionEUCombined"]]]];
	[templates addObject:[self rowTemplateWithFloatEditorAndLeftKeys:[[translation objectForKey:"heightToWidth"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"gearCount"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"doorCount"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"maxSeatCount"]]]];	
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"luggageSpaceMin"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"fuelTankSize"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"co2Emission"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"weightEU"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"cylinderCount"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"displacementCCM"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:(currency == "usd") ? "minPriceUS" : "minPriceEU"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"widthMM"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"heightMM"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"lengthMM"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"wheelDistanceMM"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"horsepowerPerTonne"]]]];
	[templates addObject:[self rowTemplateWithIntegerEditorAndLeftKeys:[[translation objectForKey:"horsepowerPerDisplacement"]]]];
	[editor setNestingMode:CPRuleEditorNestingModeList];
	[editor setRowTemplates:templates];
	[editor addRow:nil];


	var priceKey = "minPriceEU";
	if (currency == "usd")
	{
		priceKey = "minPriceUS";
		[self.usPriceInfoLabel setHidden:NO];
	}

	var columns = ["brand","modelname",priceKey,"cylinderCount","displacementCCM","maxHorsepower","maxTorque","maxSpeed","accelerationTo100", "horsepowerPerTonne", "horsepowerPerDisplacement", "heightToWidth", "weightEU", "fuelConsumptionEUCombined", "luggageSpaceMin", "fuelType", "poweredWheels", "doorCount","maxSeatCount", "co2Emission","fuelTankSize","transmissionType","gearCount","cylinderLayout", "engineAspiration" ,"widthMM","heightMM","lengthMM","wheelDistanceMM"];
	var widths;
	if (browserLanguage == "de")	widths = [80,230,60,52,58,45,78,68,65,55,55,75,60,65,70,65,60,45,40,40,40,70,45,40,65,60,60,60,70];
	else							widths = [80,230,70,60,80,50,78,68,65,55,55,90,60,80,70,65,60,45,40,40,45,85,50,45,65,60,60,60,70];
	for (var i = 0, count = [columns count]; i < count; i++)
	{
		var key = columns[i];


		var column = [[CPTableColumn alloc] initWithIdentifier:key];
		var num = widths[i];
		if (num > 0)
			[column setWidth:num];

	//	[column setMinWidth:50];
	//	[column setMaxWidth:50];
	//	[column setSortDescriptorPrototype:[[CPSortDescriptor alloc] initWithKey:key ascending:YES selector:@selector(compare:)]];
		[[column headerView] setStringValue:[translation objectForKey:key]];

		[tableView addTableColumn:column];

		var dict = nil;

		if (key == "minPriceEU") dict = @{CPValueTransformerNameBindingOption : EuroValueTransformer};
		if (key == "minPriceUS") dict = @{CPValueTransformerNameBindingOption : DollarValueTransformer};
		if (key == "displacementCCM") dict = @{CPValueTransformerNameBindingOption : CM3ValueTransformer};
		if (key == "maxHorsepower") dict = @{CPValueTransformerNameBindingOption :  (system == "us") ? BHPValueTransformer : PSValueTransformer};
		if (key == "maxTorque") dict = @{CPValueTransformerNameBindingOption : (system == "us") ? LBFTValueTransformer : NMValueTransformer};
		if (key == "maxSpeed") dict = @{CPValueTransformerNameBindingOption : (system == "us") ? MPHValueTransformer : KMHValueTransformer};
		if (key == "accelerationTo100") dict = @{CPValueTransformerNameBindingOption : SValueTransformer};
		if (key == "weightEU") dict = @{CPValueTransformerNameBindingOption : (system == "us") ? LBSValueTransformer : KGValueTransformer};
		if (key == "fuelConsumptionEUCombined") dict = @{CPValueTransformerNameBindingOption : (system == "us") ? MPGValueTransformer : LValueTransformer};
		if (key == "luggageSpaceMin") dict = @{CPValueTransformerNameBindingOption : LValueTransformer};
		if (key == "fuelType") dict = @{CPValueTransformerNameBindingOption : FuelValueTransformer};
		if (key == "poweredWheels") dict = @{CPValueTransformerNameBindingOption : PropValueTransformer};
		if (key == "fuelTankSize") dict = @{CPValueTransformerNameBindingOption : LValueTransformer};
		if (key == "transmissionType") dict = @{CPValueTransformerNameBindingOption : TransmissionValueTransformer};
		if (key == "cylinderLayout") dict = @{CPValueTransformerNameBindingOption : LayoutValueTransformer};
		if (key == "engineAspiration") dict = @{CPValueTransformerNameBindingOption : EngineValueTransformer};
		if ([key hasSuffix:"MM"]) dict = @{CPValueTransformerNameBindingOption : (system == "us") ? INValueTransformer : MMValueTransformer};


		[column bind:CPValueBinding toObject:arrayController withKeyPath:("arrangedObjects." + key) options:dict];
	}



    var dict = [[CPMutableDictionary alloc] init];
	var urldata = [CPURLConnection sendSynchronousRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:"http://www.thecardb.net/pictures.txt"]] returningResponse:nil];
	var answer = [urldata rawString];
	var lines = [answer componentsSeparatedByCharactersInSet:[CPCharacterSet characterSetWithCharactersInString:"\r\n"]];
    for (var i = 0, count = [lines count]; i < count; i++)
    {
		var line = lines[i];

		if ([line length] > 10)
		{
			var comp1 = [line componentsSeparatedByString:"||"];
			var carnames = [comp1[0] componentsSeparatedByString:"|"];


			for (var v = 0, count2 = [carnames count]; v < count2; v++)
			{
			 	var carname = carnames[v];


			 	var pics = [comp1[1] componentsSeparatedByString:" "];

			 	[dict setObject:pics forKey:carname];
			}
		}
	}
	self.imageDict = [CPDictionary dictionaryWithDictionary:dict];





	var dateurldata = [CPURLConnection sendSynchronousRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:"http://www.thecardb.net/date.txt"]] returningResponse:nil];
	var dateanswer = [dateurldata rawString];
	[self.dateLabel setStringValue:"DataBase update: " + dateanswer];

	[self.appView setHidden:NO];
	[self.loadingProgress stopAnimation:self];


/*	var sharedApplication = [CPApplication sharedApplication];
	var namedArguments = [sharedApplication namedArguments];

	var enumerator = [namedArguments keyEnumerator];
	var key;
	while ((key = [enumerator nextObject]) != nil)
	{
		var value = [namedArguments objectForKey:key];
		console.log(key + " = " + value);
	}*/
}

- (void)rowsDidChange:(CPNotification)notification
{
	var rect = [scrollView frame];
	var newRect = CGRectMake(rect.origin.x, rect.origin.y,
							 rect.size.width, [editor numberOfRows] * 26);
	[scrollView setFrame:newRect];

	var rectA = [appView frame];

	var rectT = [tableScrollView frame];
	var newRectT = CGRectMake(rectT.origin.x, rect.origin.y + [editor numberOfRows] * 26 + 0,
							  rectT.size.width, rectA.size.height - 80 - ([editor numberOfRows] * 26));
	[tableScrollView setFrame:newRectT];

	//[self refreshPredicate];
}

- (void)refreshPredicate
{
	[editor reloadPredicate];
	var pred = [editor predicate];
	var text = [pred predicateFormat];


	for (var i = 0, count = [fuelNames count]; i < count; i++)
	{
		text = [text stringByReplacingOccurrencesOfString:[CPString stringWithFormat:"\"%@\"", fuelNames[i]] withString:i];
	}
	for (var i = 0, count = [engineNames count]; i < count; i++)
	{
		text = [text stringByReplacingOccurrencesOfString:[CPString stringWithFormat:"\"%@\"", engineNames[i]] withString:i];
	}
	for (var i = 0, count = [propulsionNames count]; i < count; i++)
	{
		text = [text stringByReplacingOccurrencesOfString:[CPString stringWithFormat:"\"%@\"", propulsionNames[i]] withString:i];
	}
	for (var i = 0, count = [transmissionNames count]; i < count; i++)
	{
		text = [text stringByReplacingOccurrencesOfString:[CPString stringWithFormat:"\"%@\"", transmissionNames[i]] withString:i];
	}
	for (var i = 0, count = [layoutNames count]; i < count; i++)
	{
		text = [text stringByReplacingOccurrencesOfString:[CPString stringWithFormat:"\"%@\"", layoutNames[i]] withString:i];
	}

	var keys = [detranslation allKeys];
	keys = [keys sortedArrayUsingDescriptors:@[[CPSortDescriptor sortDescriptorWithKey:@"length" ascending:NO]]];

	for (var i = 0, count = [keys count]; i < count; i++)
	{
		var key = keys[i];
		var value = [detranslation objectForKey:key];
		text = [text stringByReplacingOccurrencesOfString:[key stringByAppendingString:@" "] withString:[value stringByAppendingString:@" "]];
	}

	text = [text stringByReplacingOccurrencesOfString:"CONTAINS[cd] 0" withString:"!= 0"];

	//[arrayController setFilterPredicate:pred];
	[arrayController setFilterPredicate:[CPPredicate predicateWithFormat:text]];

	//	[arrayController rearrangeObjects];
	/*	for (var i = 0, count = [[arrayController arrangedObjects] count]; i < count; i++)
	 {
	 var obj = [arrayController arrangedObjects][i];
	 text = text + [obj modelname];

	 [predicateField setStringValue:text];
	 }*/
}

#pragma mark - IBAction

- (@action)languageClicked:(id)sender
{
	[[CPUserDefaults standardUserDefaults] setObject:["","en","de"][[sender tag]] forKey:"userLanguage"];
	var alert = [CPAlert alertWithMessageText:"Changes will take effect on next load of the Car Database"
							    defaultButton:"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
	[alert runModal];
}

- (@action)currencyClicked:(id)sender
{
	[[CPUserDefaults standardUserDefaults] setObject:["","usd","eur"][[sender tag]] forKey:"userCurrency"];
	var alert = [CPAlert alertWithMessageText:"Changes will take effect on next load of the Car Database"
							    defaultButton:"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
	[alert runModal];
}

- (@action)systemClicked:(id)sender
{
	[[CPUserDefaults standardUserDefaults] setObject:["","us","me"][[sender tag]] forKey:"userSystem"];
	var alert = [CPAlert alertWithMessageText:"Changes will take effect on next load of the Car Database"
							    defaultButton:"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
	[alert runModal];
}

- (@action)refreshClicked:(id)sender
{
	[self refreshPredicate];
}

- (@action)resetClicked:(id)sender
{
	while ([editor numberOfRows] > 1)
		[editor removeRowAtIndex:0];
	[editor addRow:nil];
	[editor removeRowAtIndex:0];

	[arrayController setFilterPredicate:nil];

}

- (@action)aboutClicked:(id)sender
{
	if ([sender tag] == 2)
		[[CPWorkspace sharedWorkspace] openURL:[CPURL URLWithString:"http://www.thecardb.net/download/"]];
	else
		[self.aboutWindow makeKeyAndOrderFront:self];
}

- (@action)downloadappClicked:(id)sender
{
	var alert = [CPAlert alertWithMessageText:"The Car DataBase Apps for Desktop (Windows/Mac/Linux) and Mobile (Android/iPhone/iPad) devices are still under development."
							    defaultButton:"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
	[alert runModal];
}

- (@action)corecodeClicked:(id)sender
{
	var url = ["https://www.corecode.io/",@"mailto:feedback@corecode.io?subject=Feedback-CarDB"][[sender tag]];
	[[CPWorkspace sharedWorkspace] openURL:[CPURL URLWithString:url]];
}


#pragma mark - View Car

- (void)selectionDidChange:(CPNotification)notificatio
{
	[self updateImage];
}

- (@action)viewcarClicked:(id)sender
{
	[self.arrayController setSelectionIndex:[self.arrayController selectionIndex]];

	// reset view
	for (var i = 3; i <= 39; i++)
	{
		var view = [[self.viewWindow contentView] viewWithTag:i];

		[view setEnabled:NO];
		//[view unbind:CPValueBinding];
	}
	var button = [[self.viewWindow contentView] viewWithTag:90];
	[button setTitle:"Update Car"];

	[self.viewWindow makeKeyAndOrderFront:self];

	[self updateImage];
}

- (@action)imagespinnerClicked:(id)sender
{
	[self updateImage];
}

- (void)updateImage
{
	if (![self.viewWindow isVisible])
		return;

	var car = [arrayController selectedObjects][0];
	self.images = [self.imageDict objectForKey:[car modelname]];

	if (!self.images)
	{
		[self.webView setMainFrameURL:[CPURL URLWithString:[CPString stringWithFormat:"http://www.bing.com/images/search?q=%@ %@", [car brand], [car modelname]]]];

		[self.imageView setHidden:YES];
		[self.webView setHidden:NO];

	}
	else
	{
		var indexCount = Math.abs([self.imageStepper integerValue]) % [self.images count];
		var image = [[CPImage alloc] initWithContentsOfFile:self.images[indexCount]];
		[self.imageView setImage:image];
		[self.imageView setHidden:NO];
		[self.webView setHidden:YES];
	}
}

- (@action)updatecarClicked:(CPButton)sender
{
	if ([sender title] == "Submit Car")
	{
		var str = "mailto:feedback@corecode.io?subject=CarDB-UpdateCar&body=";
		for (var i = 1; i <= 39; i++)
		{
			var view = [[self.viewWindow contentView] viewWithTag:i];

			if ([view isKindOfClass:[CPTextField class]])
				str = str + [view stringValue];
			else if ([view isKindOfClass:[CPPopUpButton class]])
				str = str + [[CPNumber numberWithInt:[view indexOfSelectedItem]] stringValue];
			else if ([view isKindOfClass:[CPButton class]])
			{
				if ([view state] == CPOffState)
					str = str + "0";
				else
					str = str + "1";
			}
			str = str + ",";
		}
		if (![[CPWorkspace sharedWorkspace] openURL:[CPURL URLWithString:str]])
		{
			var msg = "Could not open your mail client. Please send the following information to feedback@corecode.io to have the car added:\n" + str;
			var alert = [CPAlert alertWithMessageText:msg
										defaultButton:"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
			[alert runModal];
			return;
		}

		[self.viewWindow orderOut:self];

		var alert = [CPAlert alertWithMessageText:"Thanks we will process the e-mail with your updates as soon as possible."
									defaultButton:"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
		[alert runModal];

	}
	else
	{
		[sender setTitle:"Submit Car"];

		for (var i = 3; i <= 39; i++)
		{
			var view = [[self.viewWindow contentView] viewWithTag:i];

			[view setEnabled:YES];
			if ([view isKindOfClass:[CPTextField class]])
				[view setEditable:YES];
		}
	}
}

#pragma mark - Add Car

- (@action)addcarClicked:(id)sender
{
	[self.addWindow makeKeyAndOrderFront:self];


	for (var i = 0, count = [brandNames count]; i < count; i++)
	{
		[self.brandsPopup addItemWithTitle:brandNames[i]];
	}
}

- (@action)submitcarClicked:(id)sender
{
	if ([self.isPublicCheckbox state] == CPOffState)
	{
		var alert = [CPAlert alertWithMessageText:"Sorry we can only accept contributions in the public domain"
									defaultButton:"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
		[alert runModal];
		return;
	}
	if ([self.isOnsaleCheckbox state] == CPOffState)
	{
		var alert = [CPAlert alertWithMessageText:"Sorry this database is only for cars currently on sale"
									defaultButton:"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
		[alert runModal];
		return;
	}


    var str = "mailto:feedback@corecode.io?subject=CarDB-NewCar&body=";
    str = str + [self.brandsPopup titleOfSelectedItem];
	for (var i = 2; i <= 39; i++)
	{
		str = str + ",";
		var view = [[self.addWindow contentView] viewWithTag:i];

		if ([view isKindOfClass:[CPTextField class]])
			str = str + [view stringValue];
		else if ([view isKindOfClass:[CPPopUpButton class]])
			str = str + [[CPNumber numberWithInt:[view indexOfSelectedItem]] stringValue];
		else if ([view isKindOfClass:[CPButton class]])
		{
			if ([view state] == CPOffState)
				str = str + "0";
			else
				str = str + "1";
		}
	}
	if (![[CPWorkspace sharedWorkspace] openURL:[CPURL URLWithString:str]])
	{
		var msg = "Could not open your mail client. Please send the following information to feedback@corecode.io to have the car added:\n" + str;
		var alert = [CPAlert alertWithMessageText:msg
									defaultButton:"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
		[alert runModal];
		return;
	}


	[self.addWindow orderOut:self];

	var alert = [CPAlert alertWithMessageText:"Thanks we will process the e-mail with your updates as soon as possible."
							    defaultButton:"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
	[alert runModal];
}

#pragma mark - Compare Car

- (@action)compareClicked:(id)sender
{
	[self.compareWindow makeKeyAndOrderFront:self];
}

#pragma mark - SPPredicateEditor helpers

- (SPPredicateEditorRowTemplate)compoundRowTemplate
{
	return [[SPPredicateEditorRowTemplate alloc] initWithCompoundTypes:[1,2,0]];
}

- (SPPredicateEditorRowTemplate)rowTemplateWithStringEditorAndLeftKeys:(CPArray)leftKeys options:(CPInteger)options
{
	if(!leftKeys)
		return;

	var operators = [
					 CPContainsPredicateOperatorType,
					 CPEqualToPredicateOperatorType,
					 CPNotEqualToPredicateOperatorType,
					 CPBeginsWithPredicateOperatorType,
					 CPEndsWithPredicateOperatorType
					 ];

	var leftExpressions = [CPMutableArray array];
	for(var i = 0;i<[leftKeys count];i++)
		[leftExpressions addObject:[CPExpression expressionForKeyPath:leftKeys[i]]];

	return [[SPPredicateEditorRowTemplate alloc] initWithLeftExpressions:leftExpressions
											rightExpressionAttributeType:CPStringAttributeType
																modifier:0
															   operators:operators
																 options:options];
}

- (SPPredicateEditorRowTemplate)rowTemplateWithLeftKeys:(CPArray)leftKeys rightConstants:(CPArray)rightConstants
{
	var operators = [CPEqualToPredicateOperatorType,CPNotEqualToPredicateOperatorType];

	var leftExpressions = [CPMutableArray array];
	for(var i = 0;i<[leftKeys count];i++)
		[leftExpressions addObject:[CPExpression expressionForKeyPath:leftKeys[i]]];

	var constants = [CPMutableArray array];
	for(var i = 0;i<[rightConstants count];i++)
		[constants addObject:[CPExpression expressionForConstantValue:rightConstants[i]]];

	return [[SPPredicateEditorRowTemplate alloc] initWithLeftExpressions:leftExpressions
														rightExpressions:constants
																modifier:0
															   operators:operators
																options:0];
}

- (SPPredicateEditorRowTemplate)rowTemplateWithBooleanEditorAndLeftKeys:(CPArray)leftKeys
{
	var operators = [CPEqualToPredicateOperatorType, CPNotEqualToPredicateOperatorType];

	var leftExpressions = [CPMutableArray array];
	for(var i = 0;i<[leftKeys count];i++)
		[leftExpressions addObject:[CPExpression expressionForKeyPath:leftKeys[i]]];

	return [[SPPredicateEditorRowTemplate alloc] initWithLeftExpressions:leftExpressions
											rightExpressionAttributeType:CPBooleanAttributeType
																modifier:0
															   operators:operators
																 options:0];
}

- (SPPredicateEditorRowTemplate)rowTemplateWithFloatEditorAndLeftKeys:(CPArray)leftKeys
{
	var operators = [
					 CPGreaterThanOrEqualToPredicateOperatorType,
					 CPLessThanOrEqualToPredicateOperatorType,
					 CPEqualToPredicateOperatorType,
					 CPNotEqualToPredicateOperatorType
					 ];

	var leftExpressions = [CPMutableArray array];
	for(var i = 0;i<[leftKeys count];i++)
		[leftExpressions addObject:[CPExpression expressionForKeyPath:leftKeys[i]]];

	return [[SPPredicateEditorRowTemplate alloc] initWithLeftExpressions:leftExpressions
											rightExpressionAttributeType:CPDoubleAttributeType
																modifier:0
															   operators:operators
																 options:0];
}

- (SPPredicateEditorRowTemplate)rowTemplateWithIntegerEditorAndLeftKeys:(CPArray)leftKeys
{
	var operators = [
					 CPGreaterThanOrEqualToPredicateOperatorType,
					 CPGreaterThanPredicateOperatorType,
					 CPLessThanOrEqualToPredicateOperatorType,
					 CPLessThanPredicateOperatorType,
					 CPEqualToPredicateOperatorType,
					 CPNotEqualToPredicateOperatorType
					 ];

	var leftExpressions = [CPMutableArray array];
	for(var i = 0;i<[leftKeys count];i++)
		[leftExpressions addObject:[CPExpression expressionForKeyPath:leftKeys[i]]];

	return [[SPPredicateEditorRowTemplate alloc] initWithLeftExpressions:leftExpressions
											rightExpressionAttributeType:CPInteger64AttributeType
																modifier:0
															   operators:operators
																 options:0];
}
@end
