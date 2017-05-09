#!/usr/bin/python2.7
# -*- coding: UTF-8 -*-

import sys, subprocess, time, os, plistlib, biplist, re
from collections import defaultdict
from collections import Counter

fl = open("loclist.txt", 'r')
fa = open("applist.txt", 'r')
_controlCharPat = re.compile(
    r"[\x00\x01\x02\x03\x04\x05\x06\x07\x08\x0b\x0c\x0e\x0f"
    r"\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f]")


apps = fa.readlines()
final = {}					
							
for languageline in fl.readlines(): # for every language
	variants = languageline.split(" ")
	mainname = variants[0].strip()
	
	print mainname
	translations = defaultdict(list)
	
	for appline in apps: # for every app
		nibfilepath = appline.strip() + "/Contents/Resources/Base.lproj/MainMenu.nib"
		nibfile = biplist.readPlist(nibfilepath)

		appname = appline.split("/")[-1].replace(".app", "").strip()
		infoplistpath = appline.strip() + "/Contents/Info.plist"
		if os.path.exists(infoplistpath):
			try:
				infoplist = biplist.readPlist(infoplistpath)
				appname = infoplist["CFBundleName"]
			except:
				print "Info: got exception, ignoring: " + infoplistpath


		english = {}

		objects = nibfile["$objects"]
		for obj in objects:
			if isinstance(obj, basestring) and obj.endswith(".title"):
				num = objects.index(obj)
				nextobj = objects[num+1]
				if isinstance(nextobj, basestring):
					if not nextobj.endswith(":"):
						m = _controlCharPat.search(nextobj)
						if m is None:
							english[obj] = nextobj.replace(appname, "<APPNAME>").replace("NewApplication", "<APPNAME>")
						else:
							print "Warning: ignoring pair: " + obj + " : " + nextobj	
						
				
					
		for name in variants:
			curname = name.strip()

			localizedinfoplistpath = appline.strip() + "/Contents/Resources/" + curname + "/InfoPlist.strings"
			localappname = appname					 

			if os.path.exists(localizedinfoplistpath):
				try:
					localizedinfoplist = biplist.readPlist(localizedinfoplistpath)
				except:
					print "Info: got exception, ignoring: " + stringsfilepath
					if "CFBundleName" in localizedinfoplist:
						localappname = localizedinfoplist["CFBundleName"]
			else:
				print "Info: does not exist" + localizedinfoplistpath
					
			stringsfilepath = appline.strip() + "/Contents/Resources/" + curname + "/MainMenu.strings"
			#print curname
			#print stringsfilepath
			if os.path.exists(stringsfilepath):
				try:
					stringsfile = biplist.readPlist(stringsfilepath)
				except:
					print "Info: got exception, ignoring: " + stringsfilepath
				for key, value in stringsfile.iteritems():	#for every translated string
					trans = value.replace(appname, "<APPNAME>")
					trans = trans.replace(localappname, "<APPNAME>")
					trans = trans.replace("NewApplication", "<APPNAME>")
					if key in english:						#if we could find the original in the nib
						if (english[key] is not trans):		#if translation differs from english
							translations[english[key]] = translations[english[key]] + [trans]
			else:
				print "Info: does not exist" + stringsfilepath
	
	translationswithcount = {}
	for key, value in translations.iteritems():
		translationswithcount[key] =  Counter(value)


	final[mainname] = translationswithcount
	
plistlib.writePlist(final, "MainMenuTranslations.plist")
