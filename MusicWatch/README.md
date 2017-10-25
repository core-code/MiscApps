
# MusicWatch
*v1.0a2*

## Introduction:
MusicWatch is an application for discovering new and old music of your favorite artists. It scans your music collection and extracts information about the albums you own. You can then easily discover other albums by those artists and get informed about new releases by those artists automatically. MusicWatch works like a RSS reader, with the artists being the "feeds" and the albums being the "articles".

## WARNING:
This application is in early development state and therefore features are missing and problems do exist.
This application is completely unsupported - USE AT YOUR OWN RISK.

## Requirements:
Mac OS X 10.6 or later 

## License &amp; Cost:
MusicWatch is completely free of charge and licensed under the [Open Source "MIT License"][1].

## Usage:
0.) MusicWatch can only operate on"properly tagged" music files. This means the metadata information of your music files must be properly (right names for artists and albums) and consistently (same artists and albums always spelled the same) filled out. If your music is not properly tagged you can use a tool like [MusicBrainz Picard ][2]to fix your music files.
1.) Place the MusicWatch folder anywhere on your hard disk (the "/Applications" folder is most suitable).
2.) Double click MusicWatch.
3.) Decide which artists you are interested in, since adding your whole music library to MusicWatch will result in the information about those artits being hard to find in between all those less interesting artists.
4.) Once you decided which artists you want to discover and observe using MusicWatch add **all the albums** you own from these artists to MusicWatch. There are basically two ways to do this - either by adding the folders containing the relevant music files or by making a playlist in iTunes that contains all these albums and adding this playlist to MusicWatch. For the first approach you can drag the folders containing the relevant music files to the left table (the Artist table) of the main MusicWatch window. Alternatively you can click "Add" in the toolbar and either choose the files from there or select the iTunes playlist to add.
5.) MusicWatch now scans the music and fetches informations about these artists from [MusicBrainz][3]. Since fetching this information is a bandwidth-intensive operation please consider [donating to the MusicBrainz project ][4]to help cover their costs. Possibly MusicWatch asks you for some albums if two names are refering to the same album, because it needs help matching album names.
6.) After MusicWatch has finished (can take a long time if you add a lot of music) you will see a list of the artists you are interested in the left table. The albums of the selected artist are presented in the right table. The albums are
 	red if they could not be matched to an album from this artist. This either means it is misspelled (you can use the "Match album" toolbar button in this case), or not a real album (e.g. an E.P., live-album, compilation-album, soundtrack, etc)
**bold** if you own this album
not-bold if you don't own this album yet
7.) MusicWatch remembers which albums you already know about. When you first add artists, the albums you already own are maked as "seen" and the other ones as "new". You can now inspect the new albums and mark them as "seen" by selecting them. You should probably inspect all those albums now to see if you want to buy them too, and mark them all as seen so there are zero "new" albums left. Double clicking an artist or album will open the relevant MusicBrainz website.
8.) Start MusicWatch again every few weeks. Hit the refresh button. MusicWatch now looks if there are any new albums from the artists you have added. The new albums will be easily discoverable because the left artists table has a column indicating how many new albums from this artist have been released.

## Known Problems / Todo List:
• If you add only not-real-albums (e.g. an E.P., live-album, compilation-album, soundtrack, etc) from an artist, the artist can't be matched with MusicBrainz. Unmatched artists appear in red, just like unmatched albums.
…

## History:
**1.0a2**:
  • Fixed a problem where the "year" of a fetched album would be 1900
**1.0a1**:
  • Initial public release

[1]: https://opensource.org/licenses/mit-license.php
[2]: http://musicbrainz.org/doc/MusicBrainz_Picard
[3]: http://musicbrainz.org/
[4]: http://metabrainz.org/donate/
