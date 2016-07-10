//
//  Musicbrainz.mm
//  MusicWatch
//
//  Created by CoreCode on 23.06.07.
/*	Copyright (c) 2007 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "Musicbrainz.h"
#import "RegexKitLite.h"

@implementation Musicbrainz

#include <iostream>
#include <musicbrainz3/webservice.h>
#include <musicbrainz3/query.h>
#include <musicbrainz3/model.h>

using namespace std;
using namespace MusicBrainz;

+ (NSArray *)artistsForName:(NSString *)name
{
    sleep(SLEEP_TIME);
	if ([name isEqualToString:@"Various Artists"])
		return nil;
	
	Query q;
	ArtistResultList results;
	
	try
	{
		ArtistFilter f = ArtistFilter().name([name UTF8String]).limit(25);
		results = q.getArtists(&f);
	}
	catch (std::exception &e)
	{
		cout << "Error: " << e.what() << endl;
		NSLog(@"%@", name);
		return nil;
	}
		
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:25];

	for (ArtistResultList::iterator i = results.begin(); i != results.end(); i++)
	{
		ArtistResult *result = *i;
				
//		cout << "Score   : " << result->getScore() << endl;
//		cout << "Id	  : " << result->getArtist()->getId() << endl;
//		cout << "Name	: " << result->getArtist()->getName() << endl;
//		cout << "SortName: " << result->getArtist()->getSortName() << endl;
//		cout << endl;
		
		NSString *artist = [NSString stringWithUTF8String:result->getArtist()->getName().c_str()];
		NSNumber *score = [NSNumber numberWithInt:result->getScore()];
		NSString *artistid = [NSString stringWithUTF8String:result->getArtist()->getId().c_str()];

		[array addObject:[NSArray arrayWithObjects:artist, artistid, score, nil]];
	}
	
	return [NSArray arrayWithArray:array];
}

+(NSDictionary *)releasesForArtist:(NSString *)artistid
{
	sleep(SLEEP_TIME);

	Artist *artist;
	Query q;
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];

	try
	{
		ArtistIncludes inc = ArtistIncludes()
		.releases(Release::TYPE_OFFICIAL)
		.releases(Release::TYPE_ALBUM)
		.releaseEvents();
		
		artist = q.getArtistById([artistid UTF8String], &inc);
	}
	catch (std::exception &e)
	{
		cout << "Error: " << e.what() << endl;
		NSLog(@"%@", artistid);
		return nil;
	}
	
/*	cout << "Id		: " << artist->getId() << endl;
	cout << "Name	  : " << artist->getName() << endl;
	cout << "SortName  : " << artist->getSortName() << endl;
	cout << "Type	  : " << artist->getType() << endl;
	cout << "BeginDate : " << artist->getBeginDate() << endl;
	cout << "EndDate   : " << artist->getEndDate() << endl;
	cout << endl;*/
	
	ReleaseList releases = artist->getReleases(); 
	/*if (releases.size() == 0)
		cout << "No releases found." << endl;
	else
		cout << "Releases:" << endl;*/
	
	for (ReleaseList::iterator i = releases.begin(); i != releases.end(); i++)
	{
        int oldestYear = 0xFFFF;
		Release *release = *i;
	/*	cout << endl;
		cout << "Id		: " << release->getId() << endl;
		cout << "Title	 : " << release->getTitle() << endl;
		if (release->getReleaseEvents().size() != 0)
			cout << "Date		: " << release->getReleaseEvent(0)->getDate() << endl;*/
		
		
		NSString *title = [NSString stringWithUTF8String:release->getTitle().c_str()];
		NSString *releaseid = [NSString stringWithUTF8String:release->getId().c_str()];
		NSNumber *year = [NSNumber numberWithShort:1900];
		
		for (uint32_t i = 0; i < release->getReleaseEvents().size(); i++) // TODO: two releases of the same album with different names (bug or slightly differently named rerelese) will be added twice
        {
            NSString *str = [NSString stringWithUTF8String:release->getReleaseEvent(i)->getDate().c_str()];
            
            if ([str length] >= 4)
            { 
                int tmpYear = [[str substringToIndex:4] intValue];
                
                if (tmpYear < oldestYear)
                    oldestYear = tmpYear;
            }
        }
		
        if (oldestYear != 0xFFFF)
            year = [NSNumber numberWithInt:oldestYear];
        
		title = [title stringByReplacingOccurrencesOfString:@" (CD)" withString:@""];
		title = [title stringByReplacingOccurrencesOfRegex:@" \\(disc [0-9]\\)" withString:@"" options:RKLCaseless range:NSMakeRange(0, [title length]) error:NULL];
		title = [title stringByReplacingOccurrencesOfRegex:@" \\(disc [0-9].*\\)" withString:@"" options:RKLCaseless range:NSMakeRange(0, [title length]) error:NULL];
		title = [title stringByReplacingOccurrencesOfRegex:@" \\(bonus disc.*\\)" withString:@"" options:RKLCaseless range:NSMakeRange(0, [title length]) error:NULL];

		if (([dict objectForKey:title] == nil) || ([[[dict objectForKey:title] lastObject] intValue] > [year intValue]) || ([[[dict objectForKey:title] lastObject] intValue] == 1900 && [year intValue] != 1900))
			[dict setObject:[NSArray arrayWithObjects:releaseid, year, nil] forKey:title];
	}
	
	delete artist;
	
    sleep(SLEEP_TIME);
	return dict;
}
@end