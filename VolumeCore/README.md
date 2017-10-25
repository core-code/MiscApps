
# VolumeCore 
*v1.0b2*

## Introduction:
VolumeCore is an application for realtime visualization of volumetric data.
Some more details and documentation can be found (in GERMAN!) [here][1].

## WARNING:
This application is completely unsupported - USE AT YOUR OWN RISK.

## Requirements:
Mac OS X 10.5 or later
Intel processor
NOTE:	ATI videocards have a problem with VolumeCore as of Mac OS X 10.5.6
Maybe future system updates resolve driver problems and thus fix VolumeCore

## License &amp; Cost:
VolumeCore is completely free of charge and licensed under the [Open Source "MIT License"][2].
The included datasets are copyrighted by their respective owners and not MIT-licensed, see section "Disclaimer".

## Usage:
1.) Place the VolumeCore folder anywhere on your hard disk (the "/Applications" folder is most suitable).
2.) Double click VolumeCore.
3.) Choose the desired options and settings in the "Settings" Panel
4.) You can visualize the built in data sets or choose arbitrary data sets conforming to this data format (volume data in different formats can probably be converted):
Header:	2 byte - uSizeX	2 byte - uSizeY	2 byte - uSizeZ
Data: 		16 bit values (stored in unsigned short - but only 12 bits used)	(length: uSizeX * uSizeY * uSizeZ * sizeof(unsigned short))

## Disclaimer:
This application contains two data files with copyright by the Vienna University of Technology (Austria):

The [stag beetle][3] from Georg Glaeser, Vienna University of Applied Arts, Austria, was scanned with an industrial CT by Johannes Kastner, Wels College of Engineering, Austria, and Meister Eduard Gröller, Vienna University of Technology, Austria.

The [christmas tree][4] by A. Kanitsar, T. Theußl, L. Mroz, M. Sramek, A. Vilanova Bartroli, B. Csébfalvi, J. Hladuvka, S. Guthe, M. Knapp, R. Wegenkittl, P. Felkel, S. Roettger, D. Fleischmann, W. Purgathofer and M. E. Gröller.

[1]: http://www.cg.tuwien.ac.at/courses/Visualisierung/2008-2009/Beispiel1/Mayer/Web-Site/Introduction.html
[2]: https://opensource.org/licenses/mit-license.php
[3]: http://www.cg.tuwien.ac.at/research/publications/2005/dataset-stagbeetle/
[4]: http://www.cg.tuwien.ac.at/xmas/
