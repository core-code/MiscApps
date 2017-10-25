
# TunesControllerClient
*v1.0a1*

## Introduction:
TunesControllerClient is the client-part of TunesController, an application for remotely controlling iTunes from any Java capable device.

## WARNING:
This application is in early development state and therefore features are missing and problems do exist.
This application is completely unsupported - USE AT YOUR OWN RISK.

## Requirements:
J2SE Java Runtime Environment 1.4 or later

## License &amp; Cost:
TunesControllerClient is completely free of charge and licensed under the [Open Source "MIT License"][1].

## Usage:
1.) Place the TunesControllerClient folder anywhere on your hard disk.
2.) Use the method provided by your platform to launch the TunesController.jar file. Double clicking should work on most platforms.
3.) Enter the IP-Address of the Computer running the TunesControllerServer instance and click connect.

## Known Problems / Todo List:
• TunesControllerClient contains no special code to support Mac OS X, and therefore features an ugly non-functional menubar when running in this environment
• TunesControllerClient can only connect to a server using the IP-Address, and doesn't support Rendezvous/Bonjour/Zeroconf
• TunesControllerClient error-handling is bad, you will get undefined results e.g. when another client is already connected to the server.
• The Source Code of TunesControllerClient depends on NetBeans 5.0+
…

[1]: https://opensource.org/licenses/mit-license.php
