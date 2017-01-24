//
//  MazeViewLayer.m
//  FingerMaze
//
//  Created by CoreCode on 07.09.10.
/*	Copyright © 2017 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "MazeViewLayer.h"
#import "Maze.h"
#import "Preferences.h"

extern Maze *maze;
extern Preferences *prefs;
extern CGImageRef door;


@implementation MazeViewLayer


- (void)drawInContext:(CGContextRef)context
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"TextureBackgrounds"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"ColorBackgrounds"])
	{
		if (RandomFloatBetween(0,2) > 1)
			DrawRandomTexture(context);
		else
			DrawRandomColor(context);
	}
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"TextureBackgrounds"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"ColorBackgrounds"])
		DrawRandomTexture(context);		
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"TextureBackgrounds"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"ColorBackgrounds"])
		DrawRandomColor(context);
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"TextureBackgrounds"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"ColorBackgrounds"])
        DrawColor(context, 0.667, 0.667, 0.667);

	
	// border
	CGContextSetRGBStrokeColor(context, 0.9, 0.9, 0.9, 1.0);
	CGContextSetLineWidth(context, BORDER);
	CGContextSetLineJoin(context, kCGLineJoinMiter);
	

	
	CGContextMoveToPoint(context, BORDER/2, 100.0);															// start
	CGContextAddLineToPoint(context, BORDER/2, BORDER/2);													// top left
	CGContextAddLineToPoint(context, BORDER/2 + [maze end] * kTilesizeX + BORDER/2, BORDER/2);			// top inset-start
	CGContextMoveToPoint(context, BORDER/2 + ([maze end]+1) * kTilesizeX  + BORDER/2, BORDER/2);			// top inset-end
	CGContextAddLineToPoint(context, MAZE_W - BORDER/2, BORDER/2);											// top right
	CGContextAddLineToPoint(context, MAZE_W - BORDER/2, MAZE_H - BORDER/2);									// bottom right
	CGContextAddLineToPoint(context, BORDER/2 + ([maze start]+1) * kTilesizeX  + BORDER/2, MAZE_H - BORDER/2);// bottom inset-start
	CGContextMoveToPoint(context, BORDER/2 + ([maze start]) * kTilesizeX  + BORDER/2, MAZE_H - BORDER/2);		// bottom inset-end
	CGContextAddLineToPoint(context, BORDER/2, MAZE_H - BORDER/2);											// bottom left
	CGContextAddLineToPoint(context, BORDER/2, 100.0);														// end
	CGContextStrokePath(context);
	
	
	// walls
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextSetLineWidth(context, 3.0);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineJoin(context, kCGLineJoinRound);

	for (uint8_t x = 0; x < kMaxX; x++)
	{
		for (uint8_t y = 0; y < kMaxY; y++)
		{
			uint8_t tile = [maze wallsForTileX:x Y:y];
			
			if (x == [maze end] && y == 0)
				tile &= ~kWallAbove;
			else if (x == [maze start] && y == kMaxY - 1)
				tile &= ~kWallBelow;
	 
			if (tile & kWallAbove)
			{
				CGContextMoveToPoint(context,
									 BORDER + x * kTilesizeX,
									 BORDER + y * kTilesizeY);
				CGContextAddLineToPoint(context,	
										BORDER + (x+1) * kTilesizeX,
										BORDER + y * kTilesizeY);
			}
			if (tile & kWallBelow)
			{
				CGContextMoveToPoint(context,		
									 BORDER + x * kTilesizeX,
									 BORDER + (y+1) * kTilesizeY);
				CGContextAddLineToPoint(context,
										BORDER + (x+1) * kTilesizeX,
										BORDER + (y+1) * kTilesizeY);
			}
			if (tile & kWallLeft)
			{
				CGContextMoveToPoint(context,	
									 BORDER + x * kTilesizeX,
									 BORDER + y * kTilesizeY);
				CGContextAddLineToPoint(context,
										BORDER + x * kTilesizeX,
										BORDER + (y+1) * kTilesizeY);
			}
			if (tile & kWallRight)
			{
				CGContextMoveToPoint(context,
									 BORDER + (x+1) * kTilesizeX,
									 BORDER + y * kTilesizeY);
				CGContextAddLineToPoint(context,
										BORDER + (x+1) * kTilesizeX,
										BORDER + (y+1) * kTilesizeY);
			}
		}
	}
	
	CGContextSetLineCap(context, kCGLineCapButt);

	
	CGContextMoveToPoint(context, BORDER + [maze end] * kTilesizeX, 0);
	CGContextAddLineToPoint(context, BORDER + [maze end] * kTilesizeX, BORDER);
	CGContextMoveToPoint(context, BORDER + ([maze end]+1) * kTilesizeX, 0);
	CGContextAddLineToPoint(context, BORDER + ([maze end]+1) * kTilesizeX, BORDER);
	
	
	CGContextMoveToPoint(context, BORDER + ([maze start]+1) * kTilesizeX, MAZE_H - BORDER);
	CGContextAddLineToPoint(context, BORDER + ([maze start]+1) * kTilesizeX, MAZE_H -1);
	CGContextAddLineToPoint(context, BORDER + [maze start] * kTilesizeX, MAZE_H -1);
	CGContextAddLineToPoint(context, BORDER + [maze start] * kTilesizeX, MAZE_H - BORDER);

	CGContextStrokePath(context);
	
	
	CGContextTranslateCTM(context, BORDER + [maze end] * kTilesizeX + 4, BORDER + BORDER / 2.0 + 19 - 4);
	CGContextScaleCTM(context, 1.0, -1.0);

	CGContextDrawImage(context, CGRectMake(0, 0, 15, 19), door); 

	
	// start end border removal
//	CGContextSetLineWidth(context, BORDER + 2);
//	
//	CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
//	
//	CGContextMoveToPoint(context, BORDER+1 + [maze start] * kTilesizeX, BORDER/2+1);
//	CGContextAddLineToPoint(context, BORDER+1 + ([maze start]+1) * kTilesizeX - 2, BORDER/2+1);
//	CGContextStrokePath(context);
//	
//	CGContextMoveToPoint(context,		BORDER+1 + [maze end] * kTilesizeX,
//						 MAZE_H - BORDER/2);
//	CGContextAddLineToPoint(context,	BORDER+1 + ([maze end]+1) * kTilesizeX - 2,
//							MAZE_H - BORDER/2);
//	CGContextStrokePath(context);
	
}


@end

// ######################################################################
// T. Nathan Mundhenk
// mundhenk@usc.edu
// C/C++ Macro HSV to RGB
#define PIX_HSV_TO_RGB_COMMON(H,S,V,R,G,B)                          \
if( V == 0 )                                                        \
{ R = 0; G = 0; B = 0; }                                            \
else if( S == 0 )                                                   \
{                                                                   \
R = V;                                                            \
G = V;                                                            \
B = V;                                                            \
}                                                                   \
else                                                                \
{                                                                   \
const double hf = H / 60.0;                                       \
const int    i  = (int) floor( hf );                              \
const double f  = hf - i;                                         \
const double pv  = V * ( 1 - S );                                 \
const double qv  = V * ( 1 - S * f );                             \
const double tv  = V * ( 1 - S * ( 1 - f ) );                     \
switch( i )                                                       \
{                                                               \
case 0:                                                         \
R = V;                                                        \
G = tv;                                                       \
B = pv;                                                       \
break;                                                        \
case 1:                                                         \
R = qv;                                                       \
G = V;                                                        \
B = pv;                                                       \
break;                                                        \
case 2:                                                         \
R = pv;                                                       \
G = V;                                                        \
B = tv;                                                       \
break;                                                        \
case 3:                                                         \
R = pv;                                                       \
G = qv;                                                       \
B = V;                                                        \
break;                                                        \
case 4:                                                         \
R = tv;                                                       \
G = pv;                                                       \
B = V;                                                        \
break;                                                        \
case 5:                                                         \
R = V;                                                        \
G = pv;                                                       \
B = qv;                                                       \
break;                                                        \
case 6:                                                         \
R = V;                                                        \
G = tv;                                                       \
B = pv;                                                       \
break;                                                        \
case -1:                                                        \
R = V;                                                        \
G = pv;                                                       \
B = qv;                                                       \
break;                                                        \
default:                                                        \
printf("i Value error in Pixel conversion, Value is %d",i);   \
break;                                                        \
}                                                               \
}                                                                  

void DrawRandomTexture(CGContextRef ctx)
{
	
	NSArray *images = [NSArray arrayWithObjects:@"3662885547_28d97fd3e7_o.jpg", @"3682831943_d5a673164e_o.jpg", @"3682834083_4f447d0e1a_o.jpg", @"4099286175_620a6626ff_o.jpg", @"4116781768_a23d7d7a4b_o.jpg", @"4136560028_c94c19bcbe_o.jpg", @"4182516039_cc692c3bd2_o.jpg", @"4183270344_2b954bcc54_o.jpg", @"4237813767_fa11c7ec4f_o.jpg", @"4278406515_daf2d8b856_o.jpg", @"4285313100_1e36207d7e_o.jpg", @"4426535173_08f7ec560e_o.jpg", @"4441454031_7772f8351e_o.jpg", @"4498648030_b252e20795_o.jpg", @"4553543798_f21fb77613_o.jpg", @"4568890603_a0720aef99_o.jpg", @"4619713941_4348bb11f3_o.jpg", @"4643168211_2cf9b07d23_o.jpg", @"4913562237_e589a308f1_o.jpg", @"5377113752_62621b9539_o.jpg", @"5638628181_36c9018e73_o.jpg", @"5800948143_8844409e58_o.jpg", @"5457829872_2e67163a21_b.jpg", nil];
	UIImage *image = [UIImage imageNamed:[images objectAtIndex:RandomIntBetween(0, [images count]-1)]];
	CGRect image_rect = CGRectMake(0, 0, 500, 500);
	
	CGContextSetAlpha(ctx, 0.5); 
	CGContextDrawTiledImage(ctx, image_rect, image.CGImage); 
	CGContextSetAlpha(ctx, 1.0);
}

void DrawRandomColor(CGContextRef ctx)
{
	if (RandomFloatBetween(0, 2) > 1)
	{
		CGFloat red = 0.0;
		CGFloat green = 0.0;
		CGFloat blue = 0.0;
		
		PIX_HSV_TO_RGB_COMMON(RandomFloatBetween(0.0,360.0),0.3,0.5, red, green, blue)
		
		
		DrawColor(ctx, red, green, blue);
	}
	else
	{
		int random = RandomIntBetween(0, 6);
		switch (random)
		{
			case 0:
				DrawColor(ctx,0.239, 0.416, 0.341); //greenblue
				break;
			case 1:
				DrawColor(ctx,0.153, 0.365, 0.412); // bluegreen
				break;
			case 2:
				DrawColor(ctx,0.329, 0.314, 0.412); // lila
				break;
			case 3:
				DrawColor(ctx,0.412, 0.271, 0.318); // pinkishred
				break;
			case 4:
				DrawColor(ctx,0.471, 0.325, 0.247); // orange
				break;
			case 5:
				DrawColor(ctx,0.471, 0.467, 0.208); // yellowish
				break;
			case 6:
				DrawColor(ctx,0.345, 0.498, 0.314); // greenish
				break;
		}
		
	}
}

void DrawColor(CGContextRef ctx, CGFloat red, CGFloat green, CGFloat blue)
{
	CGContextSetRGBFillColor(ctx, red,green,blue,1.0);
    CGContextFillRect(ctx, CGRectMake(0, 0, MAZE_W, MAZE_H));
}
