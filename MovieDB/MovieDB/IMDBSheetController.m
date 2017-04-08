//
//  IMDBSheetController.m
//
//  Created by CoreCode on 24.10.09.
/*	Copyright © 2017 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "IMDBSheetController.h"
#import "InfoHelper.h"
#import "MovieDocument.h"

@implementation IMDBSheetController

- (void)awakeFromNib
{
	//[imdbTableView setTarget:self];
	imdbTableView.doubleAction = @selector(selectAction:);
	
	[super awakeFromNib];
}	

#pragma mark *** IBAction action-methods ***

- (IBAction)lookupAction:(id)sender
{
	imdbTitleTextField.stringValue = [movieArrayController.selection valueForKey:@"title"];
	
	[NSApp beginSheet:imdbSheetWindow modalForWindow:[owner windowForSheet] modalDelegate:nil didEndSelector:nil contextInfo:nil];

	[self searchAgainAction:self];
}

- (IBAction)searchAgainAction:(id)sender
{
	[progressIndicator startAnimation:self];
    [progressIndicator setUsesThreadedAnimation:YES];

	if ([sender isKindOfClass:[NSString class]])
	{
		imdbTitleTextField.stringValue = sender;
		[NSApp beginSheet:imdbSheetWindow modalForWindow:[owner windowForSheet] modalDelegate:nil didEndSelector:nil contextInfo:nil];
	}



    NSString *infoURL = makeString(@"https://www.omdbapi.com/?s=%@&r=json&type=movie", imdbTitleTextField.stringValue);
    LOG(infoURL);
    NSDictionary *info = infoURL.escaped.URL.download.JSONDictionary;
    LOG(info);
    answers = info[@"Search"];
	
	[imdbTableView reloadData];
	
	[progressIndicator stopAnimation:self];
}

- (IBAction)selectAction:(NSButton *)sender
{
	if ([sender.title isEqualToString:@"Select"])
	{
        if (!answers.count) return;

		NSString *imdbID;
		if (imdbButtonCell.state == NSOnState)
		{		
			imdbID = answers[imdbTableView.selectedRow][@"imdbID"];

            assert([imdbID hasPrefix:@"tt"]);
        }
		else
		{
			int imdbNumber = imdbDefineTextField.stringValue.intValue;
			if (imdbNumber == 0)
			{
				NSArray *list = [NSArray arrayWithArray:[imdbDefineTextField.stringValue componentsSeparatedByString:@"/"]];
				
				for (NSString *component in list)
				{
					if ([component hasPrefix:@"tt"])
					{
                        imdbID = component;
						break;
					}
				}
				
				if (!imdbID.length)
				{
					NSBeep();
					return;
				}
			}
            else
            {
                NSString *prefix = @"tt0000000";


                imdbID = [[prefix substringToIndex:9 - imdbDefineTextField.stringValue.length] stringByAppendingString:imdbDefineTextField.stringValue];
            }
			defineButtonCell.state = NSOffState;
			imdbButtonCell.state = NSOnState;
		}
		
		[NSApp endSheet:imdbSheetWindow];
		[imdbSheetWindow orderOut:self];
		
		
		[((MovieDocument *)owner) doProgressSheet:YES];
		
		[InfoHelper retrieveInfo:imdbID forMovie:movieArrayController.selection];
		
		[movieArrayController rearrangeObjects];
		[((MovieDocument *)owner) tableViewSelectionDidChange:nil];

		[owner doProgressSheet:NO];
	}
	else
	{
		[NSApp endSheet:imdbSheetWindow];
		[imdbSheetWindow orderOut:self];	
	}
	
	answers = nil;
}

- (IBAction)openAction:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.imdb.com"]];
}

#pragma mark *** NSTableDataSource protocol-methods ***

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return answers.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	NSDictionary *answer = answers[row];

    return makeString(@"%@ (%@)", answer[@"Title"], answer[@"Year"]);
}
@end