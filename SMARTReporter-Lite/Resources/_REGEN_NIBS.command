#! /bin/sh

mv Configuration.xib Configuration~.xib
ibtool --strings-file Configuration.strings --write Configuration.xib ../en.lproj/Configuration.xib

mv MainMenu.xib MainMenu~.xib
ibtool --strings-file MainMenu.strings --write MainMenu.xib ../en.lproj/MainMenu.xib