//
//  DocumentController.m
//  Phorgiveness
//
/*	Copyright (c) 2002 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "DocumentController.h"

@implementation DocumentController

SavedData sData;
size_t 	filesize;
char	*filebuffer;
long 	datalocation;
int 	currentitem [4] = {0, 0, 0, 0};
int 	powerups [4] = {7, 8, 9, 10};
int 	weapons [8] = {16, 18, 20, 23, 28, 30, 37, 49};
int 	ammunition [9] = {17, 19, 21, 22, 24, 29, 31, 38, 50};
int 	items [2] = {39, 40};

- (IBAction)EnergyOxygenSet:(id)sender
{
	[self updateChangeCount:NSChangeDone];
}

- (IBAction)PowerupsTFSet:(id)sender
{
	printf("PowerupsTFSet\n");
	printf("[PowerupsPU indexOfSelectedItem] %li \n",(long)[PowerupsPU indexOfSelectedItem]);
	printf("sData.items[powerups[[PowerupsPU indexOfSelectedItem]]] %i \n", sData.items[powerups[[PowerupsPU indexOfSelectedItem]]]);
	printf("[sender intValue] %i \n", [sender intValue]);

	if (sData.items[powerups[[PowerupsPU indexOfSelectedItem]]] != [sender intValue])
	{
		sData.items[powerups[[PowerupsPU indexOfSelectedItem]]] = [sender intValue];
		[self updateChangeCount:NSChangeDone];
		printf("CHANGED\n");
	}
	else
		printf("NOTCHANGED\n");
}

- (IBAction)PowerupsPUSelect:(id)sender
{
	printf("PowerupsPUSelect\n");
	printf("currentitem[0] %i \n", currentitem[0]);
	printf("sData.items[powerups[currentitem[0]]] %i \n", sData.items[powerups[currentitem[0]]]);
	printf("[PowerupsTF intValue] %i \n", [PowerupsTF intValue]);

	if (sData.items[powerups[currentitem[0]]] != [PowerupsTF intValue])
	{
		sData.items[powerups[currentitem[0]]] = [PowerupsTF intValue];
		[self updateChangeCount:NSChangeDone];
		printf("CHANGED\n");
	}
	else
		printf("NOTCHANGED\n");
	
	[PowerupsTF setIntValue:sData.items[powerups[[sender indexOfSelectedItem]]]];

	currentitem[0] = [sender indexOfSelectedItem];
}

- (IBAction)WeaponsTFSet:(id)sender
{
	if (sData.items[weapons[[WeaponsPU indexOfSelectedItem]]] != [sender intValue])
	{
		sData.items[weapons[[WeaponsPU indexOfSelectedItem]]] = [sender intValue];
		[self updateChangeCount:NSChangeDone];
	}
}

- (IBAction)WeaponsPUSelect:(id)sender
{
	if (sData.items[weapons[currentitem[1]]] != [WeaponsTF intValue])
	{
		sData.items[weapons[currentitem[1]]] = [WeaponsTF intValue];
		[self updateChangeCount:NSChangeDone];
	}
	
	[WeaponsTF setIntValue:sData.items[weapons[[sender indexOfSelectedItem]]]];

	currentitem[1] = [sender indexOfSelectedItem];
}

- (IBAction)AmmunitionTFSet:(id)sender
{
	if (sData.items[ammunition[[AmmunitionPU indexOfSelectedItem]]] != [sender intValue])
	{
		sData.items[ammunition[[AmmunitionPU indexOfSelectedItem]]] = [sender intValue];
		[self updateChangeCount:NSChangeDone];
	}
}

- (IBAction)AmmunitionPUSelect:(id)sender
{
	if (sData.items[ammunition[currentitem[2]]] != [AmmunitionTF intValue])
	{
		sData.items[ammunition[currentitem[2]]] = [AmmunitionTF intValue];
		[self updateChangeCount:NSChangeDone];
	}
	
	[AmmunitionTF setIntValue:sData.items[ammunition[[sender indexOfSelectedItem]]]];

	currentitem[2] = [sender indexOfSelectedItem];
}

- (IBAction)ItemsTFSet:(id)sender
{
	if (sData.items[items[[ItemsPU indexOfSelectedItem]]] != [sender intValue])
	{
		sData.items[items[[ItemsPU indexOfSelectedItem]]] = [sender intValue];
		[self updateChangeCount:NSChangeDone];
	}
}

- (IBAction)ItemsPUSelect:(id)sender
{
	if (sData.items[items[currentitem[3]]] != [ItemsTF intValue])
	{
		sData.items[items[currentitem[3]]] = [ItemsTF intValue];
		[self updateChangeCount:NSChangeDone];
	}
	
	[ItemsTF setIntValue:sData.items[items[[sender indexOfSelectedItem]]]];

	currentitem[3] = [sender indexOfSelectedItem];
}

- (long)FindDataLocation:(char *)buffer bufferSize:(long)bsize
{
	long lpcnt;
	
	bsize -= 4;
	
	for (lpcnt = 0; lpcnt < bsize; lpcnt++)
	{
		if (buffer[lpcnt] == 'p')
		{
			lpcnt++;
			if (buffer[lpcnt] == 'l')
			{
				lpcnt++;
				if (buffer[lpcnt] == 'y')
				{
					lpcnt++;
					if (buffer[lpcnt] == 'r')
					{
						return lpcnt+9;
					}
				}
			}
		}
	}
	
	return -1;
}

#pragma mark *** NSDocument subclass-methods ***

- (NSString *)windowNibName
{
	return @"DocumentController";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];

	[EnergyTF setIntValue:sData.items[0]];
	[OxygenTF setIntValue:sData.items[1]];

	[PowerupsTF setIntValue:sData.items[powerups[0]]];
	[AmmunitionTF setIntValue:sData.items[ammunition[0]]];
	[WeaponsTF setIntValue:sData.items[weapons[0]]];
	[ItemsTF setIntValue:sData.items[items[0]]];
}

- (BOOL)writeToFile:(NSString *)fileName ofType:(NSString *)type
{
	FILE *fp;
	int itemswritten;

	printf("%s", [fileName UTF8String]);
	printf("%s", [type UTF8String]);

	sData.items[0] = [EnergyTF intValue];
	sData.items[1] = [OxygenTF intValue];
	sData.items[powerups[[PowerupsPU indexOfSelectedItem]]] = [PowerupsTF intValue];
	sData.items[weapons[[WeaponsPU indexOfSelectedItem]]] = [WeaponsTF intValue];
	sData.items[ammunition[[AmmunitionPU indexOfSelectedItem]]] = [AmmunitionPU intValue];
	sData.items[items[[ItemsPU indexOfSelectedItem]]] = [ItemsPU intValue];

	if ((fp = fopen([fileName cString],"w+b")) == NULL)
	{
		printf("cannot create target file\n, errno %i", errno);
		exit(1);
	}

	memcpy(filebuffer + datalocation, &sData, sizeof(SavedData));
	itemswritten = fwrite(filebuffer, filesize, 1, fp);

	if (itemswritten != 1)
	{
		printf("no item written");
		exit(1);
	}

	fclose(fp);
	return YES;
}

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType
{
	FILE *fp;
	int i;

	printf("%s", [fileName cString]);
	filebuffer = (char *) malloc(1024 * 1024);

	if ((fp = fopen([fileName cString], "rb")) == NULL)
	{
		printf("cannot open file\n");
		exit(1);
	}

	filesize = fread(filebuffer, 1, 1024 * 1024, fp);

    datalocation = [self FindDataLocation:filebuffer bufferSize:filesize];
	datalocation += 68;
	memcpy(&sData, filebuffer + datalocation, sizeof(SavedData));

	for (i = 0; i < 80; i++)
		printf("item %i is %i\n", i, sData.items[i]);

	fclose(fp);
	return YES;
}

- (NSDictionary *)fileAttributesToWriteToFile:(NSString *)fullDocumentPath ofType:(NSString *)documentTypeName saveOperation:(NSSaveOperationType)saveOperationType
{
	NSMutableDictionary	*dict = [NSMutableDictionary dictionaryWithDictionary: [super fileAttributesToWriteToFile:fullDocumentPath ofType:documentTypeName saveOperation:saveOperationType]];

	[dict setObject:[NSNumber numberWithUnsignedLong:'sga\xA1'] forKey:NSFileHFSTypeCode];
	[dict setObject:[NSNumber numberWithUnsignedLong:'26.A'] forKey:NSFileHFSCreatorCode];

	return dict;
}
@end

@implementation Phorgiveness

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)app
{
	return NO;
}
@end

int main(int argc, const char *argv[])
{
	return NSApplicationMain(argc, argv);
}
