
# IMPORTANT NOTE:
## For legal reasons this download doesn't contain a pre-built executable binary of iRipDVD.
## If you just want a working DVD-ripper please look elsewhere (http://handbrake.m0k.org/).
## The source code is provided for academic/historical interest, but again the most important part the mplayer/mencoder engine is missing for legal reasons.
## In case you want to compile iRipDVD and are legally entitled to do so (i.e. living outside the USA/EU) you may have luck obtaining a working mplayer/mencoder engine at this link:
[1]: http://prdownloads.sourceforge.net/mplayerosx/lastbinary.sit?download


# iRipDVD
*v1.0b8*

## Introduction:
iRipDVD is an application for converting Video-DVDs to high-quality MPEG4 video files.
iRipDVD can "rip" either directly from DVD or from VOB-files to MPEG4s (DivX5 compatible, MP3 ABR audio track) using the excellent [mplayer/mencoder encoding engine][1]. 

## WARNING:
This application is in early development state and therefore features are missing and problems do exist.
This application is completely unsupported - USE AT YOUR OWN RISK.

## Requirements:
Mac OS X 10.2 or later (PowerPC only)
700 - 3200MB free disk space

## License &amp; Cost:
iRipDVD is completely free of charge and licensed under the [Open Source "MIT License"][2].

## Usage:
1.) Place the iRipDVD folder anywhere on your hard disk (the "/Applications" folder is most suitable).
2.) Double click iRipDVD.
3.) Select if you want to rip from your DVD drive or from a VOB-file on your hard disc. As high-quality encoding takes a lot of time you may want to rip your DVDs to VOB-files with a tool called OSEx if you have the DVDs just for a time-limited period or don't want to stress your DVD-drive.
4.) Select the language you want to rip (it has to be available on the DVD). If you encode a VOB file you should rip just the language you want from the DVD into the VOB-file with OSEx.
5.) Experiment with the right settings for audio-bit-rate, movie width and target size and make previews until you are satisfied with the results (no artifacts). If your target size is just one CD you may have to reduce the movie width to under 600 pixels and the audio-bit-rate to 96 kbps. Consult a movie-encoding tutorial if you don't know what these options mean. The video bit-rate is always automatically calculated from these options.
6.) Select if you want to encode a cartoon/anime movie or a normal one. For cartoon/anime you may be able to use much higher movie width without getting artifacts.
7.) Select if you want to encode in fast mode or in higher quality. Fast mode may only take a few hours, while quality mode can take more than one day (or two if you don't have a fast machine), but you'll see the difference in quality.
8.) Select if you just want to make a 15-seconds preview or encode the whole movie.
9.) Click "Convert".
10.) Select your source VOB file if you don't rip from DVD, and enter its duration in minutes.
11.) Select your movie destination. Consider that for 2-CD rips you will ned twice as much space because the movie has to be splitted (for 2 x 700 MB CDs you will need 4 x 700MB = 2.8GB free space).
12.) Wait... ;)

## Known Problems:
• DVDs that are "field-coded" either produce a "cropdetect" error or generate just a very small file instead of the movie. That is because of a limitation in mencoder (iRipDVD's MPEG4-engine) so i can't fix it. Luckily these DVDs are rare.
• To play Movies created with iRipDVD with QuickTime you have to use the DivX plugin (http://www.divx.com/divx/mac/). If you get an error from the QuickTime Player launch the DivX Decoder Configuration application and set "Use DivX Avi Importer".
• iRipDVD won't report any problems if there wasn't enough free space on the destination drive. The resulting movie will just be shorter than expected.
• iRipDVD may not properly encode DVDs which contain multiple episodes (instead of one long movie) if they are not all stored in the same "track". Try ripping all the episodes into one VOB-file with OSex.
…

## Todo List:
• optimize memory &amp; CPU usage
• customizable movie size
• error log file
• batch encoding for VOB-files
• options: manual crop / track / chapter / ...
• SMP-support
• support for encoding subtitles
• make "Aqua Interface Guidelines" compliant
…

## History:
**1.0b8**:
  • Removed the Binary, mplayer &amp; mencoder for legal reasons, so this now only server academic interest
  • Minimal changes to fit the re-release
**1.0b7**:
  • new mencoder/mplayer binaries (version 1.0pre1, should be faster ;)
  • done some optimizations to reduce CPU usage
  • fixed a bug when producing 2-CD movies
  • now packaged as a .DMG, because iRipDVD didn't work when expanded with Stuffit Expander 8.0
**1.0b6**:
  • should fix cropdetect/non-DTS-audio problems with last release (sorry compiled mplayer/mencoder with libdl-dependencies again)
  • now provides 3 different quality modes for those who like really fast (and bad) encodes. consider that even with the lowest quality setting encoding will be 3-pass and thus slower (but better) than 1- or 2-pass encodes.
**1.0b5**:
  • new mplayer/mencoder binaries (stable 0.91 release, should fix crashing on bad config-files)
  • you can now drag'n'drop VOB-files or DVD-Volumes onto iRipDVD
  • added preference option to auo-start encoding after getting a drag'n'drop event for a VOB/DVD (useful for scripting iRipDVD)
  • added preference option to quit after encoding (useful for scripting iRipDVD)
  • added (partial) japanese localization (thanks to Yoshiki Hiraki)
**1.0b4**:
  • support for encoding short VOB files, and making previews of VOB files (although you have to enter the total duration of the VOB-file in minutes)
  • use last used open/save directories
  • finds DVD if the DVD-volume-name has spaces in it's name
  • fixes for DVDs which contain DTS audio-tracks (rewritten language code detection routine)
**1.0b3**:
  • fast mode (worse quality)
  • compiled more stable mplayer/mencoder binaries (with gcc 3.3)
  • better DVD-drive detection (works if other volumes like CDs or Disk Images are mounted)
  • use standard language code number if selected one isn't found
**1.0b2**:
  • compiled new mplayer/mencoder binaries (with gcc 3.3) which don't depend on libdl
**1.0b1**:
  • Initial public release

[2]: http://www.mplayerhq.hu/
[3]: https://opensource.org/licenses/mit-license.php
