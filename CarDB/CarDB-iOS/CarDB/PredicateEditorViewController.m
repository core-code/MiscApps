//
//  PredicateEditorViewController.m
//  CarDB
//
//  Created by CoreCode on 18.05.14.
//  Copyright © 2018 CoreCode Limited. All rights reserved.
//

#import "PredicateEditorViewController.h"
#import "JMChoiceController.h"




@interface PredicateEditorViewController ()

@property (strong, nonatomic) NSMutableDictionary *cells;

@end



@implementation PredicateEditorViewController


- (void)viewDidLoad
{
	self.cells = @{}.mutableObject;

    [super viewDidLoad];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.title = @"Filter";


	UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save"
															 style:UIBarButtonItemStyleBordered
															target:self
															action:@selector(save:)];

	UIBarButtonItem *discard = [[UIBarButtonItem alloc] initWithTitle:@"Discard"
															   style:UIBarButtonItemStyleBordered
															  target:self
															   action:@selector(discard:)];


	 self.navigationItem.rightBarButtonItem = discard;
	 self.navigationItem.leftBarButtonItem = save;


	self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);

}

- (void)save:(id)sender
{
	NSMutableArray *predicates = makeMutableArray();


	for (PredicateEditorRowTemplate *p in self.predicateArray)
	{
		int index = (int) [self.predicateArray indexOfObject:p];

		if ([p.rightExpression isKindOfClass:[NSArray class]])
		{
			UITableViewCell *cell = self.cells[makeString(@"%i", index)];

			NSString *filter = cell.detailTextLabel.text;

			if (filter && filter.length && ![filter isEqualToString:@"<any>"])
				[predicates addObject:makePredicate(@"%K == %@",  p.leftExpression, filter)];

		}
		else if ([p.rightExpression intValue] == StringAttributeType)
		{
			UITableViewCell *cell = self.cells[makeString(@"%i", index)];
			UITextField *tf =  (UITextField *)[cell.contentView viewWithTag:1];
			NSString *filter = tf.text;

			if (filter && filter.length)
				[predicates addObject:makePredicate(@"%K CONTAINS[cd] %@",  p.leftExpression, filter)];
		}
		else if ([p.rightExpression intValue] == IntegerAttributeType)
		{
			UITableViewCell *cell = self.cells[makeString(@"%i", index)];
			UITextField *tf =  (UITextField *)[cell.contentView viewWithTag:11];
			NSString *filter = tf.text;

			UISegmentedControl *sc =  (UISegmentedControl *)[cell.contentView viewWithTag:2];

			if (filter && filter.length)
			{
				if (sc.selectedSegmentIndex)
					[predicates addObject:[NSPredicate predicateWithFormat:@"%K >= %i",  p.leftExpression, filter.intValue]];
				else
					[predicates addObject:[NSPredicate predicateWithFormat:@"%K <= %i",  p.leftExpression, filter.intValue]];
			}
		}
		else if ([p.rightExpression intValue] == FloatAttributeType)
		{
			UITableViewCell *cell = self.cells[makeString(@"%i", index)];
			UITextField *tf =  (UITextField *)[cell.contentView viewWithTag:11];
			NSString *filter = tf.text;

			UISegmentedControl *sc =  (UISegmentedControl *)[cell.contentView viewWithTag:2];

			if (filter && filter.length)
			{
				if (sc.selectedSegmentIndex)
					[predicates addObject:makePredicate(@"%K >= %f",  p.leftExpression, filter.floatValue)];
				else
					[predicates addObject:makePredicate(@"%K <= %f",  p.leftExpression, filter.floatValue)];
			}
		}
	}
	NSPredicate *comp = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];


	self.finishBlock(comp);
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)discard:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDataSource protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.predicateArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = self.cells[makeString(@"%li", (long)indexPath.row)];


    if (!cell)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];

		PredicateEditorRowTemplate *pred = self.predicateArray[indexPath.row];

		cell.textLabel.text = pred.leftExpressionLocalized;

		[cell.contentView removeAllSubviews];
		cell.detailTextLabel.text = @"";
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		if ([pred.rightExpression isKindOfClass:[NSArray class]])
		{
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.detailTextLabel.text = @"<any>";
		}
		else if ([pred.rightExpression intValue] == StringAttributeType)
		{

			UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-170, 8, 165, 30)];

			tf.backgroundColor = [UIColor whiteColor];
			tf.autocorrectionType = UITextAutocorrectionTypeNo;
			tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
			tf.textAlignment = NSTextAlignmentRight;
			tf.clearButtonMode = UITextFieldViewModeNever;
			tf.returnKeyType = UIReturnKeyDone;
			tf.placeholder = [pred.leftExpressionLocalized stringByAppendingString:@"     "];
			tf.tag = 1;
			tf.delegate = self;

			[cell.contentView addSubview:tf];

		}
		else if ([pred.rightExpression intValue] == FloatAttributeType)
		{

			UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 8, 65, 30)];

			tf.backgroundColor = [UIColor whiteColor];
			tf.autocorrectionType = UITextAutocorrectionTypeNo;
			tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
			tf.textAlignment = NSTextAlignmentRight;
			tf.clearButtonMode = UITextFieldViewModeNever;
			tf.placeholder = @"<value>";
			tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			tf.returnKeyType = UIReturnKeyDone;
			tf.tag = 11;
			tf.delegate = self;

			[cell.contentView addSubview:tf];


			UISegmentedControl *sc = [[UISegmentedControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width-170, 8, 55, 30)];
			[sc insertSegmentWithTitle:@">" atIndex:0 animated:NO];
			[sc insertSegmentWithTitle:@"<" atIndex:0 animated:NO];
			sc.selectedSegmentIndex = 1;
			sc.tag = 2;
			[cell.contentView addSubview:sc];

		}
		else if ([pred.rightExpression intValue] == IntegerAttributeType)
		{
			UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 8, 65, 30)];

			tf.backgroundColor = [UIColor whiteColor];
			tf.autocorrectionType = UITextAutocorrectionTypeNo;
			tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
			tf.textAlignment = NSTextAlignmentLeft;
			tf.clearButtonMode = UITextFieldViewModeNever;
			tf.placeholder = @"<value>";
			tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			tf.returnKeyType = UIReturnKeyDone;
			tf.tag = 11;
			tf.delegate = self;
			
			[cell.contentView addSubview:tf];


			UISegmentedControl *sc = [[UISegmentedControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width-170, 8, 55, 30)];
			[sc insertSegmentWithTitle:@">" atIndex:0 animated:NO];
			[sc insertSegmentWithTitle:@"<" atIndex:0 animated:NO];
			sc.selectedSegmentIndex = 1;
			sc.tag = 2;
			[cell.contentView addSubview:sc];
			
		}
		else if ([pred.rightExpression intValue] == BooleanAttributeType)
		{

			UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 8, 55, 30)];
			sw.tag = 1;

			[cell.contentView addSubview:sw];

		}
		self.cells[makeString(@"%li", (long)indexPath.row)] = cell;
	}

    return cell;
}

#pragma mark UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PredicateEditorRowTemplate *pred = self.predicateArray[indexPath.row];

	if ([pred.rightExpression isKindOfClass:[NSArray class]])
	{
		JMChoiceController *choiceController = [[JMChoiceController alloc] initWithCompletionBlock:^(NSString *choice, NSInteger index)
		{
			[self.navigationController popViewControllerAnimated:NO];

			UITableViewCell *cell = self.cells[makeString(@"%li", (long)indexPath.row)];

			cell.detailTextLabel.text = choice;
		}];
		choiceController.choices = [@[@"<any>"] arrayByAddingObjectsFromArray:pred.rightExpression];
		choiceController.topTitle = @"Choose Value";
		choiceController.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
		[self.navigationController pushViewController:choiceController animated:YES];
	}
}

#pragma mark UITextFieldDelegate protocol

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

	if ([textField tag] == 11)
		textField.text = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789.,"] invertedSet]];
    return YES;
}
@end
