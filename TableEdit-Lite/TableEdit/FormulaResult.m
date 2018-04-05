//
//  FormulaResult.m
//  TableEdit-Lite
//
//  Created by CoreCode on 01.12.15.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "FormulaResult.h"
#import "AddressHelper.h"
#import <wchar.h>

//
//extern Cell *cell;
//extern DocumentData *data;
//extern NSDictionary <NSString *, NSMutableArray <NSString *> *> *dependencyListPerCell;
//
//
//@interface Reference ()
//
//@property (strong, nonatomic) NSArray <Cell *> *cells;
//
//@end
//
//
//@implementation Reference
//
//+ (Reference *)referenceWithCells:(NSArray <Cell *> *)cells
//{
//    Reference *ref = [Reference new];
//
//    ref.cells = cells;
//
//    return ref;
//}
//
//+ (Reference *)referenceWithCell:(NSString *)str
//{
//    Reference *ref = [Reference new];
//
//    coordinates c = [AddressHelper cellStringToIndex:str];
//
//    ref.cells = @[[Cell cellWithColumnIndex:c.column rowIndex:c.row column:NULL]];
//
//    return ref;
//}
//
//+ (Reference *)referenceWithNamedRange:(NSString *)str
//{
//    @throw ([NSException exceptionWithName:@"#NAMED_RANGE!" reason:@(__LINE__).stringValue userInfo:nil]);
//}
//
//+ (Reference *)referenceWithVRange:(NSString *)str
//{
//    NSArray <NSString *> *comp = [str componentsSeparatedByString:@":"];
//    assert(comp.count == 2);
//
//    NSUInteger firstColumn = [AddressHelper columnStringToIndex:comp[0]];
//    NSUInteger lastColumn = [AddressHelper columnStringToIndex:comp[1]];
//
//    if (lastColumn < firstColumn)
//        @throw ([NSException exceptionWithName:@"#REF!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//
//    NSMutableArray <Cell *> *cells = makeMutableArray();
//
//    for (NSUInteger column = firstColumn; column <= lastColumn; column++)
//    {
//        for (NSUInteger row = 0; row < data.rowCount; row++)
//        {
//            [cells addObject:[Cell cellWithColumnIndex:column rowIndex:row column:NULL]];
//        }
//    }
//
//    Reference *ref = [Reference new];
//
//    ref.cells = cells.immutableObject;
//
//    return ref;
//}
//
//+ (Reference *)referenceWithIntersectionFunctionCall:(Reference *)ref1 :(Reference *)ref2
//{
//    NSMutableOrderedSet <Cell *> *intersection = ref1.cells.orderedSet.mutableObject;
//
//    [intersection intersectOrderedSet:ref2.cells.orderedSet];
//
//    if (!intersection.count)
//        @throw ([NSException exceptionWithName:@"#NULL!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//
//    return [Reference referenceWithCells:intersection.array];
//}
//
//+ (Reference *)referenceWithHRange:(NSString *)str
//{
//    NSArray <NSString *> *comp = [[str replaced:@"$" with:@""] componentsSeparatedByString:@":"];
//    assert(comp.count == 2);
//    assert(comp[0].integerValue > 0);
//    assert(comp[1].integerValue > 0);
//
//    NSUInteger firstRow = comp[0].integerValue - 1;
//    NSUInteger lastRow = comp[1].integerValue - 1;
//
//
//    if (lastRow < firstRow)
//        @throw ([NSException exceptionWithName:@"#REF!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//
//    NSMutableArray <Cell *> *cells = makeMutableArray();
//
//    for (NSUInteger column = 0; column < data.columnCount; column++)
//    {
//        for (NSUInteger row = firstRow; row <= lastRow; row++)
//        {
//            [cells addObject:[Cell cellWithColumnIndex:column rowIndex:row column:NULL]];
//        }
//    }
//
//    Reference *ref = [Reference new];
//
//    ref.cells = cells.immutableObject;
//
//    return ref;
//}
//
//+ (Reference *)referenceWithRangeFunctionCall:(Reference *)ref1 :(Reference *)ref2
//{
//    if (ref1.cells.count != 1 || ref2.cells.count != 1)
//        @throw ([NSException exceptionWithName:@"#TODO_MULTIRANGE_NOT_SUPPORTED!" reason:@(__LINE__).stringValue userInfo:nil]); // e.g. file:///Volumes/RAID/_TMP/_XLS/spreadsheets/bill_williams_iii__1381__EES%20June%20Dailies.xlsx SUM(I8:K8:M8)
//
//
//    Cell *c1 = ref1.cells[0];
//    Cell *c2 = ref2.cells[0];
//
//    if (!((c1.columnIndex <= c2.columnIndex) && (c1.rowIndex <= c2.rowIndex)))
//        @throw ([NSException exceptionWithName:@"#TODO_INVERTEDRANGE_NOT_SUPPORTED!" reason:@(__LINE__).stringValue userInfo:nil]); // check excel
//
//
//
//
//    NSMutableArray <Cell *> *cells = makeMutableArray();
//
//    for (NSInteger column = c1.columnIndex; column <= c2.columnIndex; column++)
//    {
//        for (NSInteger row = c1.rowIndex; row <= c2.rowIndex; row++)
//        {
//            [cells addObject:[Cell cellWithColumnIndex:column rowIndex:row column:NULL]];
//        }
//    }
//
//    Reference *ref = [Reference new];
//
//    ref.cells = cells.immutableObject;
//
//    return ref;
//}
//
//
//
//+ (Reference *)referenceWithReferenceFunctionCall:(NSString *)function arguments:(NSArray <NSObject <FormulaResult>* > *)arguments
//{
//    if ([function isEqualToString:@"INDEX"])
//    {
//        Reference *ref = arguments[0].id;
//
//        if (arguments.count > 4 || arguments.count < 2)
//            @throw ([NSException exceptionWithName:@"#INDEX_FUNCTION_RANGE_FORMAT!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//        NSObject <FormulaResult>* row_num = arguments[1].id;
//        NSObject <FormulaResult>* col_num;
//        if (arguments.count > 2)
//            col_num = arguments[2].id;
//        NSObject <FormulaResult>* area_num;
//        if (arguments.count > 3)
//            area_num = arguments[3].id;
//
//        if (![ref isKindOfClass:[Reference class]])
//            @throw ([NSException exceptionWithName:@"#INDEX_FUNCTION_INVALID_REFERENCE!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//        if ([ref isKindOfClass:UnionReference.class])
//        {
//            NSInteger area = area_num.numberValue.integerValue-1;
//            if (area < 0) area = 0;
//
//
//            UnionReference *unionRef = ref.id;
//
//            if (area >= (NSInteger)unionRef.areas.count)
//                @throw ([NSException exceptionWithName:@"#INDEX_FUNCTION_INVALID_AREA!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//            ref = unionRef.areas[area];
//        }
//        else if (area_num.numberValue.integerValue)
//            @throw ([NSException exceptionWithName:@"#INDEX_FUNCTION_AREA_BUT_NO_UNION!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//
//        if ((id)row_num == [NSNull null])        row_num = @(0);
//        if ((id)col_num == [NSNull null])        col_num = @(0);
//
//        if (!row_num.numberValue.integerValue && !col_num.numberValue.integerValue)
//            return ref;
//        else if (row_num.numberValue.integerValue && !col_num.numberValue.integerValue)
//        {
//            NSInteger rowNumFinal = row_num.numberValue.integerValue-1;
//
//            NSArray <Reference *> *rows = ref.rows;
//
//            if (rowNumFinal < 0 || rowNumFinal >= (NSInteger)rows.count)
//                @throw ([NSException exceptionWithName:@"#INDEX_FUNCTION_INVALID_ROWNUM!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//
//            return rows[rowNumFinal];
//        }
//        else if (!row_num.numberValue.integerValue && col_num.numberValue.integerValue)
//        {
//            NSInteger colNumFinal = col_num.numberValue.integerValue-1;
//
//            NSArray <Reference *> *cols = ref.columns;
//
//            if (colNumFinal < 0 || colNumFinal >= (NSInteger)cols.count)
//                @throw ([NSException exceptionWithName:@"#INDEX_FUNCTION_INVALID_COLNUM!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//
//            return cols[colNumFinal];
//        }
//        else
//        {
//
//            NSInteger colNumFinal = col_num.numberValue.integerValue-1;
//
//            NSArray <Reference *> *cols = ref.columns;
//
//            if (colNumFinal < 0 || colNumFinal >= (NSInteger)cols.count)
//                @throw ([NSException exceptionWithName:@"#INDEX_FUNCTION_INVALID_COLNUM!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//
//            NSArray <Reference *> *rows = [cols[colNumFinal] rows];
//
//            NSInteger rowNumFinal = row_num.numberValue.integerValue-1;
//
//            if (rowNumFinal < 0 || rowNumFinal >= (NSInteger)rows.count)
//                @throw ([NSException exceptionWithName:@"#INDEX_FUNCTION_INVALID_ROWNUM!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//
//            return rows[rowNumFinal];
//        }
//    }
//    else if ([function isEqualToString:@"INDIRECT"])
//    {
//        NSString *ref_text = arguments[0].id;
//
//        { // i'm not sure how that is supposed to work
//            LogicalValue *a1 = [LogicalValue logicalValueWithBOOL:YES];
//            if (arguments.count > 1)
//                a1 = arguments[1].id;
//
//            if (a1.numberValue.integerValue == 0)
//                @throw ([NSException exceptionWithName:@"#INDIRECT_FUNCTION_R1C1_FORMAT!" reason:@(__LINE__).stringValue userInfo:nil]);
//        }
//
//        if ([ref_text isKindOfClass:[NSString class]])
//        {
//            if ([ref_text countOccurencesOfString:@":"] == 1)
//            {
//                NSArray <NSString *>*refs = [ref_text split:@":"];
//
//                return [Reference referenceWithRangeFunctionCall:[Reference referenceWithCell:refs[0]] :[Reference referenceWithCell:refs[1]]];
//            }
//            else
//                return [Reference referenceWithCell:ref_text];
//        }
//        else if ([ref_text isKindOfClass:[Reference class]])
//            return (Reference *)ref_text;
//        else
//            assert(0);
//    }
//    else if ([function isEqualToString:@"OFFSET"])
//    {
//        Reference *ref = arguments[0].id;
//
//        if (![ref isKindOfClass:Reference.class])
//            @throw ([NSException exceptionWithName:@"#OFFSET_FUNCTION_INVALID_FORMAT!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//        NSObject <FormulaResult> *row_num = arguments[1].id;
//        NSObject <FormulaResult> *col_num = arguments[2].id;
//        NSObject <FormulaResult> *height, *width;
//        if (arguments.count > 3)
//            height =  [[NSNull null] isEqual:arguments[3]] ? nil : arguments[3].id;
//        if (arguments.count > 4)
//            width = [[NSNull null] isEqual:arguments[4]] ? nil : arguments[4].id;
//
//        NSArray <Cell *> *newCells = [ref.cells mapped:^id(Cell *input)
//        {
//              return [Cell cellWithColumnIndex:input.columnIndex + col_num.numberValue.integerValue
//                                      rowIndex:input.rowIndex + row_num.numberValue.integerValue
//                                        column:nil];
//        }];
//
//        if (height.numberValue.integerValue || width.numberValue.integerValue)
//        {
//            Cell *ul = [ref upperleftCell];
//
//            newCells = [newCells filtered:^BOOL(Cell *input)
//            {
//                BOOL violatesWidth = NO, violatesHeight = NO;
//
//                if (width.numberValue.integerValue)
//                    violatesWidth = input.columnIndex - ul.columnIndex > width.numberValue.integerValue;
//
//                if (height.numberValue.integerValue)
//                    violatesHeight = input.rowIndex - ul.rowIndex > height.numberValue.integerValue;
//
//                return violatesHeight || violatesWidth;
//            }];
//        }
//
//        return [Reference referenceWithCells:newCells];
//    }
//    else
//        assert(0);
//
//    return nil;
//}
//
//- (NSArray <Reference *> *)columns
//{
//    NSMutableDictionary <NSNumber *, NSMutableArray <Cell *> *> *columns = makeMutableDictionary();
//
//    for (Cell *c in self.cells)
//    {
//        if (!columns[@(c.columnIndex)])
//            columns[@(c.columnIndex)] = makeMutableArray();
//
//        [columns[@(c.columnIndex)] addObject:c];
//    }
//
//
//    NSArray <NSNumber *> *keys = [columns.allKeys sortedArrayUsingSelector:@selector(compare:)];
//    NSMutableArray <Reference *> *columnArray = makeMutableArray();
//
//    for (NSNumber *key in keys)
//    {
//        [columnArray addObject:[Reference referenceWithCells:columns[key]]];
//    }
//
//    return columnArray;
//}
//
//- (NSArray <Reference *> *)rows
//{
//    NSMutableDictionary <NSNumber *, NSMutableArray <Cell *> *> *rows = makeMutableDictionary();
//
//    for (Cell *c in self.cells)
//    {
//        if (!rows[@(c.rowIndex)])
//            rows[@(c.rowIndex)] = makeMutableArray();
//
//        [rows[@(c.rowIndex)] addObject:c];
//    }
//
//
//    NSArray <NSNumber *> *keys = [rows.allKeys sortedArrayUsingSelector:@selector(compare:)];
//    NSMutableArray <Reference *> *rowArray = makeMutableArray();
//
//    for (NSNumber *key in keys)
//    {
//        [rowArray addObject:[Reference referenceWithCells:rows[key]]];
//    }
//
//    return rowArray;
//}
//
//- (Cell *)upperleftCell
//{
//    Cell *bestCell = [Cell cellWithColumnIndex:INT_MAX rowIndex:INT_MAX column:nil];
//
//    for (Cell *c in self.cells)
//    {
//        if (c.columnIndex < bestCell.columnIndex ||
//            (c.columnIndex == bestCell.columnIndex && c.rowIndex < bestCell.rowIndex))
//            bestCell = c;
//    }
//
//    return bestCell;
//}
//
//- (Cell *)mainCell
//{
//    if (self.cells.count == 1)
//        return self.cells.firstObject;
//    else
//    {
//        NSArray <Cell *> *cellsInSameRowOrColumn = [self.cells filtered:^BOOL(Cell *input)
//        {
//            return input.rowIndex == cell.rowIndex || input.columnIndex == cell.columnIndex;
//        }];
//
//        if (cellsInSameRowOrColumn.count == 1)
//            return cellsInSameRowOrColumn.firstObject;
//    }
//
//    return nil;
//}
//
////- (NSInteger)integerValue
////{
////    Cell *mainCell = [self mainCell];
////
////    assert(mainCell);
////
////    [dependencyListPerCell[cell.cellName] addObject:mainCell.cellName];
////    NSObject <FormulaResult> *cellData = [data valueForRow:mainCell.rowIndex column:mainCell.columnIndex throw:YES];
////    return cellData.numberValueintegerValue];
////}
////
////- (double)doubleValue
////{
////    Cell *mainCell = [self mainCell];
////
////    assert(mainCell);
////
////    [dependencyListPerCell[cell.cellName] addObject:mainCell.cellName];
////    NSObject <FormulaResult> *cellData = [data valueForRow:mainCell.rowIndex column:mainCell.columnIndex throw:YES];
////    return [cellData doubleValue];
////}
//
//- (NSDate *)dateValue
//{
//    NSObject <FormulaResult> *cellData = self.value;
//
//    return cellData.dateValue;
//}
//
//- (NSNumber *)numberValue
//{
//    NSObject <FormulaResult> *cellData = self.value;
//
//    return cellData.numberValue;
//}
//
//- (NSString *)stringValue
//{
//    NSObject <FormulaResult> *cellData = self.value;
//
//    return [cellData stringValue];
//}
//
//- (LogicalValue *)logicalValue
//{
//    NSObject <FormulaResult> *cellData = self.value;
//
//    return [cellData logicalValue];
//}
//
//- (NSObject <FormulaResult>*)value
//{
//    Cell *mainCell = [self mainCell];
//
//    if (!mainCell)
//        @throw ([NSException exceptionWithName:@"#REF!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//
//    [dependencyListPerCell[cell.cellName] addObject:mainCell.cellName];
//    return [data valueForRow:mainCell.rowIndex column:mainCell.columnIndex throw:YES];
//}
//
//- (NSObject <FormulaResult>*)valueForCell:(NSUInteger)cellNumber
//{
//    Cell *chosenCell = self.cells[cellNumber];
//
//    assert(chosenCell);
//
////    [dependencyListPerCell[cell.cellName] addObject:chosenCell.cellName];
//    [self.cells apply:^(Cell *input)
//     {
//         [dependencyListPerCell[cell.cellName] addObject:input.cellName]; // else VLOOKUP has only first result as dependency not all possible result source cells
//     }];
//    
//    return [data valueForRow:chosenCell.rowIndex column:chosenCell.columnIndex throw:YES];
//}
//
//- (NSArray <NSNumber *> *)numberValuesSparse
//{
//    return [self.cells mapped:^id(Cell *input)
//    {
//        [dependencyListPerCell[cell.cellName] addObject:input.cellName];
//        NSNumber *num = [data valueForRow:input.rowIndex column:input.columnIndex throw:YES].numberValue;
//        return num;
//    }];
//}
//
//
//- (NSArray <NSNumber *> *)numberValues
//{
//    return [self.cells mapped:^id(Cell *input)
//    {
//        [dependencyListPerCell[cell.cellName] addObject:input.cellName];
//        NSNumber *num = [data valueForRow:input.rowIndex column:input.columnIndex throw:YES].numberValue;
//        return OBJECT_OR(num, @(0));
//    }];
//}
//
//- (NSArray <NSNumber *> *)numberOrDateNumberValuesSparse
//{
//    return [self.cells mapped:^id(Cell *input)
//    {
//        [dependencyListPerCell[cell.cellName] addObject:input.cellName];
//        
//        NSObject <FormulaResult> *value = [data valueForRow:input.rowIndex column:input.columnIndex throw:YES];
//        
//        if ([value isKindOfClass:NSString.class] && ((NSString *)value).length == 0)
//            return nil;
//        
//        NSNumber *num1 = value.numberValue;
//        if (num1)
//            return num1;
//        
//        NSDate *date = value.dateValue;
//        NSNumber *num2 = date.numberValue;
//        return num2;
//    }];
//}
//
//- (NSArray <NSNumber *> *)numberOrDateNumberValues
//{
//    return [self.cells mapped:^id(Cell *input)
//    {
//        [dependencyListPerCell[cell.cellName] addObject:input.cellName];
//        
//        NSObject <FormulaResult> *value = [data valueForRow:input.rowIndex column:input.columnIndex throw:YES];
//        
//        NSNumber *num1 = value.numberValue;
//        if (num1)
//            return num1;
//        
//        NSDate *date = value.dateValue;
//        NSNumber *num2 = date.numberValue;
//        return OBJECT_OR(num2, @(0));
//    }];
//}
//
//- (NSArray <NSDate *> *)dateValues
//{
//    return [self.cells mapped:^id(Cell *input)
//    {
//        [dependencyListPerCell[cell.cellName] addObject:input.cellName];
//        return [data valueForRow:input.rowIndex column:input.columnIndex throw:YES].dateValue;
//    }];
//}
//
//- (NSArray <NSString *> *)stringValues
//{
//    return [self.cells mapped:^id(Cell *input)
//    {
//        [dependencyListPerCell[cell.cellName] addObject:input.cellName];
//        return [data valueForRow:input.rowIndex column:input.columnIndex throw:YES].stringValue;
//    }];
//}
//
//- (NSArray <LogicalValue *> *)logicalValuesSparse
//{
//    return [self.cells mapped:^id(Cell *input)
//    {
//        [dependencyListPerCell[cell.cellName] addObject:input.cellName];
//        NSObject <FormulaResult> *value = [data valueForRow:input.rowIndex column:input.columnIndex throw:YES];
//
//        if ([value isKindOfClass:NSString.class] && ((NSString *)value).length == 0)
//            return nil;
//        
//       return value.logicalValue;
//    }];
//}
//
//- (NSArray <LogicalValue *> *)logicalValues
//{
//    return [self.cells mapped:^id(Cell *input)
//    {
//        [dependencyListPerCell[cell.cellName] addObject:input.cellName];
//        return [data valueForRow:input.rowIndex column:input.columnIndex throw:YES].logicalValue;
//    }];
//}
//
//- (NSArray <FormulaResult> *)values
//{
//    return [self.cells mapped:^id(Cell *input)
//    {
//        [dependencyListPerCell[cell.cellName] addObject:input.cellName];
//        return [data valueForRow:input.rowIndex column:input.columnIndex throw:YES];
//    }].id;
//}
//@end
//
//// UnionReference ***
//
//@interface UnionReference ()
//
//@property (strong, nonatomic) NSArray <Reference *> *areas;
//
//@end
//
//
//@implementation UnionReference
//
//+ (UnionReference *)referenceWithUnionFunctionCall:(NSArray <Reference *> *)refs
//{
//    NSMutableArray <Cell *> *unionCells = makeMutableArray();
//
//    for (Reference *ref in refs)
//        [unionCells addObjectsFromArray:ref.cells];
//
//
//    if (!unionCells.count)
//        @throw ([NSException exceptionWithName:@"#NULL!" reason:@(__LINE__).stringValue userInfo:nil]);
//
//    
//    UnionReference *ref = [UnionReference new];
//
//    ref.cells = unionCells;
//    ref.areas = refs;
//
//    return ref;
//}
//
//@end
//
//// ArrayReference ***
//
//@interface ArrayReference ()
//
//@property (strong, nonatomic) NSArray <NSObject <FormulaResult>*> *refs;
//
//@end
//
//
//@implementation ArrayReference
//
//+ (ArrayReference *)referenceWithArray:(NSArray <NSObject <FormulaResult>*> *)_refs
//{
//    ArrayReference *ref = [ArrayReference new];
//
//    ref.refs = _refs;
//
//    return ref;
//}
//
//- (NSArray <NSNumber *> *)numberValues
//{
//    return [self.refs mapped:^id(NSObject <FormulaResult>* input) { return OBJECT_OR(input.numberValue, @(0)); }];
//}
//
//- (NSArray <NSDate *> *)dateValues
//{
//    return [self.refs mapped:^id(NSObject <FormulaResult>* input) { return OBJECT_OR(input.dateValue, [NSDate dateWithTimeIntervalSince1970:0]); }];
//}
//
//- (NSArray <NSString *> *)stringValues
//{
//    return [self.refs mapped:^id(NSObject <FormulaResult>* input) { return OBJECT_OR(input.stringValue, @""); }];
//}
//
//- (NSArray <LogicalValue *> *)logicalValues
//{
//    return [self.refs mapped:^id(NSObject <FormulaResult>*input) { return OBJECT_OR(input.logicalValue, [LogicalValue logicalValueWithBOOL:NO]); }];
//}
//
//- (NSArray <FormulaResult> *)values
//{
//    return self.refs.id;
//}
//@end
//
//
//// LogicalValue ***
//
//@interface LogicalValue ()
//@property (nonatomic, strong) NSNumber *internalNumber;
//@end
//
//@implementation LogicalValue
//
//@dynamic stringValue, logicalValue, numberValue;
//
//+ (LogicalValue *)logicalValueWithBOOL:(BOOL)boolean
//{
//    LogicalValue *value = [[LogicalValue alloc] init];
//
//    if (value)
//    {
//        value.internalNumber = @(boolean);
//    }
//
//    return value;
//}
//
////- (NSInteger)integerValue
////{
////    return _internalNumber.integerValue;
////}
////
////- (double)doubleValue
////{
////    return _internalNumber.doubleValue;
////}
//
//- (NSNumber *)numberValue
//{
//    return _internalNumber;
//}
//
//- (NSString *)stringValue
//{
//    return (_internalNumber.integerValue == 0) ? @"FALSE" : @"TRUE";
//}
//
//- (LogicalValue *)logicalValue
//{
//    return self;
//}
//
//- (BOOL)isEqual:(id)object
//{
//    if (![object isKindOfClass:[self class]])
//        return NO;
//    else
//    {
//        LogicalValue *otherValue = object;
//        return ([otherValue.internalNumber isEqual:_internalNumber]);
//    }
//}
//- (NSUInteger)hash
//{
//    return _internalNumber.unsignedIntegerValue;
//}
//@end
//
//



