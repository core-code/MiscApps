//
//  Movie.m
//  MovieDB
//
//  Created by CoreCode on 19.12.05.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "Movie.h"

@implementation Movie

- (NSInteger)totalSize
{
    [self willAccessValueForKey:@"files"];
	NSInteger size = [[self valueForKeyPath:@"files.@sum.size"] integerValue];
	[self didAccessValueForKey:@"files"];
    return size;
}

- (NSInteger)totalLength
{
    [self willAccessValueForKey:@"files"];
	NSInteger length = [[self valueForKeyPath:@"files.@sum.length"] integerValue];
	[self didAccessValueForKey:@"files"];
    return length;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSArray *keys = @[@"file_audio_codec", @"file_container", @"file_type", @"file_video_codec", @"file_video_height", @"file_video_width", @"imdb_cast", @"imdb_director", @"imdb_genre", @"imdb_id", @"imdb_plot", @"imdb_rating", @"imdb_title", @"imdb_writer", @"imdb_year", @"language", @"rating", @"title"];
    NSDictionary *dict = [self dictionaryWithValuesForKeys:keys];

    return dict;
}

@dynamic file_audio_codec;
@dynamic file_container;
@dynamic file_type;
@dynamic file_video_codec;
@dynamic file_video_height;
@dynamic file_video_width;
@dynamic imdb_cast;
@dynamic imdb_director;
@dynamic imdb_genre;
@dynamic imdb_id;
@dynamic imdb_plot;
@dynamic imdb_poster;
@dynamic imdb_rating;
@dynamic imdb_title;
@dynamic imdb_writer;
@dynamic imdb_year;
@dynamic language;
@dynamic rating;
@dynamic title;
@dynamic files;

@end