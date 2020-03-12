//
//  PredicateEditorViewController.h
//  CarDB
//
//  Created by CoreCode on 18.05.14.
//  Copyright © 2018 CoreCode Limited. All rights reserved.
//

typedef NS_ENUM(uint8_t, predicateEditorOption)
{
    IntegerAttributeType,
    FloatAttributeType,
    StringAttributeType,
    BooleanAttributeType
};




@interface PredicateEditorRowTemplate : NSDictionary

@property (nonatomic, readonly) NSString *leftExpression;
@property (nonatomic, readonly) NSString *leftExpressionLocalized;
@property (nonatomic, readonly) id rightExpression;
@property (nonatomic, readonly) id options;

@end




@interface PredicateEditorViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSArray <PredicateEditorRowTemplate*> *predicateArray;
@property (copy, nonatomic) ObjectInBlock finishBlock;

@end
