//
//  MusicWatch_AppDelegate.m
//  MusicWatch
//
//  Created by CoreCode on 17.06.07.
/*	Copyright © 2018 CoreCode Limited
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import "MusicWatch_AppDelegate.h"
#import "ValueTransformer.h"
#import "Musicbrainz.h"
#import "DataImporters.h"
#import "iTunes.h"
#import "NSString+DamerauLevenshtein.h"

NSImage *newIcon;

@implementation MusicWatch_AppDelegate

+ (void)initialize
{
	UnseenCountValueTransformer *ucvt = [[UnseenCountValueTransformer alloc] init];
	AlbumColorValueTransformer *acvt = [[AlbumColorValueTransformer alloc] init];
	UnseenIconValueTransformer *uivt = [[UnseenIconValueTransformer alloc] init];
	EmptyValueTransformer *evt = [[EmptyValueTransformer alloc] init];
	
	
	[NSValueTransformer setValueTransformer:evt forName:@"EmptyValueTransformer"];
	[NSValueTransformer setValueTransformer:acvt forName:@"AlbumColorValueTransformer"];
	[NSValueTransformer setValueTransformer:ucvt forName:@"UnseenCountValueTransformer"];
	[NSValueTransformer setValueTransformer:uivt forName:@"UnseenIconValueTransformer"];
	
	newIcon = [NSImage imageNamed:@"unread"];
}

- (void)awakeFromNib
{
	[self updateDockIcon];
	
	[artistsTableView registerForDraggedTypes:@[NSFilenamesPboardType]];

	artistsTableView.doubleAction = @selector(artistsTableDoubleClick:);
	releasesTableView.doubleAction = @selector(releasesTableDoubleClick:);
	
	NSSortDescriptor * sd = [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES];
	artistsTableView.sortDescriptors = @[sd];
	[sd release];
	
	sd = [[NSSortDescriptor alloc] initWithKey:@"Year" ascending:NO];
	releasesTableView.sortDescriptors = @[sd];
	[sd release];
	
	[artistsTableView scrollRowToVisible:artistsTableView.selectedRow];
}

- (void)artistsTableDoubleClick:(id)sender
{
	NSURL *url = [NSURL URLWithString:[[artistArrayController.selection valueForKey:@"id"] stringByReplacingOccurrencesOfString:@"/artist/" withString:@"/show/artist/?mbid="]];

	if (![[NSWorkspace sharedWorkspace] openURL:url])
		NSLog(@"Warning: [[NSWorkspace sharedWorkspace] openURL:url] failed");
}

- (void)releasesTableDoubleClick:(id)sender
{
	NSURL *url = [NSURL URLWithString:[[releaseArrayController.selection valueForKey:@"id"] stringByReplacingOccurrencesOfString:@"/release/" withString:@"/show/release/?mbid="]];

	if (![[NSWorkspace sharedWorkspace] openURL:url])
		NSLog(@"Warning: [[NSWorkspace sharedWorkspace] openURL:url] failed");
}

- (IBAction)addAction:(id)sender
{
	iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	NSArray *playlists = [[(iTunes.sources)[0] userPlaylists] arrayByApplyingSelector:@selector(name)];
	
	for (NSString *playlist in playlists)
		[playlistsPopup addItemWithTitle:playlist];
	
	[NSApp beginSheet:addSheet modalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (IBAction)removeAction:(id)sender
{
	if (mainWindow.firstResponder == artistsTableView)
	{
        if (NSRunAlertPanel(@"MusicWatch", @"%@", [NSString stringWithFormat:@"Do you really want to remove the artist \"%@\"?",
											[artistArrayController.selection valueForKey:@"name"]], @"Remove", @"Cancel", nil) == NSAlertDefaultReturn)
				[artistArrayController remove:self];
	}
	else if ((mainWindow.firstResponder == releasesTableView) && (releaseArrayController.canRemove))
	{
        if (NSRunAlertPanel(@"MusicWatch", @"%@", [NSString stringWithFormat:@"Do you really want to remove the album \"%@\"?",
											[releaseArrayController.selection valueForKey:@"name"]], @"Remove", @"Cancel", nil) == NSAlertDefaultReturn)
			[releaseArrayController remove:self];
	}
	[self updateDockIcon];	
}

- (IBAction)markAllAsSeenAction:(id)sender
{	
	for (NSManagedObject *album in [[artistArrayController.selection valueForKey:@"releases"] objectEnumerator])
	{
		[album setValue:@0 forKey:@"unseen"];
	}	
	[self updateDockIcon];	
}

- (IBAction)markAsOwnedAction:(id)sender
{
	[releaseArrayController.selection setValue:@1 forKey:@"owned"];
}

- (IBAction)markAsUnseenAction:(id)sender
{
	[releaseArrayController.selection setValue:@1 forKey:@"unseen"];
}

- (IBAction)matchAlbumsAction:(id)sender
{
	matchTextField.stringValue = [NSString stringWithFormat:@"Match \"%@\" with:", [releaseArrayController.selection valueForKey:@"name"]];
	[matchTableDataSource.matchAlbumArray removeAllObjects];
	
	for (NSManagedObject *album in [[artistArrayController.selection valueForKey:@"releases"] objectEnumerator])
	{
		if (! [[album valueForKey:@"name"] isEqualToString:[releaseArrayController.selection valueForKey:@"name"]])
			[matchTableDataSource.matchAlbumArray addObject:album];
	}	
	
	[NSApp beginSheet:matchSheet modalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (IBAction)refreshAction:(id)sender
{
	[NSApp beginSheet:progressLookupSheet modalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [progressLookupIndicator setUsesThreadedAnimation:YES];
    [progressLookupIndicator startAnimation:self];
	
	
	for (NSManagedObject *artist in artistArrayController.arrangedObjects)
		if ([artist valueForKey:@"id"] && ![[artist valueForKey:@"id"] isEqualToString:@""])
			[self updateArtist:artist];
	
	[progressLookupIndicator stopAnimation:self];
	[NSApp endSheet:progressLookupSheet];
	[progressLookupSheet orderOut:self];
}

- (IBAction)markEverythingSeenAction:(id)sender
{
	for (NSManagedObject *artist in artistArrayController.arrangedObjects)
		for (NSManagedObject *album in [[artist valueForKey:@"releases"] objectEnumerator])
			[album setValue:@0 forKey:@"unseen"];


	[self updateDockIcon];	
}

- (IBAction)selectPlaylistAction:(id)sender
{
	[sourceMatrix selectCellAtRow:1 column:0];
}

- (IBAction)addSheetAction:(id)sender
{
    [NSApp endSheet:addSheet];
    [addSheet orderOut:self];
	
	if ([[sender title] isEqualToString:@"Add"])
	{
		if (sourceMatrix.selectedRow == 0)
		{
			NSOpenPanel *panel = [NSOpenPanel openPanel];
			
			[panel setAllowsMultipleSelection:YES];
			[panel setCanChooseDirectories:YES];
			[panel setCanChooseFiles:NO];
			
			[panel beginSheetForDirectory:nil
									 file:nil
									types:nil
						   modalForWindow:mainWindow
							modalDelegate:self
						   didEndSelector:@selector(openPanelDidEnd:
													returnCode:
													contextInfo:)
							  contextInfo:nil];
		}
		else
		{
			[self addPlaylist:playlistsPopup.titleOfSelectedItem];
		}
	}
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{	
	if (returnCode == NSOKButton)
		[self performSelector:@selector(addFolders:) withObject:panel.URLs afterDelay:0.1];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSTableView *table = aNotification.object;
	
	if (table.selectedRow != -1)
	{
		NSArray *selectedObjects = releaseArrayController.selectedObjects;
		NSEntityDescription *entity = selectedObjects[0];
		//NSLog([entity valueForKey:@"name"]);
		[entity setValue:@0 forKey:@"unseen"];
	}
	
	[self updateDockIcon];
}

- (void)addFolders:(NSArray *)URLs
{
	[NSApp beginSheet:progressScanSheet modalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [progressScanIndicator setUsesThreadedAnimation:YES];
    [progressScanIndicator startAnimation:self];
    
	
	NSDictionary *dict = [TaglibImporter infoForFilesInDirectories:URLs];
	
	
    [progressScanIndicator stopAnimation:self];
    [NSApp endSheet:progressScanSheet];
    [progressScanSheet orderOut:self];
	
	
	[NSApp beginSheet:progressLookupSheet modalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [progressLookupIndicator setUsesThreadedAnimation:YES];
    [progressLookupIndicator startAnimation:self];
	
	
	[self addArtistsAndReleases:dict];

	
	[progressLookupIndicator stopAnimation:self];
	[NSApp endSheet:progressLookupSheet];
	[progressLookupSheet orderOut:self];
}

- (void)addPlaylist:(NSString *)path
{
    [NSApp beginSheet:progressScanSheet modalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [progressScanIndicator setUsesThreadedAnimation:YES];
    [progressScanIndicator startAnimation:self];
    
	
	NSDictionary *dict = [iTunesImporter infoForFilesInPlaylist:path];
	
	
    [progressScanIndicator stopAnimation:self];
    [NSApp endSheet:progressScanSheet];
    [progressScanSheet orderOut:self];
	
    
    [NSApp beginSheet:progressLookupSheet modalForWindow:mainWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[progressLookupIndicator setUsesThreadedAnimation:YES];
    [progressLookupIndicator startAnimation:self];
    
	
	[self addArtistsAndReleases:dict];
    
	[progressLookupIndicator stopAnimation:self];
	[NSApp endSheet:progressLookupSheet];
	[progressLookupSheet orderOut:self];
	
}

- (void)addArtistsAndReleases:(NSDictionary *)artists_dict
{
	NSError *error;

	for (NSString *artist_name in artists_dict)
	{
		[artistArrayController fetchWithRequest:nil merge:NO error:&error];
		BOOL			restart = YES;
		NSManagedObject *artist = nil;
		NSMutableSet	*albums = nil;
		NSMutableSet	*preexisting_mb_albums = nil;
		

		// try to match to an existing artist
        while (restart)
        {
        restart = NO;
		for (NSManagedObject *a in artistArrayController.arrangedObjects)
		{
			if ([[a valueForKey:@"name"] isEqualToString:artist_name])
			{
				artist = a;
				
				albums = [artist valueForKey:@"releases"];
				

				preexisting_mb_albums = [NSMutableSet new];
				for (NSManagedObject *existing_album in albums)
					if (![[existing_album valueForKey:@"owned"] boolValue])
						[preexisting_mb_albums addObject:existing_album];
				[albums minusSet:preexisting_mb_albums]; 
				
				break;
			}	
		}
		
		// create artist and album list if it is new
		if (!artist)
		{
			artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext: managedObjectContext];
			albums = [NSMutableSet setWithCapacity:5];
			[artist setValue:artist_name forKey:@"name"];
		}
 				
		// add new local albums	
		NSMutableDictionary *albums_dict = artists_dict[artist_name];
		for (NSString *album_name in albums_dict)
		{
			BOOL skip = NO;
			
			for (NSManagedObject *existing_album in albums)
				if ([[existing_album valueForKey:@"name"] compare:album_name options:NSCaseInsensitiveSearch] == kCFCompareEqualTo)
					skip = YES;
			
			if (skip)
				continue;
			
			
			NSManagedObject *album = [NSEntityDescription
									  insertNewObjectForEntityForName:@"Release"
									  inManagedObjectContext: managedObjectContext];
						
			[album setValue:album_name forKey:@"name"];
			[album setValue:albums_dict[album_name] forKey:@"year"];
			[album setValue:@YES forKey:@"owned"];
			[album setValue:@0 forKey:@"unseen"];
			[album setValue:artist forKey:@"artist"];
			[album setValue:@"" forKey:@"id"];
			
			[albums addObject:album];
		}
		
		[artist setValue:albums forKey:@"releases"];
		
		// already matched, just update
		if ([artist valueForKey:@"id"] && ![[artist valueForKey:@"id"] isEqualToString:@""])
			[self updateArtist:artist];
		else // need to match to a MB artist
		{			
			NSArray *mb_artists = [Musicbrainz artistsForName:artist_name];
			
			[artist setValue:@"" forKey:@"id"];	
			
			
			for (NSArray *mb_artist in mb_artists)
			{
				[artist setValue:mb_artist[1] forKey:@"id"];
				
				[self updateArtist:artist];
				
				BOOL matches = NO;
				NSMutableSet *releases = [artist valueForKey:@"releases"];
				
				for (NSManagedObject *release in [releases objectEnumerator])
				{
					if ([[release valueForKey:@"owned"] boolValue] && [release valueForKey:@"id"]  && ![[release valueForKey:@"id"] isEqualToString:@""])
					{
						matches = TRUE;
						break;
					}
				}
				
				if (matches)
				{
				// TODO: fix this not working at all anymore
#warning error THIS IS BROKEN
#warning error THIS IS BROKEN
#warning error THIS IS BROKEN
					if ([mb_artist[2] intValue] < 100)
						NSLog(@"Warning: matching %@ to %@ with score %i", artist_name, mb_artist[0], [mb_artist[2] intValue]);
					
					
					for (NSManagedObject *other_artist in artistArrayController.arrangedObjects) // ok if the artist was misspelled and already exists in our library we gotta jump back
					{
						if (other_artist != artist && [[other_artist valueForKey:@"id"] isEqualToString:[artist valueForKey:@"id"]])
						{
							[artistArrayController fetchWithRequest:nil merge:NO error:&error];
							[artistArrayController removeObject:artist];
							artist = other_artist;

							restart = YES;
						}
					}		
					
					break;
				}
				else
				{
					[artist setValue:@"" forKey:@"id"]; // TODO: artist matching doesn't work if we have only local albums that cant be matched
					
					// erase musicbrainz_only albums
					NSMutableSet *all_albums = [artist valueForKey:@"releases"];
					NSMutableSet *albums_to_erase = [NSMutableSet new];
					for (NSManagedObject *existing_album in all_albums)
						if (![[existing_album valueForKey:@"owned"] boolValue])
							[albums_to_erase addObject:existing_album];
					[all_albums minusSet:albums_to_erase]; 
					[artist setValue:all_albums forKey:@"releases"];	
				}
			}
			
		}
        }

		for (NSManagedObject *old_mb_album in preexisting_mb_albums)	// mark those albums that we already have seen but removed for matching as seen again
			for (NSManagedObject *new_album in [artist valueForKey:@"releases"])
				if ([[old_mb_album valueForKey:@"id"] isEqualToString:[new_album valueForKey:@"id"]])
					if (![[old_mb_album valueForKey:@"unseen"] boolValue] && [[new_album valueForKey:@"unseen"] boolValue])
						[new_album setValue:@0 forKey:@"unseen"];
		
		// select and scroll to new object
		[artistArrayController fetchWithRequest:nil merge:NO error:&error];
		[artistArrayController setSelectedObjects:@[artist]];
		[artistsTableView scrollRowToVisible:artistArrayController.selectionIndex];
	}
	
	[self updateDockIcon];
}

- (void)updateArtist:(NSManagedObject *)artist
{
	NSDictionary *mb_releases = [Musicbrainz releasesForArtist:[artist valueForKey:@"id"]];
	NSMutableSet *local_releases = [artist valueForKey:@"releases"];
	
	
	for (NSString *mb_release_title in mb_releases)
	{
		NSEnumerator *local_release_enumerator = [local_releases objectEnumerator];
		NSArray *mb_release = mb_releases[mb_release_title];
		BOOL done = FALSE;
		
		// check if it is already matched to a local release
		for (NSManagedObject *local_release in local_release_enumerator)
		{
			if ([[local_release valueForKey:@"id"] isEqualToString:mb_release[0]])
			{
				done = TRUE;
				break;
			}
		}
		if (done) continue;
		
		// look for exact match and check fuzzy match candidates
		NSMutableArray *matchCandidates = [NSMutableArray arrayWithCapacity:local_releases.count];

		local_release_enumerator = [local_releases objectEnumerator];
		for (NSManagedObject *local_release in local_release_enumerator)
		{
			if (![[local_release valueForKey:@"owned"] boolValue] || [[local_release valueForKey:@"id"] length])
				continue;
				
			NSString *local_release_title = [local_release valueForKey:@"name"];
			
			
			if (([local_release_title caseInsensitiveCompare:mb_release_title] == NSOrderedSame) ||
				 ([[local_release_title stringByReplacingOccurrencesOfString:@" - " withString:@": "] caseInsensitiveCompare:mb_release_title] == NSOrderedSame))
			{
				//NSLog(@"%@ == %@" , title , [r valueForKey:@"name"]);			
				if ([mb_release[1] intValue] != 1900)
					[local_release setValue:mb_release[1] forKey:@"year"];
				[local_release setValue:mb_release[0] forKey:@"id"];
				done = TRUE;
				break;
			}
			else
			{
				float dist = MIN([local_release_title compareWithString:mb_release_title],
								 [[local_release_title stringByReplacingOccurrencesOfString:@" - " withString:@": "] compareWithString:mb_release_title]); 
				
				[matchCandidates addObject:@{@"managedObject": local_release, @"dist": @(dist)}];
			}
		}
		
		if (done) continue;

		[matchCandidates sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"dist" ascending:YES]]];
		for (NSDictionary *dict in matchCandidates)
		{
			float dist = [dict[@"dist"] floatValue];
			NSManagedObject *match = dict[@"managedObject"];
			
			if (dist < 5 && ((float) MIN([mb_release_title length], [[match valueForKey:@"name"] length]) / dist >= 4))
			{
				NSLog(@" Warning: proposing match with distance %f %@ != %@", dist, mb_release_title , [match valueForKey:@"name"]); // TODO: remove logs
				
                if (NSRunAlertPanel(@"MusicWatch", @"%@", [NSString stringWithFormat:@"Please help MusicWatch match albumnames. Are these two (different) names for the same album?\n%@\n%@", mb_release_title, [match valueForKey:@"name"]], @"Same album", @"Not the same album", nil) == NSAlertDefaultReturn) 
				{
					[match setValue:mb_release[1] forKey:@"year"];
					[match setValue:mb_release[0] forKey:@"id"];
					done = TRUE;
				}	
			}	
			if (done) break;
		}
		
		if (done) continue;
		
		// if no match can be found add as a new release
		NSManagedObject *album = [NSEntityDescription
								  insertNewObjectForEntityForName:@"Release"
								  inManagedObjectContext: managedObjectContext];
		
		[album setValue:mb_release_title forKey:@"name"];
		[album setValue:mb_release[1] forKey:@"year"];
		
		[album setValue:@NO forKey:@"owned"];
		[album setValue:@1 forKey:@"unseen"];
		[album setValue:artist forKey:@"artist"];
		[album setValue:mb_release[0] forKey:@"id"];
		
		NSMutableSet *releases = [NSMutableSet setWithSet:[artist valueForKey:@"releases"]];
		[releases addObject:album];
		[artist setValue:releases forKey:@"releases"];
	}
}

- (void)updateDockIcon
{
	int unseen = 0;
	NSError *error;
	
	[artistArrayController fetchWithRequest:nil merge:NO error:&error];
	
	for (NSManagedObject *artist in artistArrayController.arrangedObjects)
		unseen += [[artist valueForKeyPath:@"releases.@sum.unseen"] intValue];

	NSApp.dockTile.badgeLabel = [NSString stringWithFormat:@"%i", unseen];
}

- (IBAction)matchSheetAction:(id)sender
{
    [NSApp endSheet:matchSheet];
    [matchSheet orderOut:self];
	
	if ([[sender title] isEqualToString:@"Match"])
	{
		NSManagedObject *o2 = matchTableDataSource.matchAlbumArray[matchTableView.selectedRow];
		NSManagedObject *o1 = releaseArrayController.selection;
		
		[o1 setValue:[o2 valueForKey:@"id"] forKey:@"id"];
		
		[releaseArrayController removeObject:o2];
	}
}

#pragma mark *** NSTableDataSource protocol-methods ***

- (NSDragOperation)tableView:(NSTableView *)tv
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op
{
	[tv setDropRow:row dropOperation:NSTableViewDropAbove];
	
	return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tv
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op
{
	NSArray *classArray = @[[NSURL class]]; // types of objects you are looking for
	NSDictionary *options = @{NSPasteboardURLReadingFileURLsOnlyKey: @YES};
	NSArray *arrayOfURLs = [[info draggingPasteboard] readObjectsForClasses:classArray options:options]; // read objects of those classes

	// Can we get an URL?  If so, add a new row, configure it, then return.
	if (arrayOfURLs.count)
	{
		[self addFolders:arrayOfURLs];
		
		return YES;
	}
	
	return NO;
}



#pragma mark GENERATED CODE

/*************************************************************
 **********				GENERATED CODE				**********
 *************************************************************/



