/*
 * SPRuleEditorView.j
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
@import <AppKit/CPView.j>
@import "SPRuleEditorRowView.j"
@global SPRuleEditorItemPBoardType

SPRuleEditorRowViewMinHeight=26;
SPRuleEditorRowViewIndent=30;

@implementation SPRuleEditorView : CPView
{
	SPRuleEditorModel 	_model @accessors(property=model)
	id 					_delegate @accessors(property=delegate);
	BOOL 				_editable @accessors(property=editable);
	CGFloat				_rowHeight @accessors(property=rowHeight);
	BOOL 				_dragging @accessors(readonly,property=dragging);
	SPRuleEditorRowView _currentDropTarget;
	BOOL 				_forcedRedraw;
}

+ (CPDictionary)themeAttributes
{
	return [SPRuleEditor themeAttributes];
}

#pragma mark Constructors

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(!self)
    	return nil;

    _model=nil;
    _delegate=nil;
    _editable=YES;
    _rowHeight=SPRuleEditorRowViewMinHeight;
    _dragging=NO;
    _forcedRedraw=NO;
    
 	[self setThemeClass:"rule-editor"];    
    [self setBackgroundColor:[CPColor colorWithHexString:"ededed"]];

    [self setPostsFrameChangedNotifications:YES];
    [self registerForDraggedTypes:[CPArray arrayWithObjects:SPRuleEditorItemPBoardType,nil]];
    return self;
}

- (void)removeFromSuperview
{
/*
	if([self superview])	
		[[CPNotificationCenter defaultCenter] removeObserver: self];
	[[CPNotificationCenter defaultCenter] removeObserver:self];
*/
}

#pragma mark Properties

-(void)setModel:(SPRuleEditorModel)model
{
	if(model==_model)
		return nil;
	
    var notificationCenter=[CPNotificationCenter defaultCenter];
    
    if(_model)
    {
		[notificationCenter removeObserver:self name:SPRuleEditorModelRowAdded object:_model];
		[notificationCenter removeObserver:self name:SPRuleEditorModelRowRemoved object:_model];
		[notificationCenter removeObserver:self name:SPRuleEditorModelRowModified object:_model];
		[notificationCenter removeObserver:self name:SPRuleEditorModelNestingModeWillChange object:_model];
		[notificationCenter removeObserver:self name:SPRuleEditorModelNestingModeDidChange object:_model];
		[notificationCenter removeObserver:self name:SPRuleEditorModelRemovedAllRows object:_model];
    }
    
    _model=model;
    
    if(_model)
    {
		[notificationCenter addObserver:self selector:@selector(rowAdded:) name:SPRuleEditorModelRowAdded object:_model];
		[notificationCenter addObserver:self selector:@selector(rowRemoved:) name:SPRuleEditorModelRowRemoved object:_model];
		[notificationCenter addObserver:self selector:@selector(rowModified:) name: SPRuleEditorModelRowModified object:_model];
		[notificationCenter addObserver:self selector:@selector(nestingModeWillChange:) name:SPRuleEditorModelNestingModeWillChange object:_model];
		[notificationCenter addObserver:self selector:@selector(nestingModeDidChange:) name:SPRuleEditorModelNestingModeDidChange object:_model];
		[notificationCenter addObserver:self selector:@selector(allRowsRemoved:) name:SPRuleEditorModelRemovedAllRows object:_model];
    }
}

-(void)setDelegate:(id)delegate
{
	if(delegate==_delegate)
		return;
		
	_delegate=delegate;

	var subviews=[self subviews];
	
	var subview;
	var view;
	var count=[subviews count];
	
	for(var i=0;i<count;i++)	
	{
		subview=subviews[i];
		if(![subview isKindOfClass:SPRuleEditorRowView]) continue;
		[subview setDelegate:delegate];
	}
}

