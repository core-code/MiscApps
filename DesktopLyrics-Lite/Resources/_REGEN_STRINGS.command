#! /bin/sh


mv MainMenu.strings MainMenu~.strings
ibtool --generate-strings-file MainMenu.strings MainMenu.xib
