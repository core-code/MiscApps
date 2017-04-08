//
//  Movie.h
//  MovieDB
//
//  Created by CoreCode on 19.12.05.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

@interface Movie : NSManagedObject
{
	NSInteger totalLength;
	NSInteger totalSize;	
}

@property (readonly) NSInteger totalLength;
@property (readonly) NSInteger totalSize;

@property (strong) NSString * file_audio_codec;
@property (strong) NSString * file_container;
@property (strong) NSNumber * file_type;
@property (strong) NSString * file_video_codec;
@property (strong) NSNumber * file_video_height;
@property (strong) NSNumber * file_video_width;
@property (strong) NSString * imdb_cast;
@property (strong) NSString * imdb_director;
@property (strong) NSString * imdb_genre;
@property (strong) NSString * imdb_id;
@property (strong) NSString * imdb_plot;
@property (strong) NSData * imdb_poster;
@property (strong) NSNumber * imdb_rating;
@property (strong) NSString * imdb_title;
@property (strong) NSString * imdb_writer;
@property (strong) NSNumber * imdb_year;
@property (strong) NSNumber * language;
@property (strong) NSNumber * rating;
@property (strong) NSString * title;
@property (strong) NSSet* files;


- (NSDictionary *)dictionaryRepresentation;

@end

@interface Movie (CoreDataGeneratedAccessors)
- (void)addFilesObject:(NSManagedObject *)value;
- (void)removeFilesObject:(NSManagedObject *)value;
- (void)addFiles:(NSSet *)value;
- (void)removeFiles:(NSSet *)value;
@end