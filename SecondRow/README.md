
# SecondRow
*v1.0a1*

## Introduction:
SecondRow is an application that automatically redirects the "Front Row" presentation mode to your second display, so you can experience "Front Row" on your big TV-screen instead of your computer monitor.

## WARNING:
This application is in early development state and therefore features are missing and problems do exist.
This application is completely unsupported - USE AT YOUR OWN RISK.

## Requirements:
Mac OS X 10.5 or later 

## License &amp; Cost:
SecondRow is completely free of charge and licensed under the [Open Source "MIT License"][1].

## Usage:
1.) Place the SecondRow folder anywhere on your hard disk (the "/Applications" folder is most suitable).
2.) Double click SecondRow. You won't see anything now since SecondRow is a background application without Graphical-User-Interface.
3.) Until your Mac is restarted any invocation of "Front Row" will now be redirected to your second attached display. Note: SecondRow may have to quit and restart "Front Row" for this to happen, so be patient.
4.) You may want to add SecondRow to "System Preferences-&gt;Users-&gt;Login Items" so you don't have to start it manually after every reboot.


## Known Problems / Todo List:
• SecondRow runs and functions from the time it is started until the next reboot. If you want to quit it you have to do so manually using "Activity Monitor.app"
• SecondRow may produce problems or misbehave until restarted when more or less than 2 displays are attached while "Front Row" is invoked
• SecondRow may stop working with future system updates since it relies on the undocumented notification " com.apple.BezelServices.BMDisplayHWReconfiguredEvent"
…

[1]: https://opensource.org/licenses/mit-license.php
