//
//  iTunesController.m
//  DesktopLyrics
//
//  Created by CoreCode on 22.08.09.
/*	Copyright (c) 2006 - 2012 CoreCode
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "iTunesController.h"
#import "iTunes.h"

@implementation iTunesController

@synthesize title, artist, lyrics, state, album, length, year, start;

- (id)initWithDelegate:(id)_delegate
{
	if ((self = [super init]))
	{
		delegate = _delegate;

		[(NSDistributedNotificationCenter *)[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:@"com.apple.iTunes.playerInfo" object:@"com.apple.iTunes.player"];
	}
	return self;
}

- (void)update:(NSNotification *)n
{
	NSString *oldLyrics = [[lyrics copy] autorelease];

	[self setArtist:@""];
	[self setTitle:@""];
	[self setLyrics:@""];
	[self setAlbum:@""];
	[self setYear:@""];
	[self setLength:0];


	if (n && ![userDefaults boolForKey:kDisplayLyricsWhilePausedKey] && [[[n userInfo] objectForKey:@"Player State"] isEqualToString:@"Paused"])
	{
		[self setState:kPaused];
		[self setArtist:[[n userInfo] objectForKey:@"Artist"]];
		[self setTitle:[[n userInfo] objectForKey:@"Name"]];
		[self setAlbum:[[n userInfo] objectForKey:@"Album"]];
        id y = [[n userInfo] objectForKey:@"Year"];
        if (y && [y isKindOfClass:[NSString class]])
            [self setYear:y];
        else if (y && [y isKindOfClass:[NSNumber class]])
            [self setYear:[y stringValue]];
		[self setLength:[[[n userInfo] objectForKey:@"Total Time"] intValue] / 1000];
	}
	else if (n && [[[n userInfo] objectForKey:@"Player State"] isEqualToString:@"Stopped"])
		[self setState:kStopped];
	else
	{
		@try {
			iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];

			if (!n && ![iTunes isRunning])
				[self setState:kNotRunning];
			else
			{
				[self setState:kPlaying];

				if (n)
				{
					[self setArtist:[[n userInfo] objectForKey:@"Artist"]];
					[self setTitle:[[n userInfo] objectForKey:@"Name"]];
                    id y = [[n userInfo] objectForKey:@"Year"];
                    if (y && [y isKindOfClass:[NSString class]])
                        [self setYear:y];
                    else if (y && [y isKindOfClass:[NSNumber class]])
                             [self setYear:[y stringValue]];
					[self setAlbum:[[n userInfo] objectForKey:@"Album"]];
					[self setLength:[[[n userInfo] objectForKey:@"Total Time"] intValue] / 1000];

//					if ( [[[n userInfo] objectForKey:@"Player State"] isEqualToString:@"Paused"]) // we lie here
//						[self setState:kPaused];
				}
				else if (state != kStopped)
				{
					if ([iTunes playerState] == iTunesEPlSStopped)
						[self setState:kStopped];
					else if ([iTunes playerState] == iTunesEPlSPaused && ![userDefaults boolForKey:kDisplayLyricsWhilePausedKey])
						[self setState:kPaused];
				}

				if (state != kStopped)
				{
					NSString *newlyrics = [[iTunes currentTrack] lyrics];

					if (newlyrics && ![newlyrics isEqualToString:@"msng"] && ![newlyrics isEqualToString:@"(null)"] &&
							  !(([userDefaults boolForKey:kHideInstrumentalKey]) &&
							  ([newlyrics rangeOfString:@"instrumental" options:NSCaseInsensitiveSearch].location != NSNotFound) &&
							  ([newlyrics length] < 20)))
						[self setLyrics:newlyrics];

					[self setArtist:[[iTunes currentTrack] artist]];
					[self setTitle:[[iTunes currentTrack] name]];
					int y = [[iTunes currentTrack] year];
					if (y)
						[self setYear:[NSString stringWithFormat:@"%i", y]];
					[self setAlbum:[[iTunes currentTrack] album]];
					[self setLength:(int)[[iTunes currentTrack] finish]];
					[self setStart:[NSDate dateWithTimeIntervalSinceNow:-[iTunes playerPosition]]];
//					[iTunes setFixedIndexing:FALSE];
//					for (iTunesTrack *t in [[iTunes currentPlaylist] tracks])
//						asl_NSLog_debug(@"%@ %i %i", [t name], (int)[t index], 			(int)		[[iTunes currentTrack] index]);
				}
			}
		}
		@catch (id exception) {
			asl_NSLog(ASL_LEVEL_ERR, @"Error: got exception while trying to communicate with iTunes %@", exception);
		}
	}

	[delegate iTunesDidChange:[oldLyrics isEqualToString:lyrics]];
}

- (void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    
	[self setArtist:nil];
	[self setTitle:nil];
	[self setLyrics:nil];
	[self setAlbum:nil];
	[self setYear:nil];
    
	[super dealloc];
}
@end