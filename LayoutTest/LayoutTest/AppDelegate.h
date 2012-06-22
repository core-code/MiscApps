//
//  AppDelegate.h
//  LayoutTest
//
//  Created by CoreCode on 04.05.12.
//  Copyright (c) 2012 CoreCode. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define $earray             ([NSArray array])
#define $emarray            ([NSMutableArray array])
#define $array(OBJS...)     ((NSArray *)([NSArray arrayWithObjects:OBJS, nil]))
#define $marray(OBJS...)    ([NSMutableArray arrayWithObjects:OBJS, nil])
#define $dict(PAIRS...)     ([NSDictionary dictionaryWithObjectsAndKeys:PAIRS, nil])
#define $mdict(PAIRS...)    ([NSMutableDictionary dictionaryWithObjectsAndKeys:PAIRS, nil])
#define $num(num)			([NSNumber numberWithFloat:num])
#define $numd(num)			([NSNumber numberWithDouble:num])
#define $numi(num)			([NSNumber numberWithInteger:num])
#define $numui(num)			([NSNumber numberWithUnsignedInt:num])
#define $string(str...)     ([NSString stringWithString:str])
#define $stringcu8(x)       ([NSString stringWithUTF8String:x])
#define $mstring(str)       ([NSMutableString stringWithString:str])
#define $stringf(format...) ([NSString stringWithFormat:format])
#define $mstringf(format...)([NSMutableString stringWithFormat:format])


@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	int y;
}
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSScrollView *scrollView;

@end
