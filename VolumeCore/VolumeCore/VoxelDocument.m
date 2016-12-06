//
//  VoxelDocument.m
//  VolumeCore
//
//  Created by CoreCode on 16.10.08.
/*	Copyright (c) 2016 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "VolumeCore.h"

#ifdef __linux__
@interface NSView (GNUStepFakeSupport)
- (id)animator;
@end
@implementation NSView (GNUStepFakeSupport)
- (id)animator
{
	return self;
}
@end
#endif

@implementation VoxelDocument

@synthesize stepsize3DButton, sliceSlider, steps2DSlider, offsetX2DSlider, offsetY2DSlider, zoom2DSlider, steps3DSlider, stepsize3DSlider, latitudeSlider, longitudeSlider, orientationSlider, offsetX3DSlider, offsetY3DSlider, zoom3DSlider, directionPopUp, datasetPopUp, modusPopUp, method2DPopUp, method3DPopUp, transferFunction2DView, transferFunction3DView;

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
		[steps2DSlider setFloatValue:[[initDict objectForKey:@"steps2DSlider"] floatValue]];
		[steps3DSlider setFloatValue:[[initDict objectForKey:@"steps3DSlider"] floatValue]];
		[stepsize3DSlider setFloatValue:[[initDict objectForKey:@"stepsize3DSlider"] floatValue]];
		[stepsize3DButton setState:[[initDict objectForKey:@"stepsize3DButton"] intValue]];
		[sliceSlider setFloatValue:[[initDict objectForKey:@"sliceSlider"] floatValue]];
		[offsetX2DSlider setFloatValue:[[initDict objectForKey:@"offsetX2DSlider"] floatValue]];
		[offsetY2DSlider setFloatValue:[[initDict objectForKey:@"offsetY2DSlider"] floatValue]];
		[zoom2DSlider setFloatValue:[[initDict objectForKey:@"zoom2DSlider"] floatValue]];
		[latitudeSlider setFloatValue:[[initDict objectForKey:@"latitudeSlider"] floatValue]];
		[longitudeSlider setFloatValue:[[initDict objectForKey:@"longitudeSlider"] floatValue]];
		[orientationSlider setFloatValue:[[initDict objectForKey:@"orientationSlider"] floatValue]];
		[offsetX3DSlider setFloatValue:[[initDict objectForKey:@"offsetX3DSlider"] floatValue]];
		[offsetY3DSlider setFloatValue:[[initDict objectForKey:@"offsetY3DSlider"] floatValue]];	
		[zoom3DSlider setFloatValue:[[initDict objectForKey:@"zoom3DSlider"] floatValue]];		
		[directionPopUp selectItemAtIndex:[[initDict objectForKey:@"directionPopUp"] intValue]];
		[datasetPopUp selectItemAtIndex:[[initDict objectForKey:@"datasetPopUp"] intValue]];
		[modusPopUp selectItemAtIndex:[[initDict objectForKey:@"modusPopUp"] intValue]];
		[method2DPopUp selectItemAtIndex:[[initDict objectForKey:@"method2DPopUp"] intValue]];
		[method3DPopUp selectItemAtIndex:[[initDict objectForKey:@"method3DPopUp"] intValue]];
		
		for (NSArray *a in [NSArray arrayWithObjects:[initDict objectForKey:@"transferFunction2DView"], [initDict objectForKey:@"transferFunction3DView"], nil])
		{
			NSMutableArray *na = [NSMutableArray arrayWithCapacity:[a count]];
			
			for (NSDictionary *d in a)
				[na addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[d objectForKey:@"x"], @"x", [d objectForKey:@"y"], @"y", [NSColor colorWithCalibratedRed:[[d objectForKey:@"r"] floatValue] green:[[d objectForKey:@"g"] floatValue] blue:[[d objectForKey:@"b"] floatValue] alpha:1.0], @"color", nil]];
			
			[([a isEqualToArray:[initDict objectForKey:@"transferFunction2DView"]] ? transferFunction2DView :  transferFunction3DView) setPoints:na];
		}
	}
#ifdef GNUSTEP // bug 34923
	else
	{
		[modusPopUp selectItemAtIndex:0];
		[datasetPopUp selectItemAtIndex:0];
	}
#endif
	[view2d setHidden:([modusPopUp indexOfSelectedItem] == 0) ? NO : YES];
	[view3d setHidden:([modusPopUp indexOfSelectedItem] == 0) ? YES : NO];
	if ([modusPopUp indexOfSelectedItem] == 0)
	{
		NSRect frame = [settingsPanel frame];
		
		frame.size.height -= 47;
		frame.origin.y += 47;
		[settingsPanel setFrame:frame display:YES animate:NO];
	}
	[self stepsizeSettingsChanged:nil];
	[self method2DSettingsChanged:nil];
	[stepsize3DTextField setStringValue:([stepsize3DButton state] == NSOnState) ? [steps3DSlider stringValue] : [stepsize3DSlider stringValue]];	
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"TransferFunctionChanged" object:nil];
	
    [super dealloc];  
}

- (NSString *)windowNibName
{
    return @"VoxelDocument";
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
	
	[dict setObject:[NSNumber numberWithFloat:[steps2DSlider floatValue]] forKey:@"steps2DSlider"];
	[dict setObject:[NSNumber numberWithFloat:[steps3DSlider floatValue]] forKey:@"steps3DSlider"];
	[dict setObject:[NSNumber numberWithFloat:[stepsize3DSlider floatValue]] forKey:@"stepsize3DSlider"];
	[dict setObject:[NSNumber numberWithFloat:[stepsize3DButton intValue]] forKey:@"stepsize3DButton"];
	[dict setObject:[NSNumber numberWithFloat:[sliceSlider floatValue]] forKey:@"sliceSlider"];
	[dict setObject:[NSNumber numberWithFloat:[offsetX2DSlider floatValue]] forKey:@"offsetX2DSlider"];
	[dict setObject:[NSNumber numberWithFloat:[offsetY2DSlider floatValue]] forKey:@"offsetY2DSlider"];
	[dict setObject:[NSNumber numberWithFloat:[zoom2DSlider floatValue]] forKey:@"zoom2DSlider"];
	[dict setObject:[NSNumber numberWithFloat:[latitudeSlider floatValue]] forKey:@"latitudeSlider"];
	[dict setObject:[NSNumber numberWithFloat:[longitudeSlider floatValue]] forKey:@"longitudeSlider"];
	[dict setObject:[NSNumber numberWithFloat:[orientationSlider floatValue]] forKey:@"orientationSlider"];
	[dict setObject:[NSNumber numberWithFloat:[offsetX3DSlider floatValue]] forKey:@"offsetX3DSlider"];
	[dict setObject:[NSNumber numberWithFloat:[offsetY3DSlider floatValue]] forKey:@"offsetY3DSlider"];	
	[dict setObject:[NSNumber numberWithFloat:[zoom3DSlider floatValue]] forKey:@"zoom3DSlider"];	
	[dict setObject:[NSNumber numberWithInt:[directionPopUp indexOfSelectedItem]] forKey:@"directionPopUp"];
	[dict setObject:[NSNumber numberWithInt:[datasetPopUp indexOfSelectedItem]] forKey:@"datasetPopUp"];
	[dict setObject:[NSNumber numberWithInt:[modusPopUp indexOfSelectedItem]] forKey:@"modusPopUp"];
	[dict setObject:[NSNumber numberWithInt:[method2DPopUp indexOfSelectedItem]] forKey:@"method2DPopUp"];
	[dict setObject:[NSNumber numberWithInt:[method3DPopUp indexOfSelectedItem]] forKey:@"method3DPopUp"];
	
	for (NSArray *a in [NSArray arrayWithObjects:[transferFunction2DView points], [transferFunction3DView points], nil])
	{
		NSMutableArray *na = [NSMutableArray arrayWithCapacity:[a count]];
		
		for (NSDictionary *d in a)
		{
			NSColor *c = [[d objectForKey:@"color"] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
			
			[na addObject:[NSDictionary dictionaryWithObjectsAndKeys:[d objectForKey:@"x"], @"x", [d objectForKey:@"y"], @"y", [NSNumber numberWithFloat:[c redComponent]], @"r", [NSNumber numberWithFloat:[c greenComponent]], @"g", [NSNumber numberWithFloat:[c blueComponent]], @"b", nil]];
		}
		[dict setObject:na forKey:([a isEqualToArray:[transferFunction2DView points]] ? @"transferFunction2DView" :  @"transferFunction3DView")];
	}

	
	data = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListXMLFormat_v1_0 errorDescription:&err];
	
	if (!data)
	{
		if (!outError)
			NSLog(@"dataFromPropertyList failed with %@", err);
		else
			*outError = [NSError errorWithDomain:@"VolumeCore" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"VolumeCore document couldn't be written", NSLocalizedDescriptionKey, (err ? err : @"kUnknownErr"), NSLocalizedFailureReasonErrorKey, nil]];
		
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
			*outError = [NSError errorWithDomain:@"VolumeCore" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys: @"VolumeCore document couldn't be read", NSLocalizedDescriptionKey, (err ? err : @"kUnknownErr"), NSLocalizedFailureReasonErrorKey, nil]];

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

- (IBAction)stepsizeSettingsChanged:(id)sender
{
	[(sender ? [steps3DSlider animator] : steps3DSlider) setHidden:([stepsize3DButton state] == NSOnState) ? NO : YES];
	[(sender ? [steps3DLabel animator] : steps3DLabel) setHidden:([stepsize3DButton state] == NSOnState) ? NO : YES];
	[(sender ? [stepsize3DSlider animator] : stepsize3DSlider) setHidden:([stepsize3DButton state] == NSOnState) ? YES : NO];
	[(sender ? [stepsize3DLabel animator] : stepsize3DLabel) setHidden:([stepsize3DButton state] == NSOnState) ? YES : NO];	
	
	[self stepsize3DSettingsChanged:sender];
}

- (IBAction)method2DSettingsChanged:(id)sender
{
	[(sender ? [sliceSlider animator] : sliceSlider)  setHidden:([method2DPopUp indexOfSelectedItem] == 0) ? NO : YES];
	[(sender ? [sliceLabel animator] : sliceLabel)  setHidden:([method2DPopUp indexOfSelectedItem] == 0) ? NO : YES];
	[(sender ? [steps2DSlider animator] : steps2DSlider)  setHidden:([method2DPopUp indexOfSelectedItem] == 0) ? YES : NO];
	[(sender ? [steps2DLabel animator] : steps2DLabel)  setHidden:([method2DPopUp indexOfSelectedItem] == 0) ? YES : NO];
	
	if (sender) [self updateChangeCount:NSChangeDone];
}

- (IBAction)modusSettingsChanged:(id)sender
{
	NSRect frame = [settingsPanel frame];
	BOOL change = NO;
	
	if (([modusPopUp indexOfSelectedItem] == 1)) // && (frame.size.height == 458)) // 3d
	{
		frame.size.height += 47;
		frame.origin.y -= 47;
		[settingsPanel setFrame:frame display:YES animate:YES];
		change = YES;
	}
	else if (([modusPopUp indexOfSelectedItem] == 0)) //  && (frame.size.height == 505)) // 2d
	{
		frame.size.height -= 47;
		frame.origin.y += 47;		
		[settingsPanel setFrame:frame display:YES animate:YES];
		change = YES;		
    }
	
	if (change)
	{
		[[view2d animator] setHidden:([modusPopUp indexOfSelectedItem] == 0) ? NO : YES];
		[[view3d animator] setHidden:([modusPopUp indexOfSelectedItem] == 0) ? YES : NO];
		
		[oglview loadTransferFunction:sender];
		[self updateChangeCount:NSChangeDone];
	}
}

- (IBAction)settingsChanged:(id)sender
{
	[self updateChangeCount:NSChangeDone];
}

- (IBAction)presetAction:(id)sender
{
	if ([[sender title] isEqualToString:@"T"])
	{
		[longitudeSlider setFloatValue:0.0];
		[latitudeSlider setFloatValue:0.0];
		[orientationSlider setFloatValue:0.0];	
	}
	else if ([[sender title] isEqualToString:@"S"])
	{
		[longitudeSlider setFloatValue:0.0];
		[latitudeSlider setFloatValue:-180.0];
		[orientationSlider setFloatValue:-90.0];	
	}	
	else if ([[sender title] isEqualToString:@"F"])
	{
		[longitudeSlider setFloatValue:0.0];
		[latitudeSlider setFloatValue:-180.0];
		[orientationSlider setFloatValue:0.0];	
	}	
	
	[self updateChangeCount:NSChangeDone];	
}

- (IBAction)stepsize3DSettingsChanged:(id)sender
{
	[stepsize3DTextField setStringValue:([stepsize3DButton state] == NSOnState) ? [steps3DSlider stringValue] : [stepsize3DSlider stringValue]];
		
	if (sender) [self updateChangeCount:NSChangeDone];
}
@end