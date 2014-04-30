#! /bin/sh

mv MainMenu.xib MainMenu~.xib
ibtool --strings-file MainMenu.strings --write MainMenu.xib ../English.lproj/MainMenu.xib