@implementation NSString(FormulaResultCategory)
@dynamic dateValue, numberValue;

//- (LogicalValue *)logicalValue
//{
//    if ([self.lowercaseString isEqualToString:@"true"] || !IS_DOUBLE_EQUAL(self.doubleValue, 0.0))
//        return [LogicalValue logicalValueWithBOOL:YES];
//    else
//        return [LogicalValue logicalValueWithBOOL:NO];
//}

- (NSDate *)dateValue
{
	static NSArray <NSDateFormatter *> *dateInputFormatters;
    static NSMutableDictionary <NSString *, NSDate *> *cache; // this would be a perfect usecase for cocoa's built in cache API

	ONCE_PER_FUNCTION(^
	{
		NSMutableArray <NSDateFormatter *> *tmp = makeMutableArray();
		NSLocale *l = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];

		  for (NSString *dateFormat in @[@"EEE, d MMM yyyy", @"MM/dd/yy", @"M/d/yy", @"MM/dd/yyyy", @"M/d/yyyy", @"dd.MM.yyyy", @"d.M.yyyy", @"dd/MM/yyyy", @"d/M/yyyy", @"yyyy-MM-dd", @"yyyy-M-d", @"yyyy.MM.dd", @"yyyy.M.d", @""])
		  {
			  for (NSString *timeFormat in @[@"'T'HH:mm:ss'Z'", @" HH:mm:ss", @" HH:mm", @" hh:mm a", @""])
			  {
				  NSDateFormatter *df = [NSDateFormatter new];
				  df.dateFormat = [dateFormat stringByAppendingString:timeFormat].trimmedOfWhitespace;
				  df.locale = l;
				  df.timeZone = tz;
				  assert(excelBaseDate);
				  df.defaultDate = excelBaseDate;

				  [tmp addObject:df];
			  }
		  }
		  dateInputFormatters = tmp.immutableObject;

        cache = makeMutableDictionary();
	});


    NSDate *cachedData = cache[self];
    static int times = 0, cached = 0;

    times++;
    if (cachedData)
    {
        cached++;
        return cachedData;
    }

    if (cache.count > 1000 * 100)
    {
        cc_log(@"Warning: string date cache had to be cleaned (up to now we got %i requests and %i were answered from cache)", times, cached);
        [cache removeAllObjects];
    }


	for (NSDateFormatter *dateFormatter in dateInputFormatters)
	{
		NSDate *date = [dateFormatter dateFromString:self];

		if (date)
        {
			cache[self] = date;
            return date;
        }
	}

    NSDate *date = self.numberValue.dateValue;
    cache[self] = date;
	return date;
}
- (NSNumber *)numberValue
{
	static NSArray <NSNumberFormatter *> *numberInputFormatters;
	static NSCharacterSet *invalidCharacterSet;


	ONCE_PER_FUNCTION(^
	{
		  NSMutableArray <NSNumberFormatter *> *tmpFormatters = makeMutableArray();
		  NSMutableCharacterSet *tmpCS = NSMutableCharacterSet.decimalDigitCharacterSet;
		  NSString *currentSeparator = [NSLocale.currentLocale objectForKey:NSLocaleDecimalSeparator];
		  [tmpCS addCharactersInString:@"-"];
		  [tmpCS addCharactersInString:@",."];
		  [tmpCS addCharactersInString:currentSeparator];

//		  for (NSString *locID in NSLocale.availableLocaleIdentifiers)
//		  {
//
//			  NSLocale *loc = [NSLocale localeWithLocaleIdentifier:locID];
//			  NSString *separator = [loc objectForKey:NSLocaleDecimalSeparator];
//
//
//			  [tmpCS addCharactersInString:separator];
//		  }

		if (kNumberFormatKey.defaultInt != inputFormatSystem)
		{
			for (NSNumber *hasThousandSeparators in @[@(YES), @(NO)])
			{
				NSNumberFormatter *ul = NSNumberFormatter.new;
				ul.locale = NSLocale.systemLocale;
				ul.numberStyle = kCFNumberFormatterDecimalStyle;
				ul.hasThousandSeparators = hasThousandSeparators.boolValue;



				if (kNumberFormatKey.defaultInt == inputFormatDECCOMMA_GROUPPOINT || kNumberFormatKey.defaultInt == inputFormatDECCOMMA_GROUPSPACE)
					ul.decimalSeparator = @",";
				else if (kNumberFormatKey.defaultInt == inputFormatDECPOINT_GROUPCOMMA || kNumberFormatKey.defaultInt == inputFormatDECPOINT_GROUPSPACE)
					ul.decimalSeparator = @".";

				if (kNumberFormatKey.defaultInt == inputFormatDECCOMMA_GROUPPOINT)
					ul.thousandSeparator = @".";
				else if (kNumberFormatKey.defaultInt == inputFormatDECPOINT_GROUPCOMMA)
					ul.thousandSeparator = @",";
				else if (kNumberFormatKey.defaultInt == inputFormatDECCOMMA_GROUPSPACE|| kNumberFormatKey.defaultInt == inputFormatDECPOINT_GROUPSPACE)
					ul.thousandSeparator = @" ";


				if (hasThousandSeparators.boolValue)
				{
					[tmpCS addCharactersInString:ul.thousandSeparator];
					[tmpCS addCharactersInString:ul.decimalSeparator];
					[tmpCS addCharactersInString:ul.negativeSuffix];
					[tmpCS addCharactersInString:ul.negativePrefix];
				}
				//LOG(makeString(@"systemLocale: %@", [sl stringFromNumber:@(1234.5678)]));

				[tmpFormatters addObject:ul];
			}
		}

		  for (NSNumber *hasThousandSeparators in @[@(YES), @(NO)])
		  {
			  NSNumberFormatter *cl = NSNumberFormatter.new;
			  cl.locale = NSLocale.currentLocale;
			  cl.numberStyle = kCFNumberFormatterDecimalStyle;
			  cl.hasThousandSeparators = hasThousandSeparators.boolValue;
			  if (hasThousandSeparators.boolValue)
              {
                  [tmpCS addCharactersInString:cl.thousandSeparator];
                  [tmpCS addCharactersInString:cl.decimalSeparator];
                  [tmpCS addCharactersInString:cl.negativeSuffix];
                  [tmpCS addCharactersInString:cl.negativePrefix];
              }
			  //LOG(makeString(@"currentLocale: %@", [cl stringFromNumber:@(1234.5678)]));

			  [tmpFormatters addObject:cl];
		  }

		  for (NSNumber *hasThousandSeparators in @[@(YES), @(NO)])
		  {
			  NSNumberFormatter *sl = NSNumberFormatter.new;
			  sl.locale = NSLocale.systemLocale;
			  sl.numberStyle = kCFNumberFormatterDecimalStyle;
			  sl.hasThousandSeparators = hasThousandSeparators.boolValue;
			  if (hasThousandSeparators.boolValue)
              {
                  [tmpCS addCharactersInString:sl.thousandSeparator];
                  [tmpCS addCharactersInString:sl.decimalSeparator];
                  [tmpCS addCharactersInString:sl.negativeSuffix];
                  [tmpCS addCharactersInString:sl.negativePrefix];
              }
			  //LOG(makeString(@"systemLocale: %@", [sl stringFromNumber:@(1234.5678)]));

			  [tmpFormatters addObject:sl];
		  }

		  for (NSNumber *hasThousandSeparators in @[@(YES), @(NO)])
		  {
			  NSNumberFormatter *el = NSNumberFormatter.new;
			  el.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
			  el.numberStyle = kCFNumberFormatterDecimalStyle;
			  el.hasThousandSeparators = hasThousandSeparators.boolValue;
			  if (hasThousandSeparators.boolValue)
              {
                  [tmpCS addCharactersInString:el.thousandSeparator];
                  [tmpCS addCharactersInString:el.decimalSeparator];
                  [tmpCS addCharactersInString:el.negativeSuffix];
                  [tmpCS addCharactersInString:el.negativePrefix];
              }
			  //LOG(makeString(@"posix: %@", [el stringFromNumber:@(1234.5678)]));

			  [tmpFormatters addObject:el];
		  }

		  invalidCharacterSet =  tmpCS.invertedSet;
		  numberInputFormatters = tmpFormatters.immutableObject;
	});

	// optim on
	NSUInteger      len = self.length;
	BOOL			valid = NO;
	if (!len)		return nil;
	else if (len < 18)
	{
		unichar         buffer[20];
		[self getCharacters:buffer range:NSMakeRange(0, len)];
		BOOL clean = TRUE;
		for (NSUInteger i = 0; i < len; i++)
		{
			if (buffer[i] < '0' || buffer[i] > '9')
				clean = NO;
			else
				valid = TRUE;
		}
		if (clean)
		{
			char *singlecharbuffer = (char *)&buffer;
			for (NSUInteger i = 0; i < len; i++)
				*singlecharbuffer++ = (char)buffer[i];
			*singlecharbuffer = 0;
			long res = atol((char *)buffer);
			NSNumber *resnum = @(res);
			return resnum;
		}
		if (!valid)
			return nil;
	}
	// optim off


	NSString *string = [self stringByTrimmingCharactersInSet:invalidCharacterSet];

	for (NSNumberFormatter *numberFormatter in numberInputFormatters)
	{
        NSNumber *number = [numberFormatter numberFromString:string]; // TODO: this is very slow

		if (number)
        {
            //cc_log_debug(@"converting string {%@} to number [%@] with formatter: %@", self, number, numberFormatter.description);
            return number;
        }
	}

	return nil;
}
@end


