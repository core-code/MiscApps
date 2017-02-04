//
//  FlowDocument.mm
//  FlowCore
//
//  Created by CoreCode on 09.01.09.
/*	Copyright © 2017 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "FlowCore.h"

@implementation FlowDocument

@synthesize arrowsEnabledButton, colorsEnabledButton, streamlinesEnabledButton, scalewithvelocityButton, amountSlider, sizeSlider, datasetPopUp, colorChannelPopUp, transferFunctionView, slAmountSlider, stepsSlider, stepsizeSlider, methodPopUp;


- (id)init
{
    self = [super init];
	
    if (self)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(transferFunctionChanged:) name:@"TransferFunctionChanged" object:nil];		
		[self setHasUndoManager:NO];
	}
	
    return self;
}

- (void)awakeFromNib
{
	[oglview setDoc:self];

	if (initDict)
	{
		[datasetPopUp selectItemAtIndex:[[initDict objectForKey:@"datasetPopUp"] intValue]];
		
		NSArray *a  = [initDict objectForKey:@"transferFunctionView"];
		NSMutableArray *na = [NSMutableArray arrayWithCapacity:[a count]];
		
		for (NSDictionary *d in a)
			[na addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[d objectForKey:@"x"], @"x", [d objectForKey:@"y"], @"y", [NSColor colorWithCalibratedRed:[[d objectForKey:@"r"] floatValue] green:[[d objectForKey:@"g"] floatValue] blue:[[d objectForKey:@"b"] floatValue] alpha:1.0], @"color", nil]];
		
		[transferFunctionView setPoints:na];
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TransferFunctionChanged" object:nil];
	
    [super dealloc];  
}

- (NSString *)windowNibName
{
    return @"FlowDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	NSData *data;
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSString *err;
	
	[dict setObject:[NSNumber numberWithInt:[datasetPopUp indexOfSelectedItem]] forKey:@"datasetPopUp"];

	
	NSArray *a = [transferFunctionView points];
	NSMutableArray *na = [NSMutableArray arrayWithCapacity:[a count]];
	
	for (NSDictionary *d in a)
	{
		NSColor *c = [[d objectForKey:@"color"] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		
		[na addObject:[NSDictionary dictionaryWithObjectsAndKeys:[d objectForKey:@"x"], @"x", [d objectForKey:@"y"], @"y", [NSNumber numberWithFloat:[c redComponent]], @"r", [NSNumber numberWithFloat:[c greenComponent]], @"g", [NSNumber numberWithFloat:[c blueComponent]], @"b", nil]];
	}
	[dict setObject:na forKey:@"transferFunctionView"];
	
	
	data = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListXMLFormat_v1_0 errorDescription:&err];
	
	if (!data)
	{
		if (!outError)
			NSLog(@"dataFromPropertyList failed with %@", err);
		else
			*outError = [NSError errorWithDomain:@"FlowCore" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"FlowCore document couldn't be written", NSLocalizedDescriptionKey, (err ? err : @"kUnknownErr"), NSLocalizedFailureReasonErrorKey, nil]];
		
		[err release];
	}
	
    [[self undoManager] removeAllActions];	
	return data;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError;
{
    BOOL result = NO;
	NSString *err;
	NSDictionary *dict = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&err];
	
	if (dict)
	{                         
		initDict = [dict copy];

		result = YES;
	}
	else
	{
		if (!outError) 
			NSLog(@"propertyListFromData failed with %@", err);
		else
			*outError = [NSError errorWithDomain:@"FlowCore" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"FlowCore document couldn't be read", NSLocalizedDescriptionKey, (err ? err : @"kUnknownErr"), NSLocalizedFailureReasonErrorKey, nil]];

		[err release];
		result = NO;
	}
	
    [[self undoManager] removeAllActions];
    return result;
}

- (void)transferFunctionChanged:(id)sender
{
	[oglview loadTransferFunction:sender];
	[self updateChangeCount:NSChangeDone];	
}

- (IBAction)dataSettingsChanged:(id)sender
{
	[oglview loadData:sender];	
	[self updateChangeCount:NSChangeDone];
}

- (IBAction)settingsChanged:(id)sender
{
	[self updateChangeCount:NSChangeDone];
}
@end