-(void)setEditable:(BOOL)editable
{
	if(_editable==editable)
		return;

	_editable=editable;

	var subviews=[self subviews];

	var subview;
	var view;
	var count=[subviews count];

	for(var i=0;i<count;i++)	
	{
		subview=subviews[i];
		if(![subview isKindOfClass:SPRuleEditorRowView])
			continue;
		[subview setEditable:_editable];
	}
	
	[self setNeedsLayout];
}

-(void)setRowHeight:(CGFloat)rowHeight
{
	if(_rowHeight==rowHeight)
		return;

	_rowHeight=Math.max(rowHeight,SPRuleEditorRowViewMinHeight);

    var subviews=[self subviews];
    
	var subview;
	var view;
	var count=[subviews count];
	
	for(var i=0;i<count;i++)	
	{
		subview=subviews[i];
		if(![subview isKindOfClass:SPRuleEditorRowView])
			continue;
		[subview setRowHeight:_rowHeight];
	}
	[self setNeedsLayout];
}

#pragma mark Finding views

-(SPRuleEditorRowView)rowViewWithItem:(SPRuleEditorModelItem)item
{
	var subviews=[self subviews];
	
	var subview;
	var view;
	var count=[subviews count];
	
	for(var i=0;i<count;i++)	
	{
		subview=subviews[i];
		if(![subview isKindOfClass: SPRuleEditorRowView])
			continue;
		view=[subview rowViewWithItem:item];
		if(view)
			return view;
	}
	return nil;
}

- (CPView)rowViewAtPoint:(CPPoint)aPoint
{
	var subviews=[self subviews];
	
	var subview;
	var view;
	var count=[subviews count];
	
	for(var i=0;i<count;i++)	
	{
		subview=subviews[i];
		if(![subview isKindOfClass:SPRuleEditorRowView])
			continue;
		
		view=[subview viewAtPoint:aPoint];
		if(!view||![view isKindOfClass:SPRuleEditorRowView])
			continue;
		
		return view;
	}
	
	return nil;
}

#pragma mark Model notifications

