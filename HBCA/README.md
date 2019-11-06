# HBCA
*v1.0*

## Introduction:
HBCA is the HomeBrew Cask App for contributors to the [Homebrew Cask](https://github.com/Homebrew/homebrew-cask) project on-the-go.


## Requirements:
iOS 12.0 or macOS 10.15

## License &amp; Cost:
HBCA is completely free of charge and licensed under the [Open Source "MIT License"][2].

## Installation:
a.) If you want to use HBCA on an iOS device, you'll need to compile and install it yourself, see below
b.) If you want to use HBCA on a Mac, you can download the 1.0 release [here](https://raw.githubusercontent.com/core-code/MiscApps/master/HBCA/Binaries/HBCA_Mac_1.0.zip)

## Features
1.) it allows you to find out the name of any cask via a live search bar that works in realtime, in contrast to 'brew search' which takes exactly 7.3 eternities
2.) for any given cask, it allows you to quickly look at the caskfile, e.g. to learn about the latest version of this app in HBC. if will first display the version of the last "fetch", and then replace with the live version as soon as it is downloaded
3.) for any cask, you can quickly open a pull request in the webinterface
4.) for any cask, you can also calculate the checksum of a new version by entering the new version number. it will downloading the new file, a bit similarly to cask-repair to calculate the checksum. after it has finished downloading you can copy either the SHA256 or the whole updated caskfile including the new versionnumber => to submit as a PR via feature #3
5.) if you do have a server which can host CGI files, you can copy a short CGI file on your server and define the server URL before compiling the app. this will allow you to calculate checksums of updates on your server, instead of downloading updates locally to your iOS device. obviously, this can safe time and bandwidth

## Compilation
 to compile, you need
• a recent Xcode version
• and will also need to place a copy of our CoreLib ( https://github.com/core-code/CoreLib ) next to the HBCA folder.
• i am not sure if a paying Apple Developer membership is needed these days to install self compiled apps on your iOS device.
• you'll need to create a file "HBCA.xcconfig" in the HBCA folder containing
"DEVELOPMENT_TEAM = <yourappledeveloperteamid>"
• if you have the CGI to calculate checksums on a server installed on your server, you can adjust the __CGI_SHA_CALCULATION_URL_ entry in the Info.plist file## Compilation


## Screenshots
![Search](/HBCA/Sceenshots/ss1.png)
![View](/HBCA/Sceenshots/ss2.png)
![Edit](/HBCA/Sceenshots/ss3.png)

