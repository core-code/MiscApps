/*
 * SPRuleEditorModel.j
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
 
@import <Foundation/CPObject.j>
@import "SPRuleEditorModelItem.j"
@class SPRuleEditor
@global SPRuleEditorRowViewMinHeight

SPRuleEditorNestingModeSingle   = 0;        // Only a single row is allowed.  Plus/minus buttons will not be shown
SPRuleEditorNestingModeList     = 1;        // Allows a single list, with no nesting and no compound rows
SPRuleEditorNestingModeCompound = 2;        // Unlimited nesting and compound rows; this is the default
SPRuleEditorNestingModeSimple   = 3;        // One compound row at the top with subrows beneath it, and no further nesting allowed

SPRuleEditorRowTypeSimple       = 0;
SPRuleEditorRowTypeCompound     = 1;

SPRuleEditorModelRowAdded 				= @"SPRuleEditorModelRowAdded";
SPRuleEditorModelRowRemoved 			= @"SPRuleEditorModelRowRemoved";
SPRuleEditorModelRowModified 			= @"SPRuleEditorModelRowModified";
SPRuleEditorModelNestingModeWillChange 	= @"SPRuleEditorModelNestingModeWillChange";
SPRuleEditorModelNestingModeDidChange 	= @"SPRuleEditorModelNestingModeDidChange";
SPRuleEditorModelRemovedAllRows			= @"SPRuleEditorModelRemovedAllRows";

@implementation SPRuleEditorModel : CPObject
{
	CPArray _rows @accessors(readonly,property=rows);
	BOOL _rootLess @accessors(readonly,property=rootLess);
	CPInteger _nestingMode @accessors(property=nestingMode);
	BOOL _canRemoveAllRows @accessors(property=canRemoveAllRows);
}

#pragma mark Constructors

-(id)init
{
	self=[super init];
	if(!self)
		return nil;

	_nestingMode=SPRuleEditorNestingModeCompound;
	_rows=[[CPMutableArray alloc] init];
	_rootLess=NO;
	_canRemoveAllRows=NO;

	return self;	
}

-(id)initWithNestingMode:(int)nestingMode
{
	self=[super init];
	if(!self)
		return nil;
		
	_nestingMode=nestingMode;
	_rows=[[CPMutableArray alloc] init];
	_rootLess=_nestingMode==SPRuleEditorNestingModeSingle||_nestingMode==SPRuleEditorNestingModeList;
	
	_canRemoveAllRows=NO;

	return self;	
}

#pragma mark Properties

-(int)defaultRowType
{
	if(_rootLess)
		return SPRuleEditorRowTypeSimple;
	return [_rows count]?SPRuleEditorRowTypeSimple:SPRuleEditorRowTypeCompound;
}

-(void)setNestingMode:(CPInteger)nestingMode
{
	if(nestingMode==_nestingMode)
		return;
	
	var notificationCenter=[CPNotificationCenter defaultCenter];
		
	var userInfo=[CPDictionary dictionaryWithObjects:[nestingMode,_nestingMode] forKeys:["newNestingMode","oldNestingMode"]];
    [notificationCenter postNotificationName:SPRuleEditorModelNestingModeWillChange object:self userInfo:userInfo];
    
    var oldNestingMode=_nestingMode;
    
    _nestingMode=nestingMode;

	_rootLess=_nestingMode==SPRuleEditorNestingModeSingle||_nestingMode==SPRuleEditorNestingModeList;

	[self setCanRemoveAllRows:_canRemoveAllRows];
	[self removeAllRows];

	userInfo=[CPDictionary dictionaryWithObjects:[_nestingMode,oldNestingMode] forKeys:["newNestingMode","oldNestingMode"]];
    [notificationCenter postNotificationName:SPRuleEditorModelNestingModeDidChange object:self userInfo:userInfo];
}

-(void)setCanRemoveAllRows:(BOOL)canRemoveAllRows
{
	_canRemoveAllRows=canRemoveAllRows;
}

-(int)rowsCount
{
	return [_rows count];
}

-(int)flatRowsCount
{
	var total=0;
	var count=[_rows count];
	for(var i=0;i<count;i++)
		total+=[_rows[i] flatSubrowsCount]+1;
	return total;
}

#pragma mark Finding rows

-(int)lastRowIndex
{
	var count=[_rows count];
	if(!count)
		return CPNotFound;
		
	var row=[self lastRow];
	return row?[self indexOfRow:row]:CPNotFound;
}

-(void)lastRow
{
	var count=[_rows count];
	if(!count)
		return nil;
		
	var row=_rows[count-1];
	if(!row)
		return nil;
	return [row lastChild];
}

-(SPRuleEditorModelItem)rowAtIndex:(int)rowIndex
{
	if(rowIndex<0)
		return nil;
		
	var count=[_rows count];
	if(!count)
		return nil;
	
	var row,found,delta=0;
	for(var i=0;i<count;i++)
	{
		row=_rows[i];
		found=[row childAtFlatIndex:rowIndex-delta];
		if(found)
			return found;
		delta+=[row flatSubrowsCount]+1;
	}
	return nil;	
}

-(int)indexOfRow:(SPRuleEditorModelItem)aRow
{
	if(!aRow)
		return CPNotFound;
		
	var count=[_rows count];
	if(!count)
		return CPNotFound;

	var row,found,delta=0;
	for(var i=0;i<count;i++)
	{
		row=_rows[i];
		found=[row flatIndexOfChild:aRow];
		if(found!=CPNotFound)
			return found+delta;
		delta+=[row flatSubrowsCount]+1;
	}
	return CPNotFound;	
}

-(SPRuleEditorModel)rowWithDisplayValue:(id)value
{
	var count=[_rows count];
	if(!count)
		return nil;

	var row;
	for(var i=0;i<count;i++)
	{
		row=_rows[i];
		row=[row subrowWithDisplayValue:value];
		if(row)
			return row;
	}

	return nil;
}

-(CPIndexSet)immediateSubrowsIndexesOfRowAtIndex:(int)rowIndex
{
	var count=[_rows count];
	if(!count)
		return nil;

	var row=rowIndex<0?nil:[self rowAtIndex:rowIndex];
	if(row&&[row rowType]!=SPRuleEditorRowTypeCompound)
		return nil;
	
	var indexSet=[[CPMutableIndexSet alloc] init];
	var subrows=row?[row subrows]:_rows;
	var count=[subrows count];
	var subrow;
	for(var i=0;i<count;i++)
	{
		subrow=subrows[i]
		var indexVariable=[self indexOfRow:subrow];
		if(indexVariable!=CPNotFound)
			[indexSet addIndex:indexVariable];
	}
	return indexSet;
}

#pragma mark Adding rows

-(BOOL)allowNewRowInsertOfType:(int)rowType withParent:(SPRuleEditorModelItem)aParentRow
{
	var count=[_rows count];
	var firstRow=count?_rows[0]:nil;
	
	switch(_nestingMode)
	{
		case SPRuleEditorNestingModeSingle :
			return (count==0)&&(rowType==SPRuleEditorRowTypeSimple)&&(aParentRow==nil);
		case SPRuleEditorNestingModeList :
			return (rowType==SPRuleEditorRowTypeSimple)&&(aParentRow==nil);
		case SPRuleEditorNestingModeSimple :
			return ((!firstRow&&rowType==SPRuleEditorRowTypeCompound)&&(aParentRow==nil))
					||(firstRow&&(rowType==SPRuleEditorRowTypeSimple)&&(aParentRow==firstRow));
	}

	return (!firstRow&&rowType==SPRuleEditorRowTypeCompound&&aParentRow==nil)
			||(firstRow&&(aParentRow==firstRow||aParentRow!=nil));
}

-(SPRuleEditorModelItem)addNewRowOfType:(SPRuleEditorRowType)rowType criteria:(CPArray)criteria
{
	return [self addNewRowOfType:rowType criteria:criteria data:nil];
}

-(SPRuleEditorModelItem)addNewRowOfType:(SPRuleEditorRowType)rowType criteria:(CPArray)criteria data:(id)data
{
	var newRow=[[SPRuleEditorModelItem alloc] initWithType:rowType criteria:criteria data:data];
	return [self addRow:newRow];
}

-(SPRuleEditorModelItem)addRow:(SPRuleEditorModelItem)aRow
{
	if(!aRow)
		return nil;
		
	var rowType=[aRow rowType];
	if(![self allowNewRowInsertOfType:rowType withParent:nil])
		return nil;
		
	[aRow setCanRemoveAllRows:YES];
	[aRow _setDepth:0];
	[_rows addObject:aRow];
	
	var userInfo=[CPDictionary dictionaryWithObjects:[[_rows count]-1,aRow] forKeys:["index","row"]];
    [[CPNotificationCenter defaultCenter] postNotificationName:SPRuleEditorModelRowAdded object:self userInfo:userInfo];
	
	return aRow;
}

-(SPRuleEditorModelItem)insertNewRowAtIndex:(int)insertIndex ofType:(SPRuleEditorRowType)rowType withParentRowIndex:(int)parentRowIndex criteria:(CPArray)criteria
{
	return [self insertNewRowAtIndex:insertIndex ofType:rowType withParentRowIndex:parentRowIndex criteria:criteria data:nil];
}

-(SPRuleEditorModelItem)insertNewRowAtIndex:(int)insertIndex ofType:(SPRuleEditorRowType)rowType withParentRowIndex:(int)parentRowIndex criteria:(CPArray)criteria data:(id)data
{
	var newRow=[[SPRuleEditorModelItem alloc] initWithType:rowType criteria:criteria data:data];
	return [self insertRow:newRow atIndex:insertIndex withParentRowIndex:parentRowIndex];
}

-(SPRuleEditorModelItem)insertRow:(SPRuleEditorModelItem)aRow atIndex:(int)insertIndex withParentRowIndex:(int)parentRowIndex
{
	if(!aRow)
		return nil;

	var rowType=[aRow rowType];
	
	if(insertIndex<=parentRowIndex)
		return nil;
	
	var parentRow=parentRowIndex<0?nil:[self rowAtIndex:parentRowIndex];

	if(![self allowNewRowInsertOfType:rowType withParent:parentRow])
		return nil;
	var childIndex;
	
	var currentRow=[self rowAtIndex:insertIndex];
	if(currentRow)
	{
		if([currentRow parent]!=parentRow)
		{
			var flatSubrowsCount=parentRow?[parentRow flatSubrowsCount]:[self flatRowsCount];
			if([currentRow parent]==[parentRow parent]&&(insertIndex==parentRowIndex+flatSubrowsCount+1))
				childIndex=parentRow?[parentRow subrowsCount]:[self rowsCount];
			else
			{
				if((!parentRow||[parentRow rowType]==SPRuleEditorRowTypeCompound)&&(insertIndex==parentRowIndex+flatSubrowsCount+1))
					childIndex=parentRow?[parentRow subrowsCount]:[self rowsCount];
				else
					return nil;
			}
		}
		else
			childIndex=parentRow?[parentRow indexOfChild:currentRow]:[_rows indexOfObject:currentRow];
	}
	else
	{
		var subrowsCount=parentRow?[parentRow subrowsCount]:[self rowsCount];
		var flatSubrowsCount=parentRow?[parentRow flatSubrowsCount]:[self flatRowsCount];

		if(insertIndex>parentRowIndex+flatSubrowsCount+1)
			return [self addRow:aRow];
		
		childIndex=subrowsCount;			
	}
	
	if(parentRow)
		[parentRow insertChild:aRow atIndex:childIndex context:self];
	else
	{
		[aRow setCanRemoveAllRows:YES];
		[aRow _setDepth:0];
		[_rows insertObject:aRow atIndex:childIndex];
		var userInfo=[CPDictionary dictionaryWithObjects:[childIndex,aRow] forKeys:["index","row"]];
    	[[CPNotificationCenter defaultCenter] postNotificationName:SPRuleEditorModelRowAdded object:self userInfo:userInfo];
	}

	return aRow;
}

#pragma mark Removing rows

-(void)removeAllRows
{
	_rows=[[CPMutableArray alloc] init];
    [[CPNotificationCenter defaultCenter] postNotificationName:SPRuleEditorModelRemovedAllRows object:self userInfo:nil];
}

-(BOOL)isRowRemoveable:(SPRuleEditorModelItem)row includeSubrows:(BOOL)includeSubrows
{
	if(_canRemoveAllRows||[row parent])
		return YES;
		
	var count=[_rows count];
	
	if(!_rootLess&&count<=1)
		return NO;	
	
	if(includeSubrows&&count<=1)
		return NO;
		
	var subrows=[row subrows];
	var subrowsCount=subrows?[subrows count]:0;

	if(!includeSubrows&&count<=1&&subrowsCount==0)
		return NO;

	return YES;
}

- (SPRuleEditorModelItem)removeRowAtIndex:(int)rowIndex includeSubrows:(BOOL)includeSubrows
{
	var count=[_rows count];
	if(!count)
		return nil;
	
	var row=[self rowAtIndex:rowIndex];
	if(!row)
		return nil;

	if(!row||![self isRowRemoveable:row includeSubrows:includeSubrows])
		return nil;
	
	var parent=[row parent];
	if(!parent)
	{
		return [self _removeRowAtIndex:rowIndex keepSubrows:!includeSubrows];
	}
	
	var idx=[parent indexOfChild:row];
	if(idx==CPNotFound)
		return nil;
	
	[parent removeChildAtIndex:idx keepSubrows:!includeSubrows context:self];
	return row;
}

-(void)removeRowsAtIndexes:(CPIndexSet)rowIndexes includeSubrows:(BOOL)includeSubrows
{
	var count=[_rows count];
	if(!count)
		return;

	if(!rowIndexes||![rowIndexes count])
		return;
	
	var row;
	var index=[rowIndexes firstIndex];
	var cache=[CPMutableArray arrayWithCapacity:[rowIndexes count]];
	while(index!=CPNotFound)
	{
		row=[self rowAtIndex:index];
		if(!row)
			continue;
		[cache addObject:row];
		index=[rowIndexes indexGreaterThanIndex:index];
	}
	
	var parent;
	var idx;
	var count=[cache count];
	for(var i=0;i<count;i++)
	{
		row=[cache objectAtIndex:i];
		parent=[row parent];
		if(!parent)
		{
			[self _removeRowAtIndex:[self indexOfRow:row] keepSubrows:!includeSubrows];
			continue;
		}
		idx=[parent indexOfChild:row];
		if(idx==CPNotFound)
			continue;
		[parent removeChildAtIndex:idx keepSubrows:!includeSubrows context:self];
	}
	
}

#pragma mark Criteria management

-(void)setCriteria:(CPArray)criteria forRow:(SPRuleEditorModelItem)aRow
{
	[aRow setCriteria:criteria context:self];
}

#pragma mark Private methods

-(SPRuleEditorModelItem)_removeRowAtIndex:(int)index keepSubrows:(BOOL)keepSubrows
{
	var count=[_rows count];
	if(!count)
		return nil;
	
	var row=[self rowAtIndex:index];
	if(!row)
		return nil;
	
	var subrows=[row subrows];
	var subrowsCount=subrows?[subrows count]:0;
	
	if(![self isRowRemoveable:row includeSubrows:!keepSubrows])
		return nil;
	
	[_rows removeObjectAtIndex:index];
	
	[row setParent:nil];
	[row _setDepth:-1];

	var notificationCenter=[CPNotificationCenter defaultCenter];

	var userInfo=[CPDictionary dictionaryWithObjects:[index,row] forKeys:["index","row"]];
    [notificationCenter postNotificationName:SPRuleEditorModelRowRemoved object:self userInfo:userInfo];
	
	if(!keepSubrows||!subrows||!_rootLess)
		return row;	
	
	var subrow;	
	for(var i=subrowsCount-1;i>=0;i--)
	{
		subrow=subrows[i];
		[_rows insertObject:subrow atIndex:index];
		[subrow setParent:nil];
		
		var userInfo=[CPDictionary dictionaryWithObjects:[index,subrow] forKeys:["index","row"]];
    	[[CPNotificationCenter defaultCenter] postNotificationName:SPRuleEditorModelRowAdded object:self userInfo:userInfo];
	}
	
	return row;
}
@end


var RowsKey=@"rows";
var RootlessKey=@"rootLess";
var NestingModelKey=@"nestingMode";
var CanRemoveAllRowsKey=@"canRemoveAllRows";

@implementation SPRuleEditorModel(CPCoding)

- (id)initWithCoder:(id)coder
{
    self=[super init];
    if(!self)
    	return nil;

    _rows=[coder decodeObjectForKey:RowsKey];
    _rootLess=[coder decodeBoolForKey:RootlessKey];
    _canRemoveAllRows=[coder decodeBoolForKey:CanRemoveAllRowsKey];
    _nestingMode=[coder decodeIntForKey:NestingModelKey];

    return self;
}

- (void)encodeWithCoder:(id)coder
{
    [coder encodeObject:_rows forKey:RowsKey];
    [coder encodeBool:_rootLess forKey:RootlessKey];
    [coder encodeBool:_canRemoveAllRows forKey:CanRemoveAllRowsKey];
    [coder encodeInt:_nestingMode forKey:NestingModelKey];
}

@end
