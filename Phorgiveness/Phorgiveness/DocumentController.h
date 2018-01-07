//
//  DocumentController.h
//  Phorgiveness
//
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Cocoa/Cocoa.h>

typedef struct
{
	short items[80];
} SavedData;

enum
{
	invisibility_duration = 0,
	invincibility_duration,
	infravision_duration,
	extravision_duration
};

enum
{
	magnum = 0,
	fusion,
	assault,
	launcher,
	alien,
	napalm,
	shotgun,
	flechette
};

enum
{
	m_clips = 0,
	batteries,
	a_clips,
	a_grenades,
	missiles,
	ammo,
	canisters,
	shells,
	magazines
};

enum
{
	converter = 0,
	repairchip
};

@interface DocumentController : NSDocument
{
	id 	EnergyTF,
		OxygenTF,

		ItemsTF,
		ItemsPU,

		WeaponsTF,
		WeaponsPU,

		AmmunitionTF,
		AmmunitionPU,

		PowerupsTF,
		PowerupsPU;
}

- (IBAction)EnergyOxygenSet:(id)sender;

- (IBAction)PowerupsPUSelect:(id)sender;
- (IBAction)PowerupsTFSet:(id)sender;

- (IBAction)WeaponsPUSelect:(id)sender;
- (IBAction)WeaponsTFSet:(id)sender;

- (IBAction)AmmunitionPUSelect:(id)sender;
- (IBAction)AmmunitionTFSet:(id)sender;

- (IBAction)ItemsPUSelect:(id)sender;
- (IBAction)ItemsTFSet:(id)sender;

- (long)FindDataLocation:(char *)buffer bufferSize:(long)bsize;
@end

@interface Phorgiveness : NSObject
{
}
@end