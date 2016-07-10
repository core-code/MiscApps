//
//  NSString+DamerauLevenshtein.h
//  MusicWatch
//  Copyright http://weblog.wanderingmango.com/articles/14/fuzzy-string-matching-and-the-principle-of-pleasant-surprises
//


@interface NSString (DamerauLevenshteinAdditions) 

- (float) compareWithString: (NSString *)stringB;

@end
