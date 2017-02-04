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

//    NSLog(@"artist %@", currentTrack.artist);
//    NSLog(@"name %@", currentTrack.name);
//    NSLog(@"dn %@", @(currentTrack.discNumber).description);
//    NSLog(@"pc %@", @(currentTrack.playedCount).description);
//    NSLog(@"tn %@", @(currentTrack.trackNumber).description);
//    NSLog(@"st %@", @(currentTrack.starred).description);
//    NSLog(@"po %@", @(currentTrack.popularity).description);
//    NSLog(@"au %@", (currentTrack.artworkUrl));
//    NSLog(@"aw %@", (currentTrack.artwork));
//    NSLog(@"aa %@", (currentTrack.albumArtist));
//    NSLog(@"su %@", (currentTrack.spotifyUrl));
//
//    NSLog(@"%li %i %i %i", (long)currentTrack.duration, (currentTrack.duration > 29500 && currentTrack.duration < 31000), (currentTrack.duration > 14500 && currentTrack.duration < 15500), currentTrack.artist.length == 0);
    BOOL isAdForSure = [currentTrack.name isEqualToString:@"Spotify"] || [currentTrack.spotifyUrl hasPrefix:@"spotify:ad:"];
    BOOL isAdByLength = ((currentTrack.duration > 29500 && currentTrack.duration < 31000) ||
                         (currentTrack.duration > 14500 && currentTrack.duration < 15500)) &&
                        currentTrack.artist.length == 0 &&
                        currentTrack.albumArtist.length == 0 &&
                        currentTrack.discNumber == 0 &&
                        currentTrack.trackNumber == 0;
    
    
    if (isAdForSure || isAdByLength)
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
