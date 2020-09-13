//
//  AppDelegate.m
//  DMGUncompresser
//
//  all credits to Andy Matuschak
//

#import "AppDelegate.h"
#import "JMSUDiskImageUnarchiver.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames
{
    for (NSString *file in filenames)
    {
        JMSUDiskImageUnarchiver *u = [[JMSUDiskImageUnarchiver alloc] initWithArchivePath:file decryptionPassword:nil];
        
        NSError *e = [u unarchive];
        
        if (e)
            [self displayUserNotification:@"DMG Decompression Failure" text:file.lastPathComponent];
        else
            [self displayUserNotification:@"DMG Decompression SUCCESS" text:file.lastPathComponent];
    }
    
    [self displayUserNotification:@"DMG Decompression Finished" text:@"Finito"];
    NSLog(@"DONE with all files");
}

- (void)displayUserNotification:(NSString *)title text:(NSString *)text
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    notification.title = title;
    notification.informativeText = text;
    notification.hasActionButton = NO;
    
    [NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
}



@end

int main(int argc, const char * argv[]) {
    return NSApplicationMain(argc, argv);
}
