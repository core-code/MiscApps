#import "FileUtilities.h"

OSErr MakeRelativeAliasFile(FSSpec *targetFile, FSSpec *aliasDest);

@implementation FileUtilities

// this function was written by "Alan Pinstein" and posted to www.cocoadev.com
// the license is not mentioned but it is presumably permissive or even public domain
// note that the code was adapted
+ (OSErr)makeRelativeAlias:(NSString *)aliasDestination toFile:(NSString *)targetFile
{
    
    FSSpec fsSpec1, fspecNewFile, fspecParentDir;
    OSErr err;
    OSStatus        res;    
    FSRef fsRef1, frefParentDir;
    
    err = [FileUtilities getFSRefAtPath:targetFile ref:&fsRef1];
    if (err != noErr)
        return err;
    
    err = FSGetCatalogInfo(&fsRef1, kFSCatInfoNone, NULL, NULL, &fsSpec1, NULL);
    if (err != noErr)
        return err;    
    
    // SAVE
    // create FSpec for the NEW file, without actually CREATING the new file..
    // get FSRef to parent - dirPath is a NSString containing "/path/to/enclosing/dir/for/newfile
    res = FSPathMakeRef ((const UInt8 *)[[aliasDestination stringByDeletingLastPathComponent] fileSystemRepresentation],&frefParentDir, NULL);
    NSAssert(res == 0, @"Creating ref to enclosing dir failed.");
    
    err = FSGetCatalogInfo (&frefParentDir, kFSCatInfoNone, NULL, NULL, &fspecParentDir, NULL); 
	
    NSAssert1(err == 0, @"Converting to FSSpec failed: (%i)", err);
	
    // get dirID of the parent Directory (since the fspec only has the dir's PARENT dirID)
	CInfoPBRec pb;
    bzero(&pb, sizeof(pb));
    pb.dirInfo.ioFDirIndex = 0; // get info about the DIR with the NAME and PARENT specified
    pb.dirInfo.ioNamePtr = fspecParentDir.name;
    pb.dirInfo.ioDrDirID = fspecParentDir.parID;
	
    err = PBGetCatInfoSync(&pb);
    NSAssert(err == 0, @"Error getting catalog info.");        
	
    // need a name for this string. it's not important, as DecodeMacBinary will REPLACE this name with the proper one.
    Str255  tmpStr;
	/* bzero(&tmpStr, sizeof(tmpStr));
    tmpStr[0] = 1;
    tmpStr[1] = 's';*/
    if (!CFStringGetPascalString((CFStringRef) [aliasDestination lastPathComponent], (StringPtr) &tmpStr, 255, kCFStringEncodingNonLossyASCII))
        return 1;
    
    bzero(&fspecNewFile, sizeof(fspecNewFile));
    
    err = FSMakeFSSpec (fspecParentDir.vRefNum, pb.dirInfo.ioDrDirID, tmpStr, &fspecNewFile);
    NSAssert1(err == 0 || err == fnfErr, @"Creating FSSpec failed: (%i)", err);
    
    return MakeRelativeAliasFile(&fsSpec1, &fspecNewFile);
}

// this function was written by "Lorenzo Puleo", posted to cocoa-dev@lists.apple.com, modified by "zootbobbalu" and  posted to www.cocoadev.com
// the license is not mentioned but it is presumably permissive or even public domain
+ (OSErr)getFSRefAtPath:(NSString *)sourceItem ref:(FSRef *)sourceRef
{
    OSErr    err;
    BOOL    isSymLink;
    id manager = [NSFileManager defaultManager];
    NSDictionary *sourceAttribute = [manager fileAttributesAtPath:sourceItem
                                                     traverseLink:NO];
    isSymLink = ([sourceAttribute objectForKey:@"NSFileType"] == NSFileTypeSymbolicLink);
    
	if(isSymLink)
	{
		const UInt8 *sourceParentPath;
        FSRef        sourceParentRef;
        HFSUniStr255    sourceFileName;
        
        sourceParentPath = (UInt8*)[[sourceItem stringByDeletingLastPathComponent] fileSystemRepresentation];
        err = FSPathMakeRef(sourceParentPath, &sourceParentRef, NULL);
        if(err == noErr){
            [[sourceItem lastPathComponent]
getCharacters:sourceFileName.unicode];
            sourceFileName.length = [[sourceItem lastPathComponent] length];
            if (sourceFileName.length == 0){
                err = fnfErr;
            }
            else err = FSMakeFSRefUnicode(&sourceParentRef,
                                          sourceFileName.length, sourceFileName.unicode, kTextEncodingFullName,
                                          sourceRef);
        }
    }
    else
        err =  FSPathMakeRef((const UInt8 *)[sourceItem fileSystemRepresentation], sourceRef, NULL);    
	
    return err;
}

@end

// this function was written by "Apple", and published in their Technical Note TN1188
// the license is not mentioned but it is presumably permissive or even public domain
/* MakeRelativeAliasFile creates a new alias file located at
aliasDest referring to the targetFile.  relative path
information is stored in the new file. */
OSErr MakeRelativeAliasFile(FSSpec *targetFile, FSSpec *aliasDest) {
    FInfo fndrInfo;
    AliasHandle theAlias;
    Boolean fileCreated;
    short rsrc;
    OSErr err;
    /* set up locals */
    theAlias = NULL;
    fileCreated = false;
    rsrc = -1;
    /* set up our the alias' file information */
    err = FSpGetFInfo(targetFile, &fndrInfo);
    if (err != noErr) goto bail;
    if (fndrInfo.fdType == 'APPL')
        fndrInfo.fdType = kApplicationAliasType;
    fndrInfo.fdFlags = kIsAlias; /* implicitly clear the inited bit */
    /* create the new file */
    FSpCreateResFile(aliasDest, 'TEMP', 'TEMP', smSystemScript);
    if ((err = ResError()) != noErr) goto bail;
    fileCreated = true;
    /* set the file information or the new file */
    err = FSpSetFInfo(aliasDest, &fndrInfo);
    if (err != noErr) goto bail;
    /* create the alias record, relative to the new alias file */
    err = NewAlias(aliasDest, targetFile, &theAlias);
    if (err != noErr) goto bail;
    /* save the resource */
    rsrc = FSpOpenResFile(aliasDest, fsRdWrPerm);
    if (rsrc == -1) { err = ResError(); goto bail; }
    UseResFile(rsrc);
    AddResource((Handle) theAlias, rAliasType, 0, aliasDest->name);
    if ((err = ResError()) != noErr) goto bail;
    theAlias = NULL;
    CloseResFile(rsrc);
    rsrc = -1;
    if ((err = ResError()) != noErr) goto bail;
    /* done */
    return noErr;
bail:
        if (rsrc != -1) CloseResFile(rsrc);
    if (fileCreated) FSpDelete(aliasDest);
    if (theAlias != NULL) DisposeHandle((Handle) theAlias);
    return err;
}