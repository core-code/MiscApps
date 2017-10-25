
# SelectionFlasher 
*v1.0a1*

## Introduction:
SelectionFlasher is application that lets the current foreground text selection flash in different colors when a hotkey is pressed.

## WARNING:
This application is in early development state and therefore features are missing and problems do exist.
This application is completely unsupported - USE AT YOUR OWN RISK.

## Requirements:
Mac OS X 10.4 or later 

## License &amp; Cost:
SelectionFlasher is completely free of charge and licensed under the [Open Source "MIT License"][1].

## Usage:
1.) Place the SelectionFlasher folder anywhere on your hard disk (the "/Applications" folder is most suitable).
2.) Double click SelectionFlasher.
3.) On first start SelectionFlasher will present an dialog asking you for a hotkey to invoke its function.
4.) Press the hotkey you have defined and observe the current foreground text selection change color.

Note that many applications do not honor SelectionFlashers request to change the text selection highlight color.
Safari 3 doesn't work, but it now has usable search-text highlighting built-in.
Safari 2, Mail, TextEdit and Preview seem to be working fine.
Note that SelectionFlasher only shows its "user interface" on first launch to be able to configure the hotkey - to show the dialog on subsequent launches you must hold down alt.

## Known Problems / Todo List:
• Since SelectionFlasher displays an user interface only on first start it may seem like it didn't start at all
• Some applications like Safari 3 and the Finder do not honor SelectionFlashers request to change the text selection highlight color
• Only the selection in the foreground window can be flashed
• SelectionFlasher flashes the current text selection in 10 random colors, each for 100 milliseconds, resulting in an one second flash - no customization is possible
…

[1]: https://opensource.org/licenses/mit-license.php
