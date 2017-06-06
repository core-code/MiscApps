#import <Foundation/Foundation.h>
#import <Vision/Vision.h>

int printUsage(void)
{
    NSLog(@"usage: visionOCR [imagePath OR imageURL]");
    return 1;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        if (argc < 2)
            return printUsage();
        
        NSString *path = @(argv[1]);
        NSURL *url;
        if ([path hasPrefix:@"/"])
            url = [NSURL fileURLWithPath:path];
        else if ([path hasPrefix:@"http"])
            url = [NSURL URLWithString:path];
        else
            return printUsage();
    
    
        
        VNDetectTextRectanglesRequest *request = [[VNDetectTextRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error)
	    {
            NSArray *results = request.results;
        
            if (!results.count)
                NSLog(@"NO textObservations found");
            
            if (error)
                NSLog(@"%@", error.description);
            
            for (VNTextObservation *result in results)
            {
                CGRect r = result.boundingBox;
                VNConfidence c = result.confidence;
                NSUUID *u = result.uuid;

            
                NSLog(@"found textObservation %@ with confidence %f and rect %@", u.UUIDString, c, NSStringFromRect(r));
            }
        }];
        
        NSError *error;
        VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithURL:url options:@{}];
    
        [handler performRequests:@[request]  error:&error];
        
        if (error)
            NSLog(@"%@", error.description);
    }
    return 0;
}
