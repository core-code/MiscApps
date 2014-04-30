#! /bin/sh

mv Configuration.strings Configuration~.strings
ibtool --generate-strings-file Configuration.strings Configuration.xib

mv MainMenu.strings MainMenu~.strings
ibtool --generate-strings-file MainMenu.strings MainMenu.xib
