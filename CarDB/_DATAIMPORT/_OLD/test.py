#!/usr/bin/python2.7

import sys, os, signal, re, thread, threading, types, urllib2, objc, time
from socket import *
from struct import *
from urllib2 import HTTPError



data = urllib2.urlopen("http://www.heise.de/autos/neuwagenkatalog/liste.jsp?start=0")
lines = data.readlines()
full = "\n".join(lines)		
bla = full.split("autoid=")
for res in bla[1:]:
	print res.split("\"")[0]


i = 20

while i < 2260:
	data = urllib2.urlopen("http://www.heise.de/autos/neuwagenkatalog/liste.jsp?start=" + str(i))
	lines = data.readlines()
	full = "\n".join(lines)		
	bla = full.split("autoid=")
	for res in bla[1:]:
		print res.split("&")[0]
	i+=20