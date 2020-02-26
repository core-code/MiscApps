//
//  JMWebView.h
//  CoreLib
//
//  Created by CoreCode on 06.03.15.
/*	Copyright © 2020 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#include "CoreLib.h"

#if __has_feature(modules)
@import WebKit;
@import WebKit.WebPolicyDelegate;
@import WebKit.WebResourceLoadDelegate;
#else
#import <WebKit/WebKit.h>
#endif

// TODO: port to WKWebView

@interface JMWebView : WebView  <WebPolicyDelegate, WebResourceLoadDelegate>

@property (strong, nonatomic) IBInspectable NSString *localHTMLName;	// this is loaded first
@property (strong, nonatomic) IBInspectable NSString *remoteHTMLURL;	// if this is set and internet is online the contents are replaced with the live version
@property (strong, nonatomic) IBInspectable NSNumber *zoomFactor;	
@property (assign, nonatomic) IBInspectable BOOL disableScrolling;
@property (assign, nonatomic) BOOL openOnlyClicksInBrowser;


@end
