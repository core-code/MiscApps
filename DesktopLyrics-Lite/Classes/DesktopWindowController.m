//
//  DesktopWindowController.m
//  DesktopLyrics
//
//  Created by CoreCode on 26.09.06.
/*	Copyright (c) 2006 - 2012 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "DesktopWindowController.h"

float heightForStringDrawing(NSString *myString, NSFont *myFont, float myWidth);
BOOL disableAntiAliasing;

@implementation DesktopWindowController

#pragma mark *** NSObject subclass-methods ***

- (id)init
{
	if ((self = [super init]))
	{
		layoutManager = [[NSLayoutManager alloc] init];
		songLyricsArray = [[NSMutableArray alloc] initWithCapacity:10];
		timers = [[NSMutableArray alloc] initWithCapacity:10];

		iTunes = [[iTunesController alloc] initWithDelegate:self];
        
        if (OS_IS_POST_SNOW)
            [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(bringToFront) name:@"NSWorkspaceActiveSpaceDidChangeNotification" object:nil];
        
		[NSBundle loadNibNamed:@"DesktopWindow" owner:self];
	}
	return self;
}

- (void)dealloc
{
    if (OS_IS_POST_SNOW)
        [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    
	[layoutManager release];
	[textAttributes release];
	[songLyricsArray release];

	layoutManager = nil;
	textAttributes = nil;
	songLyricsArray = nil;

	[super dealloc];
}

#pragma mark *** NSNibAwaking protocol-methods ***

- (void)awakeFromNib
{
	disableAntiAliasing = [userDefaults boolForKey:@"disableAntiAliasing"];
	
	[self updateWindow:nil];
	[self forceUpdate];
}

#pragma mark *** IBAction action-methods ***

- (IBAction)prevPageClicked:(id)sender
{
	asl_NSLog_debug(@"prevPageClicked: %@", [sender description]);
	if (sender != nil) // always true
		[self clearTimers];

	currentPage--;
	if (currentPage < 0)
		currentPage = [songLyricsArray count] - 1;
	[self updateText];
}

- (IBAction)nextPageClicked:(id)sender
{
	asl_NSLog_debug(@"nextPageClicked: %@", [sender description]);
	if (sender != nil)
		[self clearTimers];

	currentPage++;
	if (currentPage >= (char)[songLyricsArray count])
		currentPage = 0;
	[self updateText];
}

#pragma mark *** DesktopWindowController methods ***

- (void)updateWindow:(id)sender
{
	NSScreen *screen = [NSScreen mainScreen];

	if ([userDefaults integerForKey:kScreenKey])
	{
		NSArray			*allScreens = [NSScreen screens];
		NSScreen		*currentScreen;

		for (currentScreen in allScreens)
		{
			NSNumber *num = [[currentScreen deviceDescription] objectForKey: @"NSScreenNumber"];

			if ([num isEqualToNumber:[userDefaults objectForKey:kScreenKey]])
				screen = currentScreen;
		}
	}

	if ([userDefaults boolForKey:kSubstractDockKey])
		windowFrame = [screen visibleFrame];
	else
	{
		windowFrame = [screen frame];
		windowFrame.size.height -= 22.0;
	}

	windowFrame.size.height -= [userDefaults floatForKey:kIndentTopKey];
	windowFrame.size.width -= [userDefaults floatForKey:kIndentRightKey];
	windowFrame.size.height -= [userDefaults floatForKey:kIndentBottomKey];
	windowFrame.size.width -= [userDefaults floatForKey:kIndentLeftKey];
	windowFrame.origin.x += [userDefaults floatForKey:kIndentLeftKey];
	windowFrame.origin.y += [userDefaults floatForKey:kIndentBottomKey];

	[window setFrame:windowFrame display:YES];

	if ([userDefaults boolForKey:kHiddenOptionLyricsOnTopKey])
		[window setLevel:CGWindowLevelForKey(kCGMaximumWindowLevelKey)];
	else
	{
        if (OS_IS_POST_SNOW)
			[window setLevel:CGWindowLevelForKey(kCGDesktopWindowLevelKey)+1];
		else
			[window setLevel:CGWindowLevelForKey(kCGDesktopWindowLevelKey)-1];
	}

	NSRect rect = [([window contentView]) frame];

	[[[outputArea superview] superview] setFrame:rect];

    if (hidden)
        [window orderOut:self];
    else
        [window orderFront:self];

    if (OS_IS_POST_SNOW)
        [buttonWindow setLevel:CGWindowLevelForKey(kCGBackstopMenuLevelKey)];
    else
        [buttonWindow setLevel:CGWindowLevelForKey(kCGDesktopWindowLevelKey)+1];

    if (OS_IS_POST_SNOW)
    {
		#define NSWindowCollectionBehaviorTransient 0x08
        /*NSWindowCollectionBehaviorManaged, NSWindowCollectionBehaviorTransient, or NSWindowCollectionBehaviorStationary*/
        [buttonWindow setCollectionBehavior:NSWindowCollectionBehaviorTransient|NSWindowCollectionBehaviorCanJoinAllSpaces];
        [window setCollectionBehavior:NSWindowCollectionBehaviorTransient|NSWindowCollectionBehaviorCanJoinAllSpaces];
    }
    
	[self updateAppearance:sender];
}

