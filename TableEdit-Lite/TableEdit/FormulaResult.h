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



@class LogicalValue;
@class Cell;
@class DocumentData;



//
//@protocol FormulaResult <NSObject>
//// can be either NSString, NSNumber, Reference or LogicalValue
//@property (nonatomic, readonly) NSString *stringValue;
//@property (nonatomic, readonly) NSNumber *numberValue;
////@property (nonatomic, readonly) double doubleValue;
////@property (nonatomic, readonly) NSInteger integerValue;
//@property (nonatomic, readonly) LogicalValue *logicalValue;
//@property (nonatomic, readonly) NSDate *dateValue;
//
//@end

//
//
//
//@interface Reference : NSObject <FormulaResult>
//
//@property (readonly, nonatomic) NSArray <Cell *> *cells;
//
//+ (Reference *)referenceWithCells:(NSArray <Cell *> *)cells;
//+ (Reference *)referenceWithCell:(NSString *)str;
//+ (Reference *)referenceWithNamedRange:(NSString *)str;
//+ (Reference *)referenceWithVRange:(NSString *)str;
//+ (Reference *)referenceWithHRange:(NSString *)str;
//+ (Reference *)referenceWithIntersectionFunctionCall:(Reference *)ref1 :(Reference *)ref2;
//+ (Reference *)referenceWithRangeFunctionCall:(Reference *)ref1 :(Reference *)ref2;
//+ (Reference *)referenceWithReferenceFunctionCall:(NSString *)function arguments:(NSArray <NSObject <FormulaResult>* > *)arguments;
//- (NSArray <Reference *> *)columns;
//- (NSArray <Reference *> *)rows;
//- (NSArray <NSNumber *> *)numberValuesSparse;
//- (NSArray <NSNumber *> *)numberValues;
//- (NSArray <NSString *> *)stringValues;
//- (NSArray <NSNumber *> *)numberOrDateNumberValuesSparse;
//- (NSArray <NSNumber *> *)numberOrDateNumberValues;
//- (NSArray <LogicalValue *> *)logicalValues;
//- (NSArray <LogicalValue *> *)logicalValuesSparse;
//- (NSArray <NSDate *> *)dateValues;
//- (NSArray <FormulaResult> *)values;
//- (NSObject <FormulaResult> *)valueForCell:(NSUInteger)cellNumber;
////- (double)doubleValue;
////- (NSInteger)integerValue;
//- (NSString *)stringValue;
//- (NSDate *)dateValue;
//- (NSNumber *)numberValue;
//
//- (LogicalValue *)logicalValue;
//- (NSObject <FormulaResult>*)value;
//
//@end

//
//@interface UnionReference : Reference
//
//+ (UnionReference *)referenceWithUnionFunctionCall:(NSArray <Reference *> *)refs;
//@property (readonly, nonatomic) NSArray <Reference *> *areas;
//
//@end
//
//
//@interface ArrayReference : Reference
//
//+ (ArrayReference *)referenceWithArray:(NSArray <NSObject <FormulaResult>*> *)refs;
//@property (readonly, nonatomic) NSArray <NSObject <FormulaResult>*> *refs;
//
//@end
//

//
//@interface LogicalValue : NSObject <FormulaResult>
//
//+ (LogicalValue *)logicalValueWithBOOL:(BOOL)boolean;
//@property (nonatomic, readonly) NSString *stringValue;
////@property (nonatomic, readonly) double doubleValue;
////@property (nonatomic, readonly) NSInteger integerValue;
//@property (nonatomic, readonly) LogicalValue *logicalValue;
//@property (nonatomic, readonly) NSDate *dateValue;
//@property (nonatomic, readonly) NSNumber *numberValue;
//
//@end




@interface NSString(FormulaResultCategory)
@property (nonatomic, readonly) NSDate *dateValue;
@property (nonatomic, readonly) NSNumber *numberValue;
@end


@interface NSNumber(FormulaResultCategory)
@property (nonatomic, readonly) NSDate *dateValue;
@property (nonatomic, readonly) NSNumber *numberValue;
@end


@interface NSDate(ExcelSerialDate)
@property (nonatomic, readonly) NSNumber *numberValue;
@end
