#include <ApplicationServices/ApplicationServices.h>

// this function was posted to http://www.cocoadev.com/index.pl?ChoosingMainDisplay
// the license is not mentioned but it is presumably permissive or even public domain
// note that the code was adapted
void switchDisplays()
{
	CGDirectDisplayID activeDisplays[32];
	CGDisplayErr err;
	CGDisplayCount displayCount;
	CGDisplayConfigRef config;
	
	err = CGGetActiveDisplayList(32, activeDisplays, &displayCount);
	if ( err != kCGErrorSuccess )
	{
		printf("Err: CGGetActiveDisplayList(%d)\n", err);
		exit(1);
	}
	
	if (displayCount > 1)
	{
		err = CGBeginDisplayConfiguration(&config);
		if ( err != kCGErrorSuccess )
		{
			printf("Err: CGBeginDisplayConfiguration(%d)\n", err);
			exit(1);
		}
		
		
		err = CGConfigureDisplayOrigin(config,activeDisplays[1], 0, 0);											// set the second display as the new main display by positioning at 0,0
		if ( err != kCGErrorSuccess )
		{
			printf("Err: CGConfigureDisplayOrigin(%d)\n", err);
			exit(1);
		}
		
		err = CGConfigureDisplayOrigin(config,activeDisplays[0], CGDisplayPixelsWide(activeDisplays[1])+1, 0);	// arrangement of the old main display to the right of the new main display
		if ( err != kCGErrorSuccess )
		{
			printf("Err: CGConfigureDisplayOrigin(%d)\n", err);
			exit(1);
		}
		
		err = CGCompleteDisplayConfiguration(config,kCGConfigureForSession);
		if ( err != kCGErrorSuccess )
		{
			printf("Err: CGCompleteDisplayConfiguration(%d)\n", err);
			exit(1);
		}
	}
	else
		printf("Warning: only 1 display\n");	
}

// this function was written by "Ian McCall" and posted to news://comp.sys.mac.programmer.help
// the license is not mentioned but it is presumably permissive or even public domain
//int mirrorDisplays(int mirroringOn)
//{	
//	int i;
//	CGDirectDisplayID   activeDisplays[32];
//	CGDisplayCount      displayCount;
//	CGDisplayConfigRef  configRef;
//	CGDisplayErr        result;
//	CGDirectDisplayID   mainDisplayID   = CGMainDisplayID();
//	
//	CGBeginDisplayConfiguration(&configRef);
//	
//	result = CGGetOnlineDisplayList(32, activeDisplays, &displayCount);
//	
//	if(result != CGDisplayNoErr)
//	{
//		fprintf(stderr, "Error getting Active Display List: %d\n", result);
//		exit(1);
//	}
//
//	CGDirectDisplayID mirrorMaster = (mirroringOn ? mainDisplayID : kCGNullDirectDisplay);
//	
//	for(i = 0; i < displayCount; i++)
//	{
//		if(activeDisplays[i] != mainDisplayID)
//		{
//			result = CGConfigureDisplayMirrorOfDisplay(configRef, activeDisplays[i], mirrorMaster);
//			
//			if(result != CGDisplayNoErr)
//			{
//				fprintf(stderr, "Error configuring display id %d, result = %d\n", activeDisplays[i], result);
//				exit(1);
//			}
//		}
//	}
//}