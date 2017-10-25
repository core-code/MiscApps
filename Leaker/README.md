
# Leaker
*v1.0a1*

## Introduction:
Leaker is an application for showing the number and size of the memory leaks in all running processes.

## WARNING:
This application is in early development state and therefore features are missing and problems do exist.
This application is completely unsupported - USE AT YOUR OWN RISK.

## Requirements:
Mac OS X 10.4 or later 
Developer Tools installed

## License &amp; Cost:
Leaker is completely free of charge and licensed under the [Open Source "MIT License"][1].

## Usage:
1.) Place the Leaker folder anywhere on your hard disk (the "/Applications" folder is most suitable).
2.) Double click Leaker.
3.) Wait a few minutes and observe the results.

If you want to have statistics for the root-owned processes as well you have to launch Leaker using something like [Pseudo][2].

## Known Problems / Todo List:
• Leaker uses the Apple-supplied "leaks" command-line tool and inherits its problems and limitations:
  • Some processes may not give proper results especially if you aren't running Leaker as root (Big Problem, privilege error, etc...)
  • Scanning a process will cause it to freeze, resulting in an unresponsive system
…

[1]: https://opensource.org/licenses/mit-license.php
[2]: http://personalpages.tds.net/~brian_hill/pseudo.html
