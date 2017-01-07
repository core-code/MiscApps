//
//  AppDelegate.m
//  SpotifyAdBlocker
//
//  Created by CoreCode on 07/01/2017.
//  Copyright © 2017 CoreCode Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "SpotifyClient.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self performSelector:@selector(timer) withObject:nil afterDelay:1.0];
}

- (void)timer
{
    SpotifyClientApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    if (!spotify.isRunning)
    {
        [self performSelector:@selector(timer) withObject:nil afterDelay:60.0];
        return;
    }
    
    SpotifyClientTrack *currentTrack = spotify.currentTrack;

    
    if ([currentTrack.name isEqualToString:@"Spotify"] && currentTrack.artist.length == 0)
        spotify.soundVolume = 0;
    else
        spotify.soundVolume = 100;

    
    if (spotify.playerState == SpotifyClientEPlSPlaying)
        [self performSelector:@selector(timer) withObject:nil afterDelay:1.0];
    else
        [self performSelector:@selector(timer) withObject:nil afterDelay:60.0];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{

}
@end

int main(int argc, const char * argv[])
{
    return NSApplicationMain(argc, argv);
}