- (void)updateAppearance:(id)sender
{
	NSShadow *textshadow = [[NSShadow alloc] init];

	if ([userDefaults boolForKey:kTextShadowKey])
	{
		[textshadow setShadowColor: [NSUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:kTextShadowColorDataKey]]];
		[textshadow setShadowOffset: NSMakeSize([userDefaults doubleForKey:kTextShadowOffsetHorizontalKey] , [userDefaults doubleForKey:kTextShadowOffsetVerticalKey])];
		[textshadow setShadowBlurRadius:[userDefaults doubleForKey:kTextShadowBlurRadiusKey]];
	}

	if (textAttributes != nil)
		[textAttributes release];

	NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	if ([userDefaults integerForKey:kTextHorizontalAlignmentKey] == 0)		[style setAlignment:NSLeftTextAlignment];
	else if ([userDefaults integerForKey:kTextHorizontalAlignmentKey] == 1)	[style setAlignment:NSCenterTextAlignment];
	else if ([userDefaults integerForKey:kTextHorizontalAlignmentKey] == 2)	[style setAlignment:NSRightTextAlignment];

	NSFont *font = [NSFont fontWithName:[userDefaults objectForKey:kTextFontNameKey] size:[userDefaults doubleForKey:kTextFontSizeKey]];

	if (!font)
	{
		font = [NSFont fontWithName:[[NSFont boldSystemFontOfSize:12] fontName] size:[userDefaults doubleForKey:kTextFontSizeKey]];
		[userDefaults setObject:[[NSFont boldSystemFontOfSize:12] fontName] forKey:kTextFontNameKey];
		[userDefaults synchronize];
	}

	textAttributes = [[NSDictionary allocWithZone:[self zone]] initWithObjectsAndKeys:font,
		NSFontAttributeName,
		[NSUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:kTextColorDataKey]],
		NSForegroundColorAttributeName,
		textshadow,
		NSShadowAttributeName,
		[[style copy] autorelease],
		NSParagraphStyleAttributeName,
		nil];

	[textshadow release];
	[style release];

	[scrollTextField setTextColor:[NSUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:kTextColorDataKey]]];

	if (sender != nil)
	{
		[self updateText];
		[self setupTimers];
	}
}

- (void)iTunesDidChange:(BOOL)lyricsStayedSame
{
	asl_NSLog_debug(@"iTunesDidChange: %i", lyricsStayedSame);

	if (!lyricsStayedSame)
		currentPage = 0;

	[self updateText];
	[self setupTimers];
}

