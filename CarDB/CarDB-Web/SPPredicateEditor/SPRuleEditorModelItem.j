/*
 * SPRuleEditorModelItem.j
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
@import <Foundation/CPArray.j>
@import <Foundation/CPDictionary.j>
@import <Foundation/CPNotificationCenter.j>


@global SPRuleEditorRowTypeSimple
@global SPRuleEditorRowTypeCompound
@global SPRuleEditorModelRowAdded
@global SPRuleEditorModelRowRemoved
@global SPRuleEditorModelRowModified 

 

@implementation SPRuleEditorModelItem : CPObject
{
    CPArray     			_subrows @accessors(readonly,property=subrows);
    CPArray     			_criteria @accessors(readonly,property=criteria);
    CPInteger   			_rowType @accessors(readonly,property=rowType);
    CPInteger   			_depth @accessors(readonly,property=depth);
    BOOL 					_canRemoveAllRows @accessors(property=canRemoveAllRows);
    id						_data @accessors(property=data);
    SPRuleEditorModelItem  	_parent @accessors(property=parent);
}

#pragma mark Constructors

-(id)init
{
	self=[super init];
	if(!self)
		return self;

	_subrows=nil;
	_criteria=nil;
	_canRemoveAllRows=YES;
    _rowType=SPRuleEditorRowTypeSimple;
	_depth=0;
	_parent=nil;
	_data=nil;
		
	return self;
}

-(id)initWithType:(int)type criteria:(CPArray)criteria data:(id)data
{
	self=[super init];
	if(!self)
		return self;

    _rowType=type;
	_subrows=nil;
	_criteria=[[CPArray alloc] initWithArray:criteria copyItems: YES];
	_depth=0;
	_parent=nil;
	_canRemoveAllRows=YES;
	_data=data;
		
	return self;
}

#pragma mark Properties

-(int)subrowsCount
{
	return _subrows?[_subrows count]:0;
}

-(int)flatSubrowsCount
{
	var row;
	var total=0;
	var count=[self subrowsCount];
	
	for(var i=0;i<count;i++)
	{
		row=[_subrows objectAtIndex:i];
		if([row rowType]==SPRuleEditorRowTypeCompound)
			total+=[row flatSubrowsCount];
		total++;
	}
	return total;
}

-(void)setParent:(SPRuleEditorModelItem)aParent
{
	if(_parent==aParent)
		return;
	_parent=aParent;
	var newDepth=aParent?[aParent depth]+1:0;
	[self _setDepth:newDepth];
}

-(void)_setDepth:(int)newDepth
{
	if(_depth==newDepth)
		return;
		
	_depth=newDepth;
	if(_subrows&&[_subrows count])
		[_subrows makeObjectsPerformSelector:@selector(_setDepth:) withObject:_depth+1];
}

-(BOOL)hasAncestor:(SPRuleEditorModelItem)ancestor
{
	if(!ancestor||!_parent)
		return nil;
	
	var current=self;
	var p;
	while((p=[current parent])!=nil)
	{
		if(p==ancestor)
			return YES;
		current=p;
	}
	return NO;
}

#pragma mark Retrieving subrows

-(SPRuleEditorModelItem)lastChild
{
	if(!_subrows)
		return nil;
		
	var count=[_subrows count];
	if(!count)
		return nil;
		
	return [_subrows objectAtIndex:count-1];
}

-(int)indexOfChild:(SPRuleEditorModelItem)row
{
	if(!row||!_subrows||![_subrows count]||[row parent]!=self)
		return CPNotFound;
	return [_subrows indexOfObject:row];	
}

-(int)flatIndexOfChild:(SPRuleEditorModelItem)aRow 
{
	if(aRow==self)
		return 0;
	
	if(!_subrows||!aRow)
		return CPNotFound;
	
	var row;
	var rowsCount;
	var count=[_subrows count];
	var relativeIndex;
	for(var i=0,idx=1;i<count;i++)
	{
		row=[_subrows objectAtIndex:i];
		if(aRow==row)
			return idx;

		if([row rowType]==SPRuleEditorRowTypeSimple)
		{
			idx++;
			continue;
		}
		
		relativeIndex=[row flatIndexOfChild:aRow];
		if(relativeIndex!=CPNotFound)
			return idx+relativeIndex;

		rowsCount=[row flatSubrowsCount];
		idx+=rowsCount+1;
	}
	return CPNotFound;
}

-(SPRuleEditorModelItem)childAtIndex:(int)index
{
	if(!_subrows||index<0||index>=[_subrows count])
		return nil;
	return [_subrows objectAtIndex:index];
}

-(SPRuleEditorModelItem)childAtFlatIndex:(int)index
{
	if(index==0)
		return self;

	if(!_subrows||index<0)
		return nil;
	
	var row;
	var rowsCount;
	var count=[_subrows count];
	for(var i=0,idx=1;i<count;i++)
	{
		row=[_subrows objectAtIndex:i];
		if(idx==index)
			return row;
		
		if([row rowType]==SPRuleEditorRowTypeSimple)
		{
			idx++;
			continue;
		}

		rowsCount=[row flatSubrowsCount];
		if(idx+rowsCount<index)
		{
			idx+=rowsCount+1;
			continue;
		}
		
		return [row childAtFlatIndex:index-idx];
	}
	return nil;
}

-(SPRuleEditorModel)subrowWithDisplayValue:(id)value
{
	if(!_criteria||![_criteria count])
		return nil;
	
	var criterion=[_criteria objectAtIndex:0];
	if([[criterion displayValue] isEqual:value])
		return self;
		
	var row,found;
	var count=[self subrowsCount];
	for(var i=0,idx=0;i<count;i++)
	{
		row=[_subrows objectAtIndex:i];
		found=[row subrowWithDisplayValue:value];
		if(found)
			return found;
	}
	
	return nil;
}

#pragma mark Adding subrows

-(int)addChild:(SPRuleEditorModelItem)row context:(id)context
{
	if(!row||_rowType!=SPRuleEditorRowTypeCompound)
		return CPNotFound;
		
	if(!_subrows)
		_subrows=[[CPMutableArray alloc] init];
	
	[_subrows addObject:row];

	[row setParent:self];
	
	var index=[_subrows count]-1;

	if(context)
	{
		var userInfo=[CPDictionary dictionaryWithObjects:[self,index,row] forKeys:["parentRow","index","row"]];
    	[[CPNotificationCenter defaultCenter] postNotificationName:SPRuleEditorModelRowAdded object:context userInfo:userInfo];
	}

	return index;
}

-(int)insertChild:(SPRuleEditorModelItem)row atIndex:(int)index context:(id)context
{
	if(!row||_rowType!=SPRuleEditorRowTypeCompound)
		return CPNotFound;

	if(!_subrows)
		_subrows=[[CPMutableArray alloc] init];

	if(index<0)
		index=0;
	
	if(index>[_subrows count])
		return [self addChild:row context:context];
	
	[_subrows insertObject:row atIndex:index];

	[row setParent:self];

	if(context)
	{
		var userInfo=[CPDictionary dictionaryWithObjects:[self,index,row] forKeys:["parentRow","index","row"]];
    	[[CPNotificationCenter defaultCenter] postNotificationName:SPRuleEditorModelRowAdded object:context userInfo:userInfo];
    }

	return index;
}

#pragma mark Removing subrows

-(SPRuleEditorModelItem)removeChildAtIndex:(int)index keepSubrows:(BOOL)keepSubrows context:(id)context
{
	if(!_subrows||_rowType!=SPRuleEditorRowTypeCompound)
		return nil;
	
	if(!_canRemoveAllRows&&[_subrows count]<=1)
		return nil;
		
	var row=[self childAtIndex:index];
	if(!row)
		return nil;
	
	if(!_canRemoveAllRows
		&&((!keepSubrows&&[_subrows count]<=1)||(keepSubrows&&[_subrows count]==0)))
		return nil;
	
	[_subrows removeObjectAtIndex:index];
	
	[row setParent:nil];
	[row _setDepth:-1];

	if(context)
	{
		var userInfo=[CPDictionary dictionaryWithObjects:[self,index,row] forKeys:["parentRow","index","row"]];
	    [[CPNotificationCenter defaultCenter] postNotificationName:SPRuleEditorModelRowRemoved object:context userInfo:userInfo];
	}
	
	if(!keepSubrows)
		return row;	
	
	var subrows=[row subrows];
	if(!subrows)
		return;

	var subrow;	
	var count=[subrows count];
	for(var i=count-1;i>=0;i--)
	{
		subrow=subrows[i];
		[self insertChild:subrow atIndex:index context:context];
	}
	
	return row;
}

#pragma mark Criteria management

-(void)setCriteria:(CPArray)criteria context:(id)context
{
	_criteria=criteria;
	
	var index=_parent?[_parent indexOfChild:self]:CPNotFound;
	
	if(context)
	{
		var userInfo=_parent?[CPDictionary dictionaryWithObjects:[_parent,index,self] forKeys:["parentRow","index","row"]]:[CPDictionary dictionaryWithObjects:[index,self] forKeys:["index","row"]];
		[[CPNotificationCenter defaultCenter] postNotificationName:SPRuleEditorModelRowModified object:context userInfo:userInfo];
    }
}

-(CPArray)criteriaItems
{
	if(!_criteria)
		return nil;

	var criterion;
	var count=[_criteria count];
	if(!count)
		return [CPArray array];
		
	var res=[CPMutableArray arrayWithCapacity:count];
	for(var i=0;i<count;i++)
	{
		criterion=_criteria[i];
		[res addObject:[criterion items]];
	}
	return res;
}

-(CPArray)criteriaDisplayValues
{
	if(!_criteria)
		return nil;

	var criterion;
	var count=[_criteria count];
	if(!count)
		return [CPArray array];
		
	var res=[CPMutableArray arrayWithCapacity:count];
	for(var i=0;i<count;i++)
	{
		criterion=_criteria[i];
		[res addObject:[criterion displayValue]];
	}
	return res;
}

#pragma mark Other methods

-(void)flattenToArray:(CPMutableArray)array
{
	if(!array)
		return;
	
	[array addObject:self];
		
	var row;
	var count=[self subrowsCount];
	for(var i=0,idx=0;i<count;i++)
	{
		row=[_subrows objectAtIndex:i];
		if([row rowType]==SPRuleEditorRowTypeSimple)
		{
			[array addObject:row]
			continue;
		}
		[row flattenToArray:array];		
	}
}

#pragma mark Copying

- (id)copy
{
    var copy = [[SPRuleEditorModelItem alloc] init];

    [copy setRowType:_rowType];
    [copy setDepth:_depth];
    [copy setCanRemoveAllRows:_canRemoveAllRows];
    [copy setCriteria:[[CPArray alloc] initWithArray:_criteria copyItems:YES]];
    [copy setSubrows:[[CPArray alloc] initWithArray:_subrows copyItems:YES]];
    [[copy subrows] makeObjectsPerformSelector:@selector(setParent:) withObject:copy];
    [copy setData:[_data copy]];

    return copy;
}

@end

var CriteriaKey         = @"criteria";
var SubrowsKey          = @"subrows";
var RowTypeKey          = @"rowType";
var DepthKey          	= @"depth";
var ParentKey          	= @"parent";
var CanRemoveAllRowsKey = @"canRemoveAllRows";

@implementation SPRuleEditorModelItem(CPCoding)

- (id)initWithCoder:(id)coder
{
    self=[super init];
    if(!self)
    	return nil;

    _subrows=[coder decodeObjectForKey:SubrowsKey];
    _criteria=[coder decodeObjectForKey:CriteriaKey];
    _canRemoveAllRows=[coder decodeBool:CanRemoveAllRowsKey];
    _rowType=[coder decodeIntForKey:RowTypeKey];
    _depth=[coder decodeIntForKey:DepthKey];
    _parent=[coder decodeObjectForKey:ParentKey];

    return self;
}

- (void)encodeWithCoder:(id)coder
{
    [coder encodeObject:_subrows forKey:SubrowsKey];
    [coder encodeObject:_criteria forKey:CriteriaKey];
    [coder encodeBool:_canRemoveAllRows forKey:CanRemoveAllRowsKey];
    [coder encodeInt:_rowType forKey:RowTypeKey];
    [coder encodeInt:_depth forKey:DepthKey];
    [coder encodeObject:_parent forKey:ParentKey];
}

@end