@implementation NSNumber(FormulaResultCategory)

@dynamic  dateValue, numberValue;


- (NSNumber *)numberValue
{
	return self;
}
- (NSDate *)dateValue
{
	double serialdate = self.doubleValue;
	NSTimeInterval theTimeInterval;
	static NSTimeInterval numberOfSecondsInOneDay = 86400;

	double integral;
	double fractional = modf(serialdate, &integral);

//	cc_log_debug(@"%@ %@ \r serialdate = %f, integral = %f, fractional = %f", [self class], NSStringFromSelector(_cmd), serialdate, integral, fractional);

	theTimeInterval = integral * numberOfSecondsInOneDay; //number of days
	if (fractional > 0)
		theTimeInterval += numberOfSecondsInOneDay * fractional; //portion of one day


	assert(excelBaseDate);


	
	NSDate *inputDate = [NSDate dateWithTimeInterval:theTimeInterval sinceDate:excelBaseDate];
	
//	cc_log_debug(@"%@ %@ \r serialdate %f, theTimeInterval = %f \r inputDate = %@", [self class], NSStringFromSelector(_cmd), serialdate, theTimeInterval, inputDate.description);

	return inputDate;
}
@end

@implementation NSDate(ExcelSerialDate)

@dynamic numberValue;

- (NSNumber *)numberValue
{
	static NSInteger numberOfSecondsInOneDay = 86400;

	assert(excelBaseDate);


	NSTimeInterval timeInterval = [self timeIntervalSinceDate:excelBaseDate];
	NSTimeInterval timeIntervalNormalized = timeInterval / numberOfSecondsInOneDay;


	//	cc_log_debug(@"%@ %@ \r serialdate %f, theTimeInterval = %f \r inputDate = %@", [self class], NSStringFromSelector(_cmd), serialdate, theTimeInterval, inputDate.description);

	return @(timeIntervalNormalized);
}
@end