- (void)forceUpdate
{
	[iTunes update:nil];
}

- (void)configurePages // determines the amount of pages and splits the lyrics into them
{
	NSString *lyrics = [iTunes lyrics];
	NSTextStorage *textStorage = [outputArea textStorage];
	NSString *info;
	NSFont *ourFont = [NSFont fontWithName:[userDefaults objectForKey:kTextFontNameKey] size:[userDefaults doubleForKey:kTextFontSizeMinimumKey]];

	[songLyricsArray removeAllObjects];

	[buttonWindow orderOut:self];

	if (!(
		  !([iTunes state] == kPlaying) ||
		  ([lyrics isEqualToString:@""] && (![userDefaults boolForKey:kPrependSonginfoKey] || ![userDefaults boolForKey:kPrependAlsoWhenEmptyKey]))))
	{
		NSMutableDictionary *smallTextAttributes = [textAttributes mutableCopy];
		NSMutableParagraphStyle *ps = [[smallTextAttributes objectForKey:NSParagraphStyleAttributeName] mutableCopy];
		[ps setLineHeightMultiple:[userDefaults floatForKey:kTextLineSpacingKey]];
		[smallTextAttributes setObject:ps forKey:NSParagraphStyleAttributeName];
		[ps release];
		uint32_t pages = 1;

		[smallTextAttributes setObject:ourFont forKey:NSFontAttributeName];
		asl_NSLog_debug(@"configurePages:\n smallTextAttributes: %@\n", [smallTextAttributes description]);

		if ([userDefaults boolForKey:kPrependSonginfoKey])
			info = [NSString stringWithFormat:@"%@ - %@\n\n", [iTunes artist], [iTunes title]];
		else
			info = @"";

		asl_NSLog_debug(@"configurePages:\n info: %@\n", info);
		//asl_NSLog_debug(@"configurePages: lyrics:%@\n"lyrics);

		do // see how many pages we need
		{
			NSUInteger length = [lyrics length];
			NSUInteger lengthDivPages = length / pages;
			NSRange range = NSMakeRange(0, lengthDivPages);
			NSRange lineRange = [lyrics lineRangeForRange:range];
			NSString *aPageOfLyrics = [lyrics substringWithRange:lineRange];

			[textStorage beginEditing];

			if (aPageOfLyrics == nil) @throw [NSException exceptionWithName:@"aPageOfLyrics == nil exception" reason:[NSString stringWithFormat:@"aPoL L %@ le %lu  led %lu lrl %lu lrle %lu", [lyrics description], (unsigned long)length, (unsigned long)lengthDivPages, (unsigned long)lineRange.location, (unsigned long)lineRange.length] userInfo:nil];

			[textStorage replaceCharactersInRange:NSMakeRange(0, [textStorage length]) withString:[info stringByAppendingString:aPageOfLyrics]];

			[textStorage setAttributes:textAttributes range:NSMakeRange(0, [info length])];
			[textStorage setAttributes:smallTextAttributes range:NSMakeRange([info length], [aPageOfLyrics length])];

			[textStorage endEditing];

			[outputArea scrollRangeToVisible:NSMakeRange([textStorage length], 1)];
			pages ++;
		} while ([outputArea frame].size.height > [window frame].size.height);
		pages --;

		[smallTextAttributes release];

		for (uint32_t i = 0; i < pages; i++) // store lyrics pages
		{
			NSUInteger length = [lyrics length] / pages;

			[songLyricsArray addObject:[lyrics substringWithRange:[lyrics lineRangeForRange:NSMakeRange(i * length, length)]]];
		}

		//asl_NSLog_debug(@"configurePages:\n songLyricsArray: %@\n", [songLyricsArray description]);

		if (pages > 1 && !hidden)
			[buttonWindow orderFront:self];

	}
}

