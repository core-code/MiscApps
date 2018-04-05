//
//  GridTableHeaderView.m
//  TableEdit-Lite
//
//  Created by CoreCode on 20.01.15.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "GridTableHeaderView.h"
#import "Document.h"


@implementation GridTableHeaderView

- (NSMenu *)menuForEvent:(NSEvent *)event
{
	NSInteger columnForMenu = [self columnAtPoint:[self convertPoint:event.locationInWindow fromView:nil]];
	if (columnForMenu >= 1)
	{
		NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
        [menu insertItemWithTitle:@"Sort column descending without affecting others" action:@selector(sortSingleColumnDescending:) keyEquivalent:@"" atIndex:0];
        [menu insertItemWithTitle:@"Sort column ascending  without affecting others" action:@selector(sortSingleColumnAscending:) keyEquivalent:@"" atIndex:0];
        [menu insertItemWithTitle:@"Sort selected rows of column descending" action:@selector(sortDescendingSelected:) keyEquivalent:@"" atIndex:0];
        [menu insertItemWithTitle:@"Sort selected rows of column ascending" action:@selector(sortAscendingSelected:) keyEquivalent:@"" atIndex:0];
		[menu insertItemWithTitle:@"Sort whole column descending" action:@selector(sortDescending:) keyEquivalent:@"" atIndex:0];
		[menu insertItemWithTitle:@"Sort whole column ascending" action:@selector(sortAscending:) keyEquivalent:@"" atIndex:0];


		menu.associatedValue = @(columnForMenu);
	
		return menu;
	}
	else
		return nil;

}

- (void)sortAscending:(NSMenuItem *)sender
{
    [self.document sortColumn:[sender.menu.associatedValue intValue] sortAscending:YES onlySelected:NO wholeTable:YES];
}

- (void)sortDescending:(NSMenuItem *)sender
{
	[self.document sortColumn:[sender.menu.associatedValue intValue] sortAscending:NO onlySelected:NO wholeTable:YES];
}

- (void)sortSingleColumnAscending:(NSMenuItem *)sender
{
    [self.document sortColumn:[sender.menu.associatedValue intValue] sortAscending:YES onlySelected:NO wholeTable:NO];
}

- (void)sortSingleColumnDescending:(NSMenuItem *)sender
{
    [self.document sortColumn:[sender.menu.associatedValue intValue] sortAscending:NO onlySelected:NO wholeTable:NO];
}

- (void)sortAscendingSelected:(NSMenuItem *)sender
{
	[self.document sortColumn:[sender.menu.associatedValue intValue] sortAscending:YES onlySelected:YES wholeTable:YES];
}

- (void)sortDescendingSelected:(NSMenuItem *)sender
{
	[self.document sortColumn:[sender.menu.associatedValue intValue] sortAscending:NO onlySelected:YES wholeTable:YES];
}
@end
