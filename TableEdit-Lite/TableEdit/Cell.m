//
//  Cell.m
//  TableEdit-Lite
//
//  Created by CoreCode on 07.09.15.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "Cell.h"
#import "AddressHelper.h"


@implementation Cell

@dynamic cellName;

+ (Cell *)cellWithColumnIndex:(NSInteger)columnIndex rowIndex:(NSInteger)rowIndex column:(NSTableColumn *)column
{
	Cell *c = Cell.new;

	c.columnIndex = columnIndex;
	c.rowIndex = rowIndex;
	c.column = column;

	return c;
}

- (NSString *)cellName
{ // TODO: could cache this
	return [AddressHelper indicesToString:self.columnIndex rowIndex:self.rowIndex];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:makeString(@"%li\n%li", (long)_rowIndex, (long)_columnIndex)];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if ((self = super.init))
	{
		NSString *str =  coder.decodeObject;
		self.rowIndex = str.lines[0].integerValue;
		self.columnIndex = str.lines[1].integerValue;
	}
	return self;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
        return NO;
    else
    {
        Cell *otherCell = object;
        BOOL equal = (otherCell.rowIndex == self.rowIndex) && (otherCell.columnIndex == self.columnIndex);

		return equal;
    }
}

- (NSUInteger)hash
{
	return _rowIndex + (_columnIndex << 40);
}

- (NSString *)description
{
	return self.cellName;
}
@end
