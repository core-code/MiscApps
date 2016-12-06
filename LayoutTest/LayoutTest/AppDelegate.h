//
//  AppDelegate.h
//  LayoutTest
//
//  Created by CoreCode on 04.05.12.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
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