/**
 Returns the support directory for the application, used to store the Core Data
 store file.  This code uses a directory named "MusicWatch" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = (paths.count > 0) ? paths[0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"MusicWatch"];
}


/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The directory for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
												  configuration:nil 
															URL:url 
														options:nil 
														  error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release];
        persistentStoreCoordinator = nil;
        return nil;
    }    
	
    return persistentStoreCoordinator;
}

/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    managedObjectContext.persistentStoreCoordinator = coordinator;
	
    return managedObjectContext;
}

/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [self managedObjectContext].undoManager;
}


/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.  Any encountered errors
 are presented to the user.
 */

- (IBAction) saveAction:(id)sender {
	
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
	
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
 Implementation of the applicationShouldTerminate: method, used here to
 handle the saving of changes in the application managed object context
 before the application terminates.
 */

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	
    if (!managedObjectContext) return NSTerminateNow;
	
    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
	
    if (!managedObjectContext.hasChanges) return NSTerminateNow;
	
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
		
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.
		
        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
		
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;
		
        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = question;
        alert.informativeText = info;
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
		
        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;
		
    }
	
    return NSTerminateNow;
}


/**
 Implementation of dealloc, to release the retained variables.
 */

- (void)dealloc {
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
	
    [super dealloc];
}

@end