- (void)updateText
{
	[self configurePages];

	NSTextStorage *textStorage = [outputArea textStorage];


	NSString *str = [NSString stringWithFormat:@"%d/%ld", currentPage+1, (unsigned long)[songLyricsArray count]];
	NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:str attributes:[NSDictionary dictionaryWithObject:[textAttributes objectForKey:NSShadowAttributeName] forKey:NSShadowAttributeName]];
	[as setAlignment:NSCenterTextAlignment range:NSMakeRange(0, [str length])];
	[scrollTextField setAttributedStringValue:as];
	[as release];


	if (!([iTunes state] == kPlaying) ||
		([[iTunes lyrics] isEqualToString:@""] && (![userDefaults boolForKey:kPrependSonginfoKey] || ![userDefaults boolForKey:kPrependAlsoWhenEmptyKey])))
	{
		[textStorage beginEditing];
		[textStorage deleteCharactersInRange:NSMakeRange(0, [textStorage length])];
		[textStorage endEditing];

		[window setBackgroundColor: [NSColor clearColor]];
		[window display];
	}
	else
	{
		NSFont				*ourFont = [textAttributes objectForKey:NSFontAttributeName];
		NSString			*info, *text;
		NSMutableDictionary *lyricsTextAttributes = [textAttributes mutableCopy];
		NSMutableDictionary *gapTextAttributes = [textAttributes mutableCopy];
		if ((NSUInteger) currentPage >= [songLyricsArray count]) currentPage = [songLyricsArray count];
		NSUInteger			lyricsLength = [(NSString *)[songLyricsArray objectAtIndex:currentPage] length];

		[window setBackgroundColor: [NSUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:kWindowBackgroundColorDataKey]]];
		[window orderOut:self];


		if ([userDefaults boolForKey:kPrependSonginfoKey])
		{
			info = [userDefaults objectForKey:kSonginfoKey];

			if ([[iTunes album] isEqualToString:@""])
				 info = [info stringByReplacingOccurrencesOfString:@"(#r)" withString:@""];

			if ([[iTunes year] isEqualToString:@""])
				info = [info stringByReplacingOccurrencesOfString:@"(#y)" withString:@""];

			info = [info stringByReplacingOccurrencesOfString:@"#a" withString:@"ARTIST_FUCKINGUNIQUESHITDUCKQUAK"];
			info = [info stringByReplacingOccurrencesOfString:@"#t" withString:@"TITLE_FUCKINGUNIQUESHITDUCKQUAK"];
			info = [info stringByReplacingOccurrencesOfString:@"#r" withString:@"ALBUM_FUCKINGUNIQUESHITDUCKQUAK"];
			info = [info stringByReplacingOccurrencesOfString:@"#y" withString:@"YEAR_FUCKINGUNIQUESHITDUCKQUAK"];

			info = [info stringByReplacingOccurrencesOfString:@"ARTIST_FUCKINGUNIQUESHITDUCKQUAK" withString:[iTunes artist] ? [iTunes artist] : @""];
			info = [info stringByReplacingOccurrencesOfString:@"TITLE_FUCKINGUNIQUESHITDUCKQUAK" withString:[iTunes title] ? [iTunes title] : @""];
			info = [info stringByReplacingOccurrencesOfString:@"ALBUM_FUCKINGUNIQUESHITDUCKQUAK" withString:[iTunes album] ? [iTunes album] : @""];
			info = [info stringByReplacingOccurrencesOfString:@"YEAR_FUCKINGUNIQUESHITDUCKQUAK" withString:[iTunes year] ? [iTunes year] : @""];

			info = [info stringByAppendingString:@"\n"];
		}
		else
			info = @"";


		text = [NSString stringWithFormat:@"%@%@%@", info, @"\n", [songLyricsArray objectAtIndex:currentPage]];

		[gapTextAttributes setObject:[NSFont fontWithName:[ourFont fontName] size:15] forKey:NSFontAttributeName];

		asl_NSLog_debug(@"updateText:\n info: %@\n", info);
