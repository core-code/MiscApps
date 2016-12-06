//
//  DataImporters.m
//  MusicWatch
//
//  Created by CoreCode on 24.06.07.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "DataImporters.h"
#import "iTunes.h"
#import "RegexKitLite.h"

#include <stdio.h>
#include <tag_c.h>

NSString *cleanAlbumName(NSString *album);

@implementation TaglibImporter

+ (NSDictionary *)infoForFilesInDirectories:(NSArray *)URLs
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:100];
	
	for (NSURL *url in URLs)
	{
		NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:url.path];
		
		for (NSString *file in dirEnum)
		{
			if (([file.pathExtension isEqualToString: @"mp3"]) ||
				([file.pathExtension isEqualToString: @"ogg"]) ||
				([file.pathExtension isEqualToString: @"flac"]) ||
				([file.pathExtension isEqualToString: @"mpc"]))
			{
				TagLib_File *f;
				TagLib_Tag *tag;
				NSString *artist, *album;
				unsigned int year;
				
				f = taglib_file_new([url.path stringByAppendingPathComponent:file].UTF8String);
				
				if (f == NULL)
					continue;
				
				tag = taglib_file_tag(f);
				
				artist = @(taglib_tag_artist(tag));
				album = @(taglib_tag_album(tag));
				year = taglib_tag_year(tag);
				
				album = cleanAlbumName(album);
					
				taglib_tag_free_strings();
				taglib_file_free(f);
				
				NSMutableDictionary *artistDict = dict[artist];
				
				if ([artist isEqualToString:@""] || [album isEqualToString:@""])
					continue;
				
				if (artistDict == nil)
					dict[artist] = [NSMutableDictionary dictionaryWithObject:@(year) forKey:album];
				else
				{			
					if (dict[artistDict] == nil)
						artistDict[album] = @(year);
				}	
			}
		}
	}
	return dict;
}
@end

@implementation iTunesImporter

+ (NSDictionary *)infoForFilesInPlaylist:(NSString *)playlistName
{
	iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	iTunesPlaylist *playlist = [[(iTunes.sources)[0] userPlaylists] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", playlistName]][0];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:100];
	
	for (iTunesTrack *track in [playlist tracks])
	{
			NSString *artist, *album;
			unsigned int year;
						
			artist = track.artist;
			album = track.album;
			year = track.year;
			
			
			album = cleanAlbumName(album);
		
		
			NSMutableDictionary *artistDict = dict[artist];
			
			if ([artist isEqualToString:@""] || [album isEqualToString:@""])
				continue;
			
			if (artistDict == nil)
				dict[artist] = [NSMutableDictionary dictionaryWithObject:@(year) forKey:album];
			else
			{			
				if (dict[artistDict] == nil)
					artistDict[album] = @(year);
			}	
	}
	return dict;
}
@end

NSString *cleanAlbumName(NSString *album)
{
	NSString *ret = album;
	
	ret = [ret stringByReplacingOccurrencesOfRegex:@"\\(disk [0-9].*\\)" withString:@"" options:RKLCaseless range:NSMakeRange(0, ret.length) error:NULL];
	ret = [ret stringByReplacingOccurrencesOfRegex:@"\\(disc [0-9].*\\)" withString:@"" options:RKLCaseless range:NSMakeRange(0, ret.length) error:NULL];
	ret = [ret stringByReplacingOccurrencesOfRegex:@"\\(cd [0-9].*\\)" withString:@"" options:RKLCaseless range:NSMakeRange(0, ret.length) error:NULL];																						
	ret = [ret stringByReplacingOccurrencesOfRegex:@"\\(bonus.*\\)" withString:@"" options:RKLCaseless range:NSMakeRange(0, ret.length) error:NULL];																																	   
											   
	
	NSArray *replacementList = @[@"bonus cd", @"bonus disc", @"bonus disk", @"cd 1", @"disk 1", @"disc 2", @"cd 2", @"disk 2", @"disc 2", @"cd 3", @"disk 3", @"disc 3", @"special edition", @"limited edition", @"digipak", @"(o.s.t)", @"(o.s.t.)", @"(live)", @"(ost)", @"()", @"()", @"()"];
	
	for (NSString *search in replacementList)
	{
		NSRange r = [ret rangeOfString:search options:NSCaseInsensitiveSearch];
		if (r.location != NSNotFound)
			ret = [ret stringByReplacingCharactersInRange:r withString:@""];
	}

	ret = [ret stringByReplacingOccurrencesOfString:@"…" withString:@"..."];
	ret = [ret stringByReplacingOccurrencesOfString:@"…" withString:@"..."];
	ret = [ret stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	return ret;
}