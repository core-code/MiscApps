//
//  PrintViewController.m
//  TableEdit-Lite
//
//  Created by CoreCode on 08/10/2016.
/*    Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


#import "PrintViewController.h"

@interface PrintViewController ()

@end



@implementation PrintViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self addObserver:self forKeyPath:@"representedObject" options:NSKeyValueObservingOptionNew context:NULL];
    }

    return self;
}

- (NSSet *)keyPathsForValuesAffectingPreview
{

    return @[@"representedObject.leftMargin",
             @"representedObject.rightMargin",
             @"representedObject.bottomMargin",
             @"representedObject.topMargin",
             @"representedObject.horizontallyCentered",
             @"representedObject.verticallyCentered",
             @"representedObject.horizontalPagination",
             @"representedObject.verticalPagination"].set;
}

- (NSArray *)localizedSummaryItems
{
    return @[@{NSPrintPanelAccessorySummaryItemNameKey : @"name", NSPrintPanelAccessorySummaryItemDescriptionKey : @"desc"}];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context // we want to save settings
{
    LOGFUNCA;
    NSPrintInfo *info = self.representedObject;

    if ([keyPath isEqualToString:@"representedObject"])
    {
//        id old = change[NSKeyValueChangeOldKey];
//
//        [old removeObserver:self];

        [info addObserver:self forKeyPath:@"leftMargin" options:NSKeyValueObservingOptionNew context:NULL];
        [info addObserver:self forKeyPath:@"rightMargin" options:NSKeyValueObservingOptionNew context:NULL];
        [info addObserver:self forKeyPath:@"bottomMargin" options:NSKeyValueObservingOptionNew context:NULL];
        [info addObserver:self forKeyPath:@"topMargin" options:NSKeyValueObservingOptionNew context:NULL];
        [info addObserver:self forKeyPath:@"horizontallyCentered" options:NSKeyValueObservingOptionNew context:NULL];
        [info addObserver:self forKeyPath:@"verticallyCentered" options:NSKeyValueObservingOptionNew context:NULL];
        [info addObserver:self forKeyPath:@"horizontalPagination" options:NSKeyValueObservingOptionNew context:NULL];
        [info addObserver:self forKeyPath:@"verticalPagination" options:NSKeyValueObservingOptionNew context:NULL];
    }
    else if ([keyPath isEqualToString:@"leftMargin"])
    {
        kPrintSettingsLeftMarginKey.defaultInt = (int)info.leftMargin;
    }
    else if ([keyPath isEqualToString:@"rightMargin"])
    {
        kPrintSettingsRightMarginKey.defaultInt = (int)info.rightMargin;
    }
    else if ([keyPath isEqualToString:@"bottomMargin"])
    {
        kPrintSettingsBottomMarginKey.defaultInt = (int)info.bottomMargin;
    }
    else if ([keyPath isEqualToString:@"topMargin"])
    {
        kPrintSettingsTopMarginKey.defaultInt = (int)info.topMargin;
    }
    else if ([keyPath isEqualToString:@"horizontallyCentered"])
    {
        kPrintSettingsHorizontallyCenteredKey.defaultInt = info.horizontallyCentered;
    }
    else if ([keyPath isEqualToString:@"verticallyCentered"])
    {
        kPrintSettingsVerticallyCenteredKey.defaultInt = info.verticallyCentered;
    }
    else if ([keyPath isEqualToString:@"horizontalPagination"])
    {
        kPrintSettingsHorizontalPaginationKey.defaultInt = info.horizontalPagination;
    }
    else if ([keyPath isEqualToString:@"verticalPagination"])
    {
        kPrintSettingsVerticalPaginationKey.defaultInt = info.verticalPagination;
    }
}

- (void)dealloc
{
    [self.representedObject removeObserver:self forKeyPath:@"leftMargin"];
    [self.representedObject removeObserver:self forKeyPath:@"rightMargin"];
    [self.representedObject removeObserver:self forKeyPath:@"bottomMargin"];
    [self.representedObject removeObserver:self forKeyPath:@"topMargin"];
    [self.representedObject removeObserver:self forKeyPath:@"horizontallyCentered"];
    [self.representedObject removeObserver:self forKeyPath:@"verticallyCentered"];
    [self.representedObject removeObserver:self forKeyPath:@"horizontalPagination"];
    [self.representedObject removeObserver:self forKeyPath:@"verticalPagination"];

    [self removeObserver:self forKeyPath:@"representedObject"];
}

@end