//		asl_NSLog_debug(@"updateText:\n text: %@\n", text);

		do
		{
			[textStorage beginEditing];
			[textStorage replaceCharactersInRange:NSMakeRange(0, [textStorage length]) withString:text];
			[lyricsTextAttributes setObject:ourFont forKey:NSFontAttributeName];
			NSMutableParagraphStyle *ps = [[lyricsTextAttributes objectForKey:NSParagraphStyleAttributeName] mutableCopy];
			[ps setLineHeightMultiple:[userDefaults floatForKey:kTextLineSpacingKey]];
			[lyricsTextAttributes setObject:ps forKey:NSParagraphStyleAttributeName];
			[ps release];

			[textStorage setAttributes:textAttributes range:NSMakeRange(0, [info length])];
			[textStorage setAttributes:gapTextAttributes range:NSMakeRange([info length], 1)];
			[textStorage setAttributes:lyricsTextAttributes range:NSMakeRange([info length] + 1, lyricsLength)];

			[textStorage endEditing];

			[outputArea scrollRangeToVisible:NSMakeRange([textStorage length], 1)];

			ourFont = [NSFont fontWithName:[ourFont fontName] size:[ourFont pointSize] - 0.5];
		} while ([outputArea frame].size.height > [window frame].size.height);

		asl_NSLog_debug(@"updateText:\n ourFont pointSize = %f\n", [ourFont pointSize] + 0.5);

		short times = 0;

		if ([userDefaults integerForKey:kTextVerticalAlignmentKey])
		{
			do
			{
				times++;
				[textStorage beginEditing];
				[textStorage replaceCharactersInRange:NSMakeRange(0, 0) withString:@"\n"];
				[textStorage endEditing];

				[outputArea scrollRangeToVisible:NSMakeRange([textStorage length], 1)];
			} while ([outputArea frame].size.height <= [window frame].size.height);

			[textStorage beginEditing];

			[textStorage deleteCharactersInRange:NSMakeRange(0, 1)];
			times -= 1;

			if ([userDefaults integerForKey:kTextVerticalAlignmentKey] == 1)
			{
				[textStorage deleteCharactersInRange:NSMakeRange(0, times/2)];
				times = times - (times/2);
			}

			[textStorage endEditing];
        }

//		if (![userDefaults boolForKey:kPrependSonginfoKey]) times--;

		NSFont *font = [NSFont fontWithName:[ourFont fontName] size:(![userDefaults boolForKey:kPrependSonginfoKey]) ? 15 : [userDefaults doubleForKey:kTextFontSizeKey]];
		CGFloat lineHeight = [layoutManager defaultLineHeightForFont:font];
		float songinfoHeight = heightForStringDrawing([info stringByReplacingOccurrencesOfString:@"\n" withString:@""], font, [window frame].size.width);
//		printf("FZDF %f ", songinfoHeight);
		if (![userDefaults boolForKey:kPrependSonginfoKey]) songinfoHeight = 0;
		int xorigin = 0, yorigin = [window frame].origin.y + [window frame].size.height - 20 - times * lineHeight - songinfoHeight;

		if ([userDefaults integerForKey:kTextHorizontalAlignmentKey] == 0)		xorigin = [window frame].origin.x;
		else if ([userDefaults integerForKey:kTextHorizontalAlignmentKey] == 1)	xorigin = [window frame].origin.x + [window frame].size.width/2.0 - 30;
		else if ([userDefaults integerForKey:kTextHorizontalAlignmentKey] == 2)	xorigin = [window frame].origin.x + [window frame].size.width - 65;

		asl_NSLog_debug(@"updateText:\n times %i\n", times);
