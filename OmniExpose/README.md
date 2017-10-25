
# OmniExpose
*v1.0a1*

## Introduction:
OmniExpose is an application that extends the Exposé feature to include applications that are currently hidden.

## WARNING:
This application is in early development state and therefore features are missing and problems do exist.
This application is completely unsupported - USE AT YOUR OWN RISK.

## Requirements:
Mac OS X 10.4 or later

## License &amp; Cost:
OmniExpose is completely free of charge and licensed under the [Open Source "MIT License"][1].

## Usage:
1.) Place the OmniExpose folder anywhere on your hard disk (the "/Applications" folder is most suitable).
2.) Double click OmniExpose.
3.) On first start OmniExpose will present an dialog asking you for a hotkey to invoke its function, as well as the hotkey that invokes the Exposé "show-all-windows" function. If you don't configure the hotkey that invokes Exposé correctly there is no chance that OmniExpose can work.
4.) Press the hotkey you have defined for OmniExpose and observe the results: all windows, including ones from hidden applications will be presented in Exposé mode

Note that OmniExpose is only compatible with two ways to use it, that are similar to Exposé usage:
• Press and hold the OmniExpose hotkey, move the mouse over the destination window and release the hotkey
• Press and immediately release the OmniExpose hotkey, move the mouse over the destination window and press the hotkey again briefly.
Don't do any other things that would be fine with standard-Exposé, like clicking the mouse button to select a window or exiting with the Escape-key, because if you do so OmniExpose will get very "confused".

## Known Problems / Todo List:
• OmniExpose can't determine the hotkey for the Exposé "show-all-windows" function itself
• OmniExpose can't  be invoked with an hotcorner, like Exposé
• OmniExpose will get very confused if you exit Exposé using a method other than the supported hotkey method, resulting in undefined behavior
• OmniExpose may not work at all if it hasn't been recently invoked because showing all hidden applications takes to long, so try it again immediately
• OmniExpose uses timing hacks to work around system problems, so it is likely to break on Macs that are very slow
…

[1]: https://opensource.org/licenses/mit-license.php