-(void)rowAdded:(CPNotification)notification
{
	if(!notification)
		[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : null notification"];

	var userInfo=[notification userInfo];
	if(!userInfo)
		[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : notification userInfo is null"];
	
	var parentRow=[userInfo valueForKey:@"parentRow"];
	var index=[userInfo valueForKey:@"index"];
	var row=[userInfo valueForKey:@"row"];
	
	[self row:row addedAtIndex:index withParentRow:parentRow];	
}

-(void)row:(SPRuleEditorModelItem)row addedAtIndex:(CPInteger)index withParentRow:(SPRuleEditorModelItem)parentRow
{
	[self _row:row addedAtIndex:index withParentRow:parentRow];	
	
	var count=[row subrowsCount];
	for(var i=0;i<count;i++)
		[self row:[row childAtIndex:i] addedAtIndex:i withParentRow:row];	
}

-(void)_row:(SPRuleEditorModelItem)row addedAtIndex:(CPInteger)index withParentRow:(SPRuleEditorModelItem)parentRow
{
	if(index<0||!row)
		[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : invalid SPRuleEditorModelRowAdded notification userInfo"];
	
	var parentView;
	var subviews=[parentView subviews];
	var parentViewIsSelf;
	
	if(!parentRow)
	{
		parentView=self;
		subviews=[self subviews];
		parentViewIsSelf=YES;
	}
	else
	{
		parentView=[self rowViewWithItem:parentRow];
		subviews=[[parentView subrowsView] subviews];
		parentViewIsSelf=NO;
	}

	if(!parentView)
		[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : parent row view does not exist"];

	var count=[subviews count];
	if(index>count)
		[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : invalid SPRuleEditorModelRowAdded notification userInfo"];
	
	var rowView=[[SPRuleEditorRowView alloc] initWithFrame:[self initialFrameForItem:row]];
	[rowView setDelegate:_delegate];
    [rowView setAutoresizingMask:CPViewWidthSizable];
	[rowView setItem:row];
	[rowView setNestingMode:[_model nestingMode]];
	[rowView setDelegate:_delegate];
	[rowView setEditable:_editable];

	if(!count||index==count)
	{
		if(parentViewIsSelf)
			[self addSubview:rowView];
		else
			[parentView addRowView:rowView];
	}
	else
	{
		var siblingView=[subviews objectAtIndex:index];
		if(parentViewIsSelf)
			[self addSubview:rowView positioned:CPWindowBelow relativeTo:siblingView];
		else
			[parentView addRowView:rowView positioned:CPWindowBelow relativeTo:siblingView];
	}
	
	[[self window] makeFirstResponder:rowView];
	
	[self setNeedsLayout];
}

-(void)rowRemoved:(CPNotification)notification
{
	if(!notification)
		[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : null notification"];
	
	var userInfo=[notification userInfo];
	if(!userInfo)
		[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : notification userInfo is null"];
	
	var row=[userInfo valueForKey:@"row"];
	if(!row)
		[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : invalid SPRuleEditorModelRowAdded notification userInfo"];
	
	var parentRow=[userInfo valueForKey:@"parentRow"];

	var view=[self rowViewWithItem:row];
	if(!view)
		return;

	var parentView;
	if(!parentRow)
	{
		[view removeFromSuperview];
	}
	else
	{
		var parentView=[self rowViewWithItem:parentRow];
		if(!parentView)
			[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : invalid SPRuleEditorModelRowRemoved notification userInfo"];
		[parentView removeRowView:view];
	}

	[self setNeedsLayout];
}

-(void)allRowsRemoved:(CPNotification)notification
{
	var subviews=[self subviews];
	var count=[subviews count];
	for(var i=0;i<count;i++)
	{
		[subviews[i] removeFromSuperview];
	}
}

-(void)rowModified:(CPNotification)notification
{
	if(!notification)
		[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : null notification"];
	
	var userInfo=[notification userInfo];
	if(!userInfo)
		[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : notification userInfo is null"];
	
	var row=[userInfo valueForKey:@"row"];
	var view=[self rowViewWithItem: row];
	if(!view) return;
		
	[view setItem: row];
	[self setNeedsLayout];
}

-(void)nestingModeWillChange:(CPNotification)notification
{
}

-(void)nestingModeDidChange:(CPNotification)notification
{
	if(!notification)
		[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : null notification"];
	
	var userInfo=[notification userInfo];
	if(!userInfo)
		[CPException raise:CPInternalInconsistencyException reason:_cmd+@" : notification userInfo is null"];

	var nestingMode=[userInfo valueForKey:@"newNestingMode"];

	var subviews=[self subviews];
	
	var subview;
	var view;
	var count=[subviews count];
	
	for(var i=0;i<count;i++)	
	{
		subview=subviews[i];
		if(![subview isKindOfClass:SPRuleEditorRowView])
			continue;
		view=[subview setNestingMode:nestingMode];
		if(view)
			return view;
	}
	
	[self setNeedsLayout];
}

#pragma mark Borders drawing

-(void)drawRect:(CGRect)rect
{
	var subviews=[self subviews];
	var count=[subviews count];
	if(!count)
		return;
	
	var view;
    var context=[[CPGraphicsContext currentContext] graphicsPort];
    if(!context)
    	return;
	
	var frame=[self frame];
	for(var i=0;i<count;i++)
	{
		view=subviews[i];
		if(![view isKindOfClass:SPRuleEditorRowView])
			continue;
		[view drawBordersInContext: context verticalOffset:0 width:frame.size.width];
	}
}

#pragma mark Layout

-(void)forceRedrawForChromeBug
{
	var size=[self frameSize];
	self._DOMElement.style.height=(size.height+1)+"px";
	_forcedRedraw=YES;
	[self setNeedsLayout];
}

-(void)layoutSubviews
{
	if(_forcedRedraw)
	{
		var size=[self frameSize];
		self._DOMElement.style.height=(size.height-1)+"px";
		_forcedRedraw=NO;
		return;
	}
		
	var subviews=[self subviews];
	var count=[subviews count];
	var bounds=[self bounds];
	var view;
	
	var deltaY=0;
	var frame;
	for(var i=0;i<count;i++)
	{
		view=subviews[i];
		if(![view isKindOfClass:SPRuleEditorRowView])
			continue;
		
		[view _layoutSubviews];
			
		frame=[view frame];
		frame.origin.y=deltaY;
		[view setFrame:frame];
		
		deltaY+=frame.size.height;

		[view setFrame:frame];
	}
	
	var size=[self frameSize];
	size.height=deltaY;
	[self setFrameSize:size];
}

-(CGRect)initialFrameForItem:(SPRuleEditorModelItem)item
{
	var depth=[item depth];
	var indentation=!depth?0:SPRuleEditorRowViewIndent;
	return CGRectMake(indentation,0,[self frame].size.width-(indentation*depth),_rowHeight);
}

#pragma mark Drag & drop

- (CPDragOperation)draggingEntered:(CPDraggingInfo)sender

{
	if(_dragging)
		return CPDragOperationNone;
		
	var source=[sender draggingSource];

    if([source isKindOfClass:SPRuleEditorRowView]&&[source delegate]==_delegate)
    {
		_dragging=YES;
        return CPDragOperationMove;
    }

	_dragging=NO;

    return CPDragOperationNone;
}

- (void)draggingExited:(id)sender
{
	_dragging=NO;
	[self updateDropTarget:nil];
}

- (CPDragOperation)draggingUpdated:(CPDraggingInfo)sender
{
	if(!_dragging)
		return;
		
    var view=[self rowViewAtPoint:[sender draggingLocation]];

    var source=[sender draggingSource];
    if(![source isKindOfClass:SPRuleEditorRowView])
    {
	    [self updateDropTarget:nil];
        return CPDragOperationNone;
    }
    
    if(!view||view==source||[source hasSubrow:view])
    {
	    [self updateDropTarget:nil];
        return CPDragOperationNone;
    }
    
    var row=[source item];
    var anotherRow=[view item];
    
    if(_delegate
    	&&[_delegate respondsToSelector:@selector(canMoveRow:afterRow:)]
    	&&![_delegate canMoveRow:row afterRow:anotherRow])
    {
	    [self updateDropTarget:nil];
        return CPDragOperationNone;
    }

    [self updateDropTarget:view];
    return CPDragOperationMove;
}

- (BOOL)performDragOperation:(CPDraggingInfo)sender
{
    var view=[self rowViewAtPoint:[sender draggingLocation]];

    var source=[sender draggingSource];
    if(![source isKindOfClass:SPRuleEditorRowView])
    {
	    [self updateDropTarget:nil];
        return CPDragOperationNone;
    }
    
    if(!view||view==source||[source hasSubrow:view])
    {
	    [self updateDropTarget:nil];
        return CPDragOperationNone;
    }
    
    var row=[source item];
    var anotherRow=[view item];
    
    if(_delegate
    	&&[_delegate respondsToSelector:@selector(moveRow:afterRow:)] )
    {
		[_delegate moveRow:row afterRow:anotherRow];
	}
	
    _dragging=NO;
    [self updateDropTarget:nil];
    return YES;
}

-(void)updateDropTarget:(SPRuleEditorRowView)rowView
{
	if(_currentDropTarget==rowView)
		return;
		
	[_currentDropTarget setShowDragIndicator:NO];
	if(rowView)
	{
		_currentDropTarget=rowView;
		[_currentDropTarget setShowDragIndicator:YES];
	}
	
	[self layoutSubviews];
	[self setNeedsDisplay:YES];
}




@end


