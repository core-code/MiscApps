//
//  MusicWatch_AppDelegate.h
//  MusicWatch
//
//  Created by CoreCode on 17.06.07.
/*	Copyright (c) 2016 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "MatchTableDataSource.h"

@interface MusicWatch_AppDelegate : NSObject
{
	IBOutlet MatchTableDataSource *matchTableDataSource;
	
	IBOutlet NSTableView *matchTableView;
	IBOutlet NSTableView *artistsTableView;
	IBOutlet NSTableView *releasesTableView;
	
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSWindow *addSheet;
	IBOutlet NSWindow *matchSheet;
	IBOutlet NSWindow *progressScanSheet;
	IBOutlet NSWindow *progressLookupSheet;
	IBOutlet NSPopUpButton *playlistsPopup;
	IBOutlet NSProgressIndicator *progressScanIndicator;
	IBOutlet NSProgressIndicator *progressLookupIndicator;
	IBOutlet NSMatrix *sourceMatrix;	
	IBOutlet NSArrayController *releaseArrayController;
	IBOutlet NSArrayController *artistArrayController;
	IBOutlet NSTextField *matchTextField;
	
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
}

- (void)updateArtist:(NSManagedObject *)artist;
- (void)addArtistsAndReleases:(NSDictionary *)dict;
- (void)updateDockIcon;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (void)addFolders:(NSArray *)URLs;
- (void)addPlaylist:(NSString *)path;

- (IBAction)markEverythingSeenAction:(id)sender;
- (IBAction)matchSheetAction:(id)sender;
- (IBAction)addSheetAction:(id)sender;
- (IBAction)refreshAction:(id)sender;
- (IBAction)addAction:(id)sender;
- (IBAction)removeAction:(id)sender;
- (IBAction)markAllAsSeenAction:(id)sender;
- (IBAction)markAsOwnedAction:(id)sender;
- (IBAction)markAsUnseenAction:(id)sender;
- (IBAction)matchAlbumsAction:(id)sender;
- (IBAction)selectPlaylistAction:(id)sender;

/*************************************************************
 **********				GENERATED CODE				**********
 *************************************************************/

- (IBAction)saveAction:(id)sender;

@end