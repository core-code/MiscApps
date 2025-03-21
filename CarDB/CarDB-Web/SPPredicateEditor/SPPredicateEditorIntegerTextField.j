/*
 * SPPredicateEditorIntegerTextField.j
 * AppKit
 *
 * Created by JC Bordes [jcbordes at gmail dot com] Copyright 2012 JC Bordes
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */
 
@import <AppKit/CPTextField.j>

@implementation SPPredicateEditorUnsignedIntegerTextField : CPTextField
{
}

-(void)keyDown:(CPEvent)anEvent
{
	if ([anEvent keyCode] == 13)
	{
		[[self window] makeFirstResponder:nil];
		[[CPNotificationCenter defaultCenter] postNotificationName:"squirrelsarefunny" object:self];
	}
	if([self isCharacterValid:[anEvent characters]])
	{
		[super keyDown:anEvent];
		return;
	}
	[[[self window] platformWindow] _propagateCurrentDOMEvent:NO];
}

-(BOOL)isCharacterValid:(CPString)str
{
	var code=str.charCodeAt(0);
	if(code==0x1B||code==0xD||code==0x8||code==0x7F||code>0xF700||(code>=0x30&&code<=0x39))
		return YES;
	return NO;
}

@end

@implementation SPPredicateEditorIntegerTextField : CPTextField
{
}

-(void)keyDown:(CPEvent)anEvent
{
	if ([anEvent keyCode] == 13)
	{
		[[self window] makeFirstResponder:nil];
		[[CPNotificationCenter defaultCenter] postNotificationName:"squirrelsarefunny" object:self];
	}
	if([self isCharacterValid:[anEvent characters]])
	{
		[super keyDown:anEvent];
		return;
	}
	[[[self window] platformWindow] _propagateCurrentDOMEvent:NO];
}

-(BOOL)isCharacterValid:(CPString)str
{
	var code=str.charCodeAt(0);
	var range=[self selectedRange];
	if(range.location==0&&(code==0x2B||code==0x2D))
		return YES;
	if(code==0x1B||code==0xD||code==0x8||code>0xF700||code==0x7F||(code>=0x30&&code<=0x39))
		return YES;
	return NO;
}

@end