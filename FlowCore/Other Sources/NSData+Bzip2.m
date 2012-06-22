#import "NSData+Bzip2.h"
#import "bzlib.h"

@implementation NSData (Bzip2)

- (NSData *) bunzip2
{
	int bzret;
	bz_stream stream = { 0 };
	stream.next_in = (void *)[self bytes];
	stream.avail_in = [self length];
	
	const int buffer_size = 10000;
	NSMutableData * buffer = [NSMutableData dataWithLength:buffer_size];
	stream.next_out = [buffer mutableBytes];
	stream.avail_out = buffer_size;
	
	NSMutableData * decompressed = [NSMutableData data];
	
	BZ2_bzDecompressInit(&stream, 0, NO);
	@try {
		do {
			bzret = BZ2_bzDecompress(&stream);
			if (bzret != BZ_OK && bzret != BZ_STREAM_END)
				@throw [NSException exceptionWithName:@"bzip2" reason:@"BZ2_bzDecompress failed" userInfo:nil];

			[decompressed appendBytes:[buffer bytes] length:(buffer_size - stream.avail_out)];
			stream.next_out = [buffer mutableBytes];
			stream.avail_out = buffer_size;
		} while(bzret != BZ_STREAM_END);
	}
	@finally {
		BZ2_bzCompressEnd(&stream);
	}
	
	return decompressed;
}
@end