//		asl_NSLog_debug(@"updateText:\n sud %@\n", [[userDefaults dictionaryRepresentation] description]);
		asl_NSLog_debug(@"updateText:\n lineheight %f\n", lineHeight);
		asl_NSLog_debug(@"updateText:\n xorigin %i yorigin %i\n", xorigin, yorigin);

		[buttonWindow setFrame:NSMakeRect(xorigin, yorigin, 70, 20) display:YES];

        if (hidden)
            [window orderOut:self];
        else
        {
            [window orderFront:self];
            [window display];
        }
		[lyricsTextAttributes release];
		[gapTextAttributes release];
	}
}

- (void)bringToFront
{
	asl_NSLog_debug(@"bringToFront");
    if (!hidden)
    {
  		if ([window isVisible])
		{
			[window orderOut:self];
			[window orderFront:self];
			[window display];
        }

		if ([buttonWindow isVisible])
		{
			[buttonWindow orderOut:self];
			[buttonWindow orderFront:self];
			[buttonWindow display];
		}
		//[self updateText];
    }
}

- (void)setupTimers
{
	if ([userDefaults boolForKey:kAutoTurnKey])
	{
		[self clearTimers];

		if ([songLyricsArray count] > 1 && [iTunes state] == kPlaying)
		{
			for (unsigned long i = 1; i <= [songLyricsArray count] - 1; i++)
			{
				NSTimer *timer = [[NSTimer alloc] initWithFireDate:[[[NSDate alloc] initWithTimeInterval: i * ([iTunes length] / [songLyricsArray count]) sinceDate:[iTunes start]] autorelease] interval:0 target:self selector:@selector(turnPageTimer:) userInfo:NULL repeats:NO];

				asl_NSLog_debug(@"adding timer: ituneslength %i songarraycount %li start %@ timeinterval %li  FIREDATE: %@", [iTunes length], [songLyricsArray count], [iTunes start], i * ([iTunes length] / [songLyricsArray count]), [[[[NSDate alloc] initWithTimeInterval: i * ([iTunes length] / [songLyricsArray count]) sinceDate:[iTunes start]] autorelease] description]);

				[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
				[timers addObject:timer];
                [timer release];
			}
		}
	}
}

- (void)clearTimers
{
	asl_NSLog_debug(@"clearTimers %@", [timers description]);

	for (NSTimer *timer in timers)
		[timer invalidate];

	[timers removeAllObjects];
}

- (void)turnPageTimer:(id)sender
{
	asl_NSLog_debug(@"turnPageTimer: %@", [sender description]);

	[self nextPageClicked:nil];
}

- (void)toggleVisibility
{
	if (!hidden)
	{
		[window orderOut:self];
		[buttonWindow orderOut:self];
	}
	else
	{
		[window orderFront:self];
		if ([songLyricsArray count] > 1)
			[buttonWindow orderFront:self];
	}

	hidden = !hidden;
}
@end


float heightForStringDrawing(NSString *myString, NSFont *myFont, float myWidth)
{
	NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init]
									  autorelease];
	NSTextStorage *textStorage = [[[NSTextStorage alloc] initWithString:myString] autorelease];
	NSTextContainer *textContainer = [[[NSTextContainer alloc] initWithContainerSize: NSMakeSize(myWidth, FLT_MAX)] autorelease];


	[layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:layoutManager];

	[textStorage addAttribute:NSFontAttributeName value:myFont range:NSMakeRange(0, [textStorage length])];
	[textContainer setLineFragmentPadding:0.0];

	[layoutManager glyphRangeForTextContainer:textContainer];
	return [layoutManager usedRectForTextContainer:textContainer].size.height;
}


@implementation  MyTextView

- (void)drawRect:(NSRect)rect
{
	
	if (disableAntiAliasing)
	{
		BOOL saved = [[NSGraphicsContext currentContext] shouldAntialias];
		[[NSGraphicsContext currentContext] setShouldAntialias: NO];
		
		[super drawRect:rect];

		[[NSGraphicsContext currentContext] setShouldAntialias:saved];
	}
	else
		[super drawRect:rect];

	return;
}
@end