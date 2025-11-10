#!/usr/bin/python2.7
# -*- coding: UTF-8 -*-
import sys, os, signal, re, thread, threading, types, urllib2, objc, time, json, re, urllib
from socket import *
from struct import *
from urllib2 import HTTPError

num = 38


audi_info = [
{'seats' : 4, 'doors': 3, 'width': 1740, 'height': 1416, 'length': 3954, 'wheelbase': 2469, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a1/a1.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1746, 'height': 1422, 'length': 3954, 'wheelbase': 2469, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a1/a1-sportback.carinfo.json'}, 
{'seats' : 4, 'doors': 3, 'width': 1740, 'height': 1416, 'length': 3954, 'wheelbase': 2469, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a1/s1.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1746, 'height': 1422, 'length': 3954, 'wheelbase': 2469, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a1/s1-sportback.carinfo.json'}, 

{'seats' : 4, 'doors': 2, 'width': 1793, 'height': 1409, 'length': 4421, 'wheelbase': 2595, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a3/a3-cabriolet.carinfo.json'}, 
{'seats' : 5, 'doors': 4, 'width': 1796, 'height': 1416, 'length': 4456, 'wheelbase': 2637, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a3/a3-limousine.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1785, 'height': 1425, 'length': 4310, 'wheelbase': 2636, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a3/a3-sportback.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1785, 'height': 1425, 'length': 4310, 'wheelbase': 2636, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a3/a3-sportback-e-tron.carinfo.json'}, 
{'seats' : 5, 'doors': 3, 'width': 1777, 'height': 1421, 'length': 4237, 'wheelbase': 2601, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a3/a3.carinfo.json'}, 
{'seats' : 4, 'doors': 2, 'width': 1793, 'height': 1409, 'length': 4421, 'wheelbase': 2595, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a3/s3-cabriolet.carinfo.json'}, 
{'seats' : 5, 'doors': 4, 'width': 1796, 'height': 1392, 'length': 4469, 'wheelbase': 2631, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a3/s3-limousine.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1785, 'height': 1404, 'length': 4324, 'wheelbase': 2631, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a3/s3-sportback.carinfo.json'}, 
{'seats' : 5, 'doors': 3, 'width': 1777, 'height': 1401, 'length': 4254, 'wheelbase': 2596, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a3/s3.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1841, 'height': 1495, 'length': 4721, 'wheelbase': 2805, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a4/a4-allroad-quattro.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1826, 'height': 1436, 'length': 4699, 'wheelbase': 2808, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a4/a4-avant.carinfo.json'}, 
{'seats' : 5, 'doors': 4, 'width': 1826, 'height': 1427, 'length': 4701, 'wheelbase': 2808, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a4/a4-limousine.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1850, 'height': 1416, 'length': 4719, 'wheelbase': 2813, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a4/rs-4-avant.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1826, 'height': 1415, 'length': 4719, 'wheelbase': 2811, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a4/s4-avant.carinfo.json'}, 
{'seats' : 5, 'doors': 4, 'width': 1826, 'height': 1406, 'length': 4716, 'wheelbase': 2811, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a4/s4-limousine.carinfo.json'}, 
{'seats' : 4, 'doors': 2, 'width': 1854, 'height': 1383, 'length': 4626, 'wheelbase': 2751, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a5/a5-cabriolet.carinfo.json'}, 
{'seats' : 4, 'doors': 3, 'width': 1854, 'height': 1372, 'length': 4625, 'wheelbase': 2751, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a5/a5-coupe.carinfo.json'}, 
{'seats' : 4, 'doors': 5, 'width': 1854, 'height': 1391, 'length': 4712, 'wheelbase': 2810, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a5/a5-sportback.carinfo.json'}, 
{'seats' : 4, 'doors': 2, 'width': 1860, 'height': 1380, 'length': 4649, 'wheelbase': 2751, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a5/rs-5-cabriolet.carinfo.json'}, 
{'seats' : 4, 'doors': 3, 'width': 1860, 'height': 1366, 'length': 4649, 'wheelbase': 2751, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a5/rs-5-coupe.carinfo.json'}, 
{'seats' : 4, 'doors': 2, 'width': 1854, 'height': 1380, 'length': 4649, 'wheelbase': 2751, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a5/s5-cabriolet.carinfo.json'}, 
{'seats' : 4, 'doors': 3, 'width': 1854, 'height': 1369, 'length': 4635, 'wheelbase': 2751, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a5/s5-coupe.carinfo.json'}, 
{'seats' : 4, 'doors': 5, 'width': 1854, 'height': 1382, 'length': 4718, 'wheelbase': 2811, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a5/s5-sportback.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1898, 'height': 1534, 'length': 4940, 'wheelbase': 2905, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a6/a6-allroad-quattro.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1874, 'height': 1461, 'length': 4926, 'wheelbase': 2912, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a6/a6-avant.carinfo.json'}, 
{'seats' : 5, 'doors': 4, 'width': 1874, 'height': 1455, 'length': 4915, 'wheelbase': 2912, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a6/a6-limousine.carinfo.json'}, 
#{'seats' : 5, 'doors': 5, 'width': 1936, 'height': 1461, 'length': 4979, 'wheelbase': 2915, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a6/rs-6-avant.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1874, 'height': 1446, 'length': 4934, 'wheelbase': 2912, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a6/s6-avant.carinfo.json'}, 
{'seats' : 5, 'doors': 4, 'width': 1874, 'height': 1440, 'length': 4931, 'wheelbase': 2916, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a6/s6-limousine.carinfo.json'}, 
{'seats' : 4, 'doors': 5, 'width': 1911, 'height': 1420, 'length': 4969, 'wheelbase': 2914, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a7/a7-sportback.carinfo.json'}, 
{'seats' : 4, 'doors': 5, 'width': 1911, 'height': 1419, 'length': 5012, 'wheelbase': 2915, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a7/rs-7-sportback.carinfo.json'}, 
{'seats' : 4, 'doors': 5, 'width': 1911, 'height': 1408, 'length': 4980, 'wheelbase': 2916, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a7/s7-sportback.carinfo.json'}, 
{'seats' : 5, 'doors': 4, 'width': 1949, 'height': 1471, 'length': 5265, 'wheelbase': 3122, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a8/a8-l-w12.carinfo.json'}, 
{'seats' : 5, 'doors': 4, 'width': 1949, 'height': 1471, 'length': 5265, 'wheelbase': 3122, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a8/a8-l.carinfo.json'}, 
{'seats' : 5, 'doors': 4, 'width': 1949, 'height': 1460, 'length': 5135, 'wheelbase': 2992, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a8/a8.carinfo.json'}, 
{'seats' : 5, 'doors': 4, 'width': 1949, 'height': 1458, 'length': 5147, 'wheelbase': 2994, 'site': 'http://www.audi.de/de/brand/de/neuwagen/a8/s8.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1831, 'height': 1608, 'length': 4385, 'wheelbase': 2603, 'site': 'http://www.audi.de/de/brand/de/neuwagen/q3/q3.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1841, 'height': 1580, 'length': 4410, 'wheelbase': 2603, 'site': 'http://www.audi.de/de/brand/de/neuwagen/q3/rs-q3.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1898, 'height': 1655, 'length': 4629, 'wheelbase': 2807, 'site': 'http://www.audi.de/de/brand/de/neuwagen/q5/q5.carinfo.json'}, 
{'seats' : 5, 'doors': 5, 'width': 1911, 'height': 1624, 'length': 4644, 'wheelbase': 2813, 'site': 'http://www.audi.de/de/brand/de/neuwagen/q5/sq5-tdi.carinfo.json'}, 
{'seats' : 7, 'doors': 5, 'width': 1983, 'height': 1729, 'length': 5089, 'wheelbase': 3002, 'site': 'http://www.audi.de/de/brand/de/neuwagen/q7/q7.carinfo.json'}, 
{'seats' : 2, 'doors': 2, 'width': 1904, 'height': 1252, 'length': 4440, 'wheelbase': 2650, 'site': 'http://www.audi.de/de/brand/de/neuwagen/r8/r8-coupe.carinfo.json'}, 
{'seats' : 2, 'doors': 2, 'width': 1904, 'height': 1244, 'length': 4440, 'wheelbase': 2650, 'site': 'http://www.audi.de/de/brand/de/neuwagen/r8/r8-spyder.carinfo.json'}, 
{'seats' : 4, 'doors': 2, 'width': 1842, 'height': 1353, 'length': 4198, 'wheelbase': 2468, 'site': 'http://www.audi.de/de/brand/de/neuwagen/tt/tt-coupe.carinfo.json'}, 
#{'seats' : 2, 'doors': 2, 'width': 1842, 'height': 1358, 'length': 4198, 'wheelbase': 2468, 'site': 'http://www.audi.de/de/brand/de/neuwagen/tt/tt-roadster.carinfo.json'}, 
#{'seats' : 4, 'doors': 2, 'width': 1842, 'height': 1342, 'length': 4198, 'wheelbase': 2468, 'site': 'http://www.audi.de/de/brand/de/neuwagen/tt/tt-rs-coupe.carinfo.json'}, 
#{'seats' : 2, 'doors': 2, 'width': 1842, 'height': 1348, 'length': 4198, 'wheelbase': 2468, 'site': 'http://www.audi.de/de/brand/de/neuwagen/tt/tt-rs-roadster.carinfo.json'}, 
#{'seats' : 4, 'doors': 2, 'width': 1842, 'height': 1345, 'length': 4198, 'wheelbase': 2468, 'site': 'http://www.audi.de/de/brand/de/neuwagen/tt/tts-coupe.carinfo.json'}, 
#{'seats' : 2, 'doors': 2, 'width': 1842, 'height': 1350, 'length': 4198, 'wheelbase': 2468, 'site': 'http://www.audi.de/de/brand/de/neuwagen/tt/tts-roadster.carinfo.json'}
]

bmw_info = [
{'seats' : 5, 'doors': 3, 'width': 1765, 'height': 1421, 'length': 4324, 'wheelbase': 2690, 'site': 'http://www.bmw.de/de/neufahrzeuge/1er/3-tuerer/2012/technische-daten.html'}, 
{'seats' : 5, 'doors': 3, 'width': 1765, 'height': 1421, 'length': 4324, 'wheelbase': 2690, 'site': 'http://www.bmw.de/de/neufahrzeuge/1er/5-door/2011/technische-daten.html'}, 
{'seats' : 4, 'doors': 2, 'width': 1774, 'height': 1418, 'length': 4432, 'wheelbase': 2690, 'site': 'http://www.bmw.de/de/neufahrzeuge/2er/coupe/2013/technische-daten.html'}, 
{'seats' : 5, 'doors': 4, 'width': 1811, 'height': 1429, 'length': 4624, 'wheelbase': 2810, 'site': 'http://www.bmw.de/de/neufahrzeuge/3er/limousine/2011/technische-daten.html'}, 
{'seats' : 5, 'doors': 4, 'width': 1811, 'height': 1429, 'length': 4624, 'wheelbase': 2810, 'site': 'http://www.bmw.de/de/neufahrzeuge/3er/touring/2012/technische-daten.html'}, 
{'seats' : 5, 'doors': 5, 'width': 1828, 'height': 1508, 'length': 4824, 'wheelbase': 2920, 'site': 'http://www.bmw.de/de/neufahrzeuge/3er/gran-turismo/2013/technische-daten.html'}, 
{'seats' : 5, 'doors': 4, 'width': 1811, 'height': 1429, 'length': 4624, 'wheelbase': 2810, 'site': 'http://www.bmw.de/de/neufahrzeuge/3er/activehybrid-3/2011/technische-daten.html'}, 
{'seats' : 4, 'doors': 2, 'width': 1825, 'height': 1362, 'length': 4638, 'wheelbase': 2810, 'site': 'http://www.bmw.de/de/neufahrzeuge/4/coupe/2013/technische-daten.html'}, 
{'seats' : 4, 'doors': 2, 'width': 1825, 'height': 1380, 'length': 4638, 'wheelbase': 2810, 'site': 'http://www.bmw.de/de/neufahrzeuge/4/cabrio/2013/technische-daten.html'}, 
{'seats' : 4, 'doors': 2, 'width': 1825, 'height': 1372, 'length': 4638, 'wheelbase': 2810, 'site': 'http://www.bmw.de/de/neufahrzeuge/4/gran-coupe/2014/technische-daten.html'}, 
{'seats' : 5, 'doors': 4, 'width': 1860, 'height': 1464, 'length': 4907, 'wheelbase': 2968, 'site': 'http://www.bmw.de/de/neufahrzeuge/5er/limousine/2013/technische-daten.html'}, 
{'seats' : 5, 'doors': 5, 'width': 1860, 'height': 1462, 'length': 4907, 'wheelbase': 2968, 'site': 'http://www.bmw.de/de/neufahrzeuge/5er/touring/2013/technicaldata.html'}, 
{'seats' : 5, 'doors': 5, 'width': 1901, 'height': 1559, 'length': 5004, 'wheelbase': 3070, 'site': 'http://www.bmw.de/de/neufahrzeuge/5er/gran-turismo/2013/technische-daten.html'}, 
{'seats' : 5, 'doors': 4, 'width': 1860, 'height': 1464, 'length': 4907, 'wheelbase': 2968, 'site': 'http://www.bmw.de/de/neufahrzeuge/5er/activehybrid-5/2013/data.html'}, 
{'seats' : 4, 'doors': 2, 'width': 1894, 'height': 1369, 'length': 4894, 'wheelbase': 2855, 'site': 'http://www.bmw.de/de/neufahrzeuge/6er-uebersicht/coupe/2011/technische-daten.html'},
{'seats' : 4, 'doors': 2, 'width': 1894, 'height': 1365, 'length': 4894, 'wheelbase': 2855, 'site': 'http://www.bmw.de/de/neufahrzeuge/6er-uebersicht/cabrio/2010/technische-daten.html'},
{'seats' : 5, 'doors': 4, 'width': 1894, 'height': 1392, 'length': 5007, 'wheelbase': 2968, 'site': 'http://www.bmw.de/de/neufahrzeuge/6er-uebersicht/grancoupe/2011/technische-daten.html'},
{'seats' : 5, 'doors': 4, 'width': 1902, 'height': 1471, 'length': 5079, 'wheelbase': 3070, 'site': 'http://www.bmw.de/de/neufahrzeuge/7er/limousine/2012/technische-daten.html'},
{'seats' : 5, 'doors': 4, 'width': 1902, 'height': 1481, 'length': 5079, 'wheelbase': 3070, 'site': 'http://www.bmw.de/de/neufahrzeuge/7er/activehybrid-7/2012/technische-daten.html'},
{'seats' : 5, 'doors': 5, 'width': 1881, 'height': 1675, 'length': 4648, 'wheelbase': 2810, 'site': 'http://www.bmw.de/de/neufahrzeuge/x/x3/2014/technische-daten.html'},
{'seats' : 5, 'doors': 5, 'width': 1938, 'height': 1762, 'length': 4886, 'wheelbase': 2933, 'site': 'http://www.bmw.de/de/neufahrzeuge/x/x5/2013/technischedaten.html'},
{'seats' : 2, 'doors': 2, 'width': 1790, 'height': 1291, 'length': 4239, 'wheelbase': 2496, 'site': 'http://www.bmw.de/de/neufahrzeuge/z4/roadster/2012/technische-daten.html'},
{'seats' : 5, 'doors': 4, 'width': 1877, 'height': 1430, 'length': 4671, 'wheelbase': 2812, 'site': 'http://www.bmw.de/de/neufahrzeuge/M/m3-limousine/2014/technische-daten.html'},
{'seats' : 4, 'doors': 2, 'width': 1870, 'height': 1383, 'length': 4671, 'wheelbase': 2812, 'site': 'http://www.bmw.de/de/neufahrzeuge/M/m4coupe/2014/technische-daten.html'},
{'seats' : 5, 'doors': 3, 'width': 1891, 'height': 1467, 'length': 4910, 'wheelbase': 2964, 'site': 'http://www.bmw.de/de/neufahrzeuge/M/m5-limousine/2013/technische-daten.html'},
{'seats' : 4, 'doors': 2, 'width': 1899, 'height': 1374, 'length': 4898, 'wheelbase': 2851, 'site': 'http://www.bmw.de/de/neufahrzeuge/M/m6-coupe/2012/technische-daten.html'},
{'seats' : 4, 'doors': 2, 'width': 1899, 'height': 1386, 'length': 4898, 'wheelbase': 2851, 'site': 'http://www.bmw.de/de/neufahrzeuge/M/m6-cabrio/2012/technische-daten.html'},
{'seats' : 5, 'doors': 4, 'width': 1894, 'height': 1392, 'length': 5007, 'wheelbase': 2968, 'site': 'http://www.bmw.de/de/neufahrzeuge/M/m6grancoupe/2012/technische-daten.html'},
{'seats' : 4, 'doors': 5, 'width': 1775, 'height': 1597, 'length': 3999, 'wheelbase': 2570, 'site': 'http://www.bmw.de/de/neufahrzeuge/bmw-i/i3/2013/techdata.html'}]

#i8, activehybridL length

def fetchPorsche():
	models = {}
	codes = []
	data = urllib2.urlopen("http://www.porsche.com/all/comparemodels/Select.aspx?pool=germany")
	lines = data.readlines()
	if (len(lines) == 0): raise Exception("ERROR: got empty file from url: " + url)
	full = "\n".join(lines)		
	codes = full.split("selectLink_")[1:]
	codes = [x.split("\"")[0] for x in codes]

	for model in codes:
		data = urllib2.urlopen("http://www.porsche.com/all/comparemodels/Compare.aspx?pool=germany&compTab=0&model1=" + model)
		lines = data.readlines()
		if (len(lines) == 0): raise Exception("ERROR: got empty file from url: " + url)
		full = "\n".join(lines)		
	
		if (full.find("single selected") != -1):
			postfixes = [""]
		else: 
			postfixes = []
			if (full.find("'250'") != -1): postfixes.append("_250")
			if (full.find("'249'") != -1): postfixes.append("_249")
			if (full.find("'480'") != -1): postfixes.append("_480")

		for postfix in postfixes:
			url = "http://www.porsche.com/all/comparemodels/Compare.aspx?pool=germany&compTab=0&model1=" + model + postfix
			#print url
	
			data = urllib2.urlopen(url)
			lines = data.readlines()
			if (len(lines) == 0): raise Exception("ERROR: got empty file from url: " + url)
			full = "\n".join(lines)		
			curr = (full.split("printHeaders")[1].split("alt=\"")[1]).split("\"")[0].replace("Der neue ","").replace("Das neue ", "")
	
			if (len(postfixes) > 1 and postfix is "_250"): 
				curr = curr + " (PDK)"
			if (len(postfixes) > 1 and postfix is "_249"): 
				curr = curr + " (Tiptronic S)"

			#print curr
			models[curr] = [None] * num
			models[curr][brand] = "Porsche"
			models[curr][modelname] = curr
			models[curr][poweredWheels] = "2" #rwd default
			models[curr][fuelType] = "1" #super default
			models[curr][engineAspiration] = "1" #NA default
			models[curr][engineLocation] = "1" #front engine default
			#if (len(postfixes) > 1 and postfix is "_249"): 
			#if (len(postfixes) > 1 and postfix is "_250"): 

			if (curr.find("Diesel") != -1): models[curr][fuelType] = "2"
			if (curr.find(" 4") != -1): models[curr][poweredWheels] = "3"
			if (curr.find("Boxster") != -1): models[curr][doorCount] = "2";models[curr][maxSeatCount] = "2";models[curr][cylinderLayout] = 3
			if (curr.find("Cayman") != -1): models[curr][doorCount] = "2";models[curr][maxSeatCount] = "2";models[curr][cylinderLayout] = 3
			if (curr.find("911") != -1): models[curr][doorCount] = "2";models[curr][maxSeatCount] = "4";models[curr][cylinderLayout] = 3
			if (curr.find("Panamera") != -1): models[curr][doorCount] = "4";models[curr][maxSeatCount] = "4";models[curr][cylinderLayout] = 2
			if (curr.find("Cayenne") != -1): models[curr][doorCount] = "5";models[curr][maxSeatCount] = "5";models[curr][cylinderLayout] = 2;models[curr][poweredWheels] = "3"
			if (curr.find("Macan") != -1): models[curr][doorCount] = "5";models[curr][maxSeatCount] = "5";models[curr][cylinderLayout] = 2;models[curr][poweredWheels] = "3"

			

			if (full.find("Hubraum</td>") != -1):
				models[curr][displacementCCM] = full.split("Hubraum</td>")[1].split(">")[1].split("</td>")[0].split("cm")[0].replace(" ","").replace(".","")
			if (full.find("0 - 100 km/h</td>") != -1):
				models[curr][accelerationTo100] = full.split("0 - 100 km/h</td>")[1].split(">")[1].split("</td>")[0].split(" ")[0].replace(",",".")
			if (full.find(">Preis<") != -1):
				models[curr][minPriceEU] = full.split(">Preis<")[1].split("Ab EUR ")[1].split("<")[0].split(" ")[0].split(",")[0].replace(".","")
			if (full.find("Zylinderzahl</td>") != -1):
				models[curr][cylinderCount] = full.split("Zylinderzahl</td>")[1].split(">")[1].split("<")[0]
			if (full.find("chstgeschwindigkeit</td>") != -1):
				models[curr][maxSpeed] = full.split("chstgeschwindigkeit</td>")[1].split(">")[1].split("<")[0].split(" ")[0]
			if (full.find("Leistung</td>") != -1):
				tmp = full.split("Leistung</td>")[1].split(">")[1].split("</td")[0]
				if (tmp.find("Ges.: ") != -1): tmp = tmp.split("Ges.: ")[1]
				models[curr][maxHorsepower] = tmp.split("(")[1].split(")")[0].replace("PS","").replace(" ","")
			if (full.find("Drehzahl</td>") != -1):
				tmp = full.split("Drehzahl</td>")[1].split("techdat\">")[1].split("</td")[0]
				if (tmp.find("Ges.: ") != -1): tmp = tmp.split("Ges.: ")[1]
				models[curr][maxHorsepowerRRM] = tmp.split(" ")[0].replace(".","")
			if (full.find("Drehmoment</td>") != -1):
				tmp = full.split("Drehmoment</td>")[1].split("techdat\">")[1].split("</td")[0]
				if (tmp.find("Ges.: ") != -1): tmp = tmp.split("Ges.: ")[1]
				models[curr][maxTorque] = tmp.split(" ")[0]
				post = full.split("Drehmoment</td>")[1]
				if (post.find("Drehzahl</td>") != -1):
					tmp = post.split("Drehzahl</td>")[1].split("techdat\">")[1].split("</td")[0]
					if (tmp.find("Ges.: ") != -1): tmp = tmp.split("Ges.: ")[1]
					models[curr][maxTorqueRPMLow] = tmp.split(" ")[0].replace(".","")
			if (full.find("Kombiniert in l/100 km</td>") != -1):
				models[curr][fuelConsumptionEUCombined] = full.split("Kombiniert in l/100 km</td>")[1].split(">")[1].split("<")[0].split(" ")[0].replace(",",".")
			if (full.find("Mittelmotor") != -1): models[curr][engineLocation] = "2"
			if (full.find("Heckmotor") != -1): models[curr][engineLocation] = "3"
			if (full.find("Allradantrieb") != -1): models[curr][poweredWheels] = "3"
			if (full.find("CO2-Emission in g/km</td>") != -1):
				models[curr][co2Emission] = full.split("CO2-Emission in g/km</td>")[1].split(">")[1].split("<")[0].split(" ")[0]

	
			if (full.find("Elastizit") != -1):
				value = 999
				tmp = full.split("Elastizit")[1].split(">")[2].split("<")[0].split(" ")[0].replace(",",".")
				if ("." in tmp): value = float(tmp)
				if (full.find("Durchzugsbeschleunigung") != -1):
					tmp = full.split("Durchzugsbeschleunigung")[1].split(">")[2].split("<")[0].split(" ")[0].replace(",",".")
					if ("." in tmp):
						new = float(tmp)
						if (new < value): value = new
				if (value < 999): 
					models[curr][elasticity80To120] = value
			else:
				if (full.find("Durchzugsbeschleunigung") != -1):
					tmp = full.split("Durchzugsbeschleunigung")[1].split(">")[2].split("<")[0].split(" ")[0].replace(",",".")
					if ("." in tmp):
						models[curr][elasticity80To120] = float(tmp)

			data = urllib2.urlopen("http://www.porsche.com/all/comparemodels/Compare.aspx?pool=germany&compTab=1&model1=" + model + postfix)
			lines = data.readlines()
			if (len(lines) == 0): raise Exception("ERROR: got empty file from url: " + url)
			full = "\n".join(lines)		
			if (full.find("V-Anordnung") != -1):	models[curr][cylinderLayout] = 2
			if (full.find("Boxeranordnung") != -1):	models[curr][cylinderLayout] = 3


			data = urllib2.urlopen("http://www.porsche.com/all/comparemodels/Compare.aspx?pool=germany&compTab=2&model1=" + model + postfix)
			lines = data.readlines()
			if (len(lines) == 0): raise Exception("ERROR: got empty file from url: " + url)
			full = "\n".join(lines)		
			
			if (full.find("PASM (*)") != -1): models[curr][adaptiveSuspension] = "1"
			elif (full.find("PASM") != -1): models[curr][adaptiveSuspension] = "2"
			else: models[curr][adaptiveSuspension] = "0"
	
			for line in lines:
				if (line.find("Reifen ") != -1 and line.find("vorn") != -1):
					tmp = line.split("Reifen ")[1].split("vorn")[0]
					models[curr][wheelsWidthFront] = tmp.split("/")[0].replace(" ", "")					
					models[curr][wheelsRatioFront] = tmp.split("/")[1].split(" ")[0]	
					models[curr][wheelsRadiusFront] = tmp.replace(" ", "").split("R")[1]	
					
				if (line.find("Reifen ") != -1 and line.find("hinten") != -1):					
					tmp = line.split("hinten")[0].split("Reifen ")[-1]
					models[curr][wheelsWidthBack] = tmp.split("/")[0].replace(" ", "")					
					models[curr][wheelsRatioBack] = tmp.split("/")[1].split(" ")[0]	
					models[curr][wheelsRadiusBack] = tmp.replace(" ", "").split("R")[1]	
				
			data = urllib2.urlopen("http://www.porsche.com/all/comparemodels/Compare.aspx?pool=germany&compTab=4&model1=" + model + postfix)
			lines = data.readlines()
			if (len(lines) == 0): raise Exception("ERROR: got empty file from url: " + url)
			full = "\n".join(lines)		
						
			if (full.find("Länge</td>") != -1):
				models[curr][lengthMM] = full.split("Länge</td>")[1].split(">")[1].split("<")[0].split(" ")[0].replace(".","")
			if (full.find("Breite</td>") != -1):
				models[curr][widthMM] = full.split("Breite</td>")[1].split(">")[1].split("<")[0].split(" ")[0].replace(".","")
			if (full.find("Höhe</td>") != -1):
				models[curr][heightMM] = full.split("Höhe</td>")[1].split(">")[1].split("<")[0].split(" ")[0].replace(".","")
			if (full.find("Radstand</td>") != -1):
				models[curr][wheelDistanceMM] = full.split("Radstand</td>")[1].split(">")[1].split("<")[0].split(" ")[0].replace(".","")
			if (full.find("Leergewicht nach EG-Richtlinie</td>") != -1):
				models[curr][weightEU] = full.split("Leergewicht nach EG-Richtlinie</td>")[1].split(">")[1].split("<")[0].split(" ")[0].replace(".","")
			if (full.find("Tankinhalt") != -1):
				models[curr][fuelTankSize] = full.split("Tankinhalt")[1].split(">")[2].split("<")[0].split("l")[0].replace("ca.","").replace(" ", "")					
			if (full.find("rraumvolumen") != -1):
				tmp = full.split("rraumvolumen")[1].split("techdat\">")[1].split("<")[0]
				tmp = tmp.replace(".", "")
				tmp = tmp.replace("l ", " l ")
				if (tmp.find("vorne") != -1):
					models[curr][luggageSpaceMin] = models[curr][luggageSpaceMax] = sum([int(x) if x.isdigit()  else 0 for x in tmp.split(" ")])
				else:
					array = [int(x) if x.isdigit()  else 0 for x in tmp.split(" ")]
					array = [value for value in array if value != 0]
					models[curr][luggageSpaceMin] = models[curr][luggageSpaceMax]= array[0]
					if (len(array) > 1): models[curr][luggageSpaceMax]= array[1]
	
	
			data = urllib2.urlopen("http://www.porsche.com/all/comparemodels/Compare.aspx?pool=germany&compTab=1&model1=" + model + postfix)
			lines = data.readlines()
			if (len(lines) == 0): raise Exception("ERROR: got empty file from url: " + url)
			full = "\n".join(lines)		
	
			if (full.find("Turbolader") != -1) or (curr.find("Turbo") != -1 or (curr.find("Diesel") != -1)): models[curr][engineAspiration] = "2"
	
			manu = full.split("Schaltgetriebe</td>")[1].split(">")[1].split("<")[0]
			if (full.find("Tiptronic S</td>") != -1):
				auto = full.split("Tiptronic S</td>")[1].split(">")[1].split("<")[0]
			else:
				auto = full.split("utomatikgetriebe verfügbar")[1].split(">")[2].split("<")[0]
			dkg = ""
			if (len(full.split("PDK</td>")) > 1):
				dkg = full.split("PDK</td>")[1].split(">")[1].split("<")[0]

			if (manu.find("-Gang") != -1):
				models[curr][transmissionType] = "1"
				models[curr][gearCount] = manu.split("-Gang")[0].split(" ")[-1]
			elif (auto.find("-Gang") != -1):
				models[curr][transmissionType] = "2"
				models[curr][gearCount] = auto.split("-Gang")[0].split(" ")[-1]
			elif (dkg.find("-Gang") != -1):
				models[curr][transmissionType] = "3"
				models[curr][gearCount] = dkg.split("-Gang")[0].split(" ")[-1]	
	for model in models:
		for i in range(num):
			if models[model][i] != None:
			 	sys.stdout.write(str(models[model][i]))
			sys.stdout.write(",")
		sys.stdout.write("\n")

def fetchAudi():
	models = {}
	for car in audi_info:

		url = car["site"]
		#print url

		response = 0
		while response == 0:
			try:
				response = urllib2.urlopen(url, timeout = 5)
			except IOError, HTTPError:
				print "exception"

		data = json.load(response)   
		classname = url.replace(".carinfo.json","").split("/")[-1].replace("-"," ")
		classname = classname.split(" ")[0].upper() + " " + (" ".join(classname.split(" ")[1:]).title())
		classname = classname.replace("Rs","RS")

		for k in data["items"]: 
			#print k
			if (data["items"][k].has_key("family") and data["items"][k]["family"] == "synthetic.motor"):
				id = data["items"][k]["id"]
				name = data["items"][k]["name"]
				for n in ["Ambiente", "amplified plus", "amplified advanced", "Attraction","S line","Ambition", "cylinder on demand", "amplified", "admired", "flexible fuel", "ultra"]:
					name = name.replace(n,"")

				if name.find("Fahrwerk") != -1:
					continue;
				p = re.compile('\(.*\) kW\(PS\)')
				name = p.sub(' kW', name)
	
				name = name.replace("Coupé".decode('utf-8'),"Coupe")

				if (name.startswith(classname)):
					curr = name
				else:
					curr = classname + " " + name
				curr = curr.replace("  "," ").replace("  "," ").replace("W12 W12","W12")

				#print curr
				if (not models.has_key(curr)):
					models[curr] = [None] * num
				models[curr][brand] = "Audi"
				models[curr][modelname] = curr
				newprice = data["items"][k]["price"].replace("EUR","").replace(".","").replace(",00","").replace(" ","")
				if (models[curr][minPriceEU] > 0):
					models[curr][minPriceEU] = min(models[curr][minPriceEU], newprice)
				else:
					models[curr][minPriceEU] = newprice
				models[curr][fuelConsumptionEUCombined] = data["items"][k]["consumption"].split("l/100")[0].replace(" ", "").replace(",",".")
				models[curr][poweredWheels] = "1" #fwd default
				models[curr][co2Emission] = data["items"][k]["co2emission"].replace("g/km","").replace(" ", "")
				models[curr][fuelType] = "1" #super default
				models[curr][doorCount] = str(car["doors"])
				models[curr][widthMM] = str(car["width"])
				models[curr][heightMM] = str(car["height"])
				models[curr][lengthMM] = str(car["length"])
				models[curr][wheelDistanceMM] = str(car["wheelbase"])
				models[curr][maxSeatCount] = str(car["seats"])
				models[curr][engineAspiration] = "1"
				models[curr][engineLocation] = "1"
				if (curr.find("R8") != -1):	models[curr][engineLocation] = "3"

				newurl = url.replace(".carinfo.json", ".engine_compare.FUCKUALL,FUCKUALL.techdata.html").replace("FUCKUALL",id)
				#print newurl

				response2 = 0
				while response2 == 0:
					try:
						response2 = urllib2.urlopen(newurl, timeout = 5)
					except IOError, HTTPError:
						print "exception"

				lines = response2.readlines()

				if (len(lines) == 0):
					raise Exception("ERROR: got empty file from url: " + url)
	
				for line in lines:
					l = line
					if (l.find("Hubraum : ") != -1):
						models[curr][displacementCCM] = line.split("Hubraum :")[1].split("cm")[0].replace(" ", "")
					if (l.find("Max. Leistung : ") != -1):
						models[curr][maxHorsepower] = line.split("PS)")[0].split("(")[1].replace(" ", "")
						models[curr][maxHorsepowerRRM] = line.split("bei")[1].split("min")[0].split("-")[0].replace(" ", "")
					if (l.find("Max. Drehmoment : ") != -1):
						models[curr][maxTorque] = line.split("Drehmoment :")[1].split("/")[0].replace(" ", "")
						models[curr][maxTorqueRPMLow] = line.split("/")[1].split(" ")[0].split("-")[0].replace(" ", "")
					if (l.find("Gesamtdrehmoment System : ") != -1):
						models[curr][maxTorque] = line.split("Gesamtdrehmoment System :")[1].split("Nm")[0].replace(" ", "")
					if (l.find("Gesamtleistung System") != -1):
						models[curr][maxHorsepower] = line.split(":")[1].split("kW")[0].replace(" ", "")
					if (l.find("Allradantrieb") != -1):
						models[curr][poweredWheels] = "3"
					if (l.find("Getriebeart :") != -1):
						if (l.find("Handschaltgetriebe") != -1): 						models[curr][transmissionType] = "1"
						elif (l.find("S tronic") != -1 or l.find("S-tronic") != -1): 	models[curr][transmissionType] = "3"
						else:															models[curr][transmissionType] = "2"
						try:	
							gc = int(l.split(":")[1].split("-")[0])
							models[curr][gearCount] = str(gc)
						except:
							pass
					if (l.find("Reifen :") != -1):
						tmp = l.split(":")[1].split(";")
						if (l.find("/") == -1):
							print url,newurl,l
							models[curr][wheelsWidthFront] = "225"
							models[curr][wheelsRatioFront] = "55"
							models[curr][wheelsRadiusFront] = "16"
							models[curr][wheelsWidthBack] = models[curr][wheelsWidthFront]
							models[curr][wheelsRatioBack] = models[curr][wheelsRatioFront]
							models[curr][wheelsRadiusBack] = models[curr][wheelsRadiusFront]
							continue
						models[curr][wheelsWidthFront] = tmp[0].split("/")[0].replace(" ", "")
						models[curr][wheelsRatioFront] = tmp[0].split("/")[1].split("R")[0].replace(" ", "").replace("Z", "")
						models[curr][wheelsRadiusFront] = tmp[0].split("/")[1].split("R")[1].split(",")[0].split("(")[0].split("vorn")[0].replace(" ", "")
						if (len(tmp) > 1 and tmp[1].find("/") != -1):
							models[curr][wheelsWidthBack] = tmp[1].split("/")[0]
							models[curr][wheelsRatioBack] = tmp[1].split("/")[1].split("R")[0].replace("Z", "")
							models[curr][wheelsRadiusBack] = tmp[1].split("/")[1].split("R")[1].split(",")[0].split("(")[0].replace("hinten","").replace(" ", "")
						else:
							models[curr][wheelsWidthBack] = models[curr][wheelsWidthFront]
							models[curr][wheelsRatioBack] = models[curr][wheelsRatioFront]
							models[curr][wheelsRadiusBack] = models[curr][wheelsRadiusFront]
					if (l.find("Leergewicht * :") != -1):
						models[curr][weightEU] = line.split("Leergewicht * :")[1].split("kg")[0].split("[")[0].replace(" ", "")
					if (l.find("7-Sitz") != -1):
						models[curr][maxSeatCount] = "7"
					if (l.find("Gepäckraumvolumen :") != -1):
						models[curr][luggageSpaceMin] = line.split("Gepäckraumvolumen :")[1].split("l")[0].replace(" ", "")
						models[curr][luggageSpaceMax] = line.split("Gepäckraumvolumen :")[1].split("l")[0].replace(" ", "")
					if (l.find("Tankinhalt, ca. :") != -1):
						models[curr][fuelTankSize] = line.split("Tankinhalt, ca. :")[1].split("l")[0].replace(" ", "")		
					if (l.find("Kraftstoffart") != -1 and l.find("Diesel") != -1):
						models[curr][fuelType] = "2"
						models[curr][engineAspiration] = "2"
					if (l.find("Motorbauart :") != -1):
						if (l.lower().find("aufladung") != -1): 		models[curr][engineAspiration] = "2"
						elif (l.lower().find("auflademodul") != -1): 	models[curr][engineAspiration] = "3"
						if (curr.lower().find("hybrid") != -1):	models[curr][engineAspiration] = "4"
						if (l.find("Reihen-") != -1): 			models[curr][cylinderLayout] = "1"
						elif (l.find("W12") != -1): 			models[curr][cylinderLayout] = "4"
						else: 									models[curr][cylinderLayout] = "2"
						if (l.find("4-Zylinder") != -1): 		models[curr][cylinderCount] = "4"
						elif (l.find("Vierzylinder") != -1):	models[curr][cylinderCount] = "4"
						elif (l.find("Fünfzylinder") != -1): 	models[curr][cylinderCount] = "5"
						elif (l.find("5-Zylinder") != -1): 		models[curr][cylinderCount] = "5"
						elif (l.find("6-Zylinder") != -1): 		models[curr][cylinderCount] = "6"
						elif (l.find("V6-Motor") != -1): 		models[curr][cylinderCount] = "6"
						elif (l.find("Achtzylinder") != -1): 	models[curr][cylinderCount] = "8"
						elif (l.find("8-Zylinder") != -1): 		models[curr][cylinderCount] = "8"
						elif (l.find("V8-Motor") != -1): 		models[curr][cylinderCount] = "8"
						elif (l.find("Zehnzylinder") != -1): 	models[curr][cylinderCount] = "10"
						elif (l.find("10-Zylinder") != -1):		models[curr][cylinderCount] = "10"
						elif (l.find("W12-Motor") != -1):		models[curr][cylinderCount] = "12"
						else: print url,newurl,l
					if (l.find("Höchstgeschwindigkeit :") != -1):
						models[curr][maxSpeed] = line.split("Höchstgeschwindigkeit :")[1].split("km/h")[0].replace(" ", "")
					if (l.find("Beschleunigung 0-100 km/h :") != -1):
						models[curr][accelerationTo100] = line.split("Beschleunigung 0-100 km/h :")[1].split("s")[0].replace(",", ".").replace(" ", "")

	for model in models:
		for i in range(num):
			if models[model][i] != None:
			 	sys.stdout.write(models[model][i].replace("\n","").replace("\r","").replace("Coupe","Coupé".decode('utf-8')))
			sys.stdout.write(",")
		sys.stdout.write("\n")
							
def fetchBMW():
#todo elasisticity can have - or <br> at automatic 335 coupe or 5er Touring M550d xDrive
#wheelsWidthFront,wheelsRatioFront,wheelsRadiusFront,wheelsWidthBack,wheelsRatioBack,wheelsRadiusBack,
#maxSeatCount,doorCount,luggageSpaceMin,luggageSpaceMax,cylinderLayout
	models = {}
	c2m = {}
	for car in bmw_info:

		url = car["site"]
		curr = ''
		currA = ''
		#print url
		data = urllib2.urlopen(url)
		lines = data.readlines()
		full = "\n".join(lines)		
		p = re.compile('</div>\s*<div')
		full = p.sub('</div><div>', full)
		lines = full.split("\n")

		if (len(lines) == 0):
			raise Exception("ERROR: got empty file from url: " + url)
		
		for line in lines:
			if (line.find("<option value=") != -1):
				model = line.split(">")[1].split("<")[0]
				code = line.split("value=\"")[1].split("\">")[0]
				c2m[code] = model.replace("BMW ","")

			elif (line.find("specContainerDataSheet") != -1):
				code = line.split("datasheet-")[1].split("\">")[0]
				curr = c2m[code]
				currA = curr + " (Automatic)"
				models[curr] = [None] * num
				models[currA] = [None] * num
				models[curr][brand] = "BMW"
				models[currA][brand] = "BMW"
				models[curr][transmissionType] = "1"
				models[currA][transmissionType] = "2"
				models[curr][engineAspiration] = "2"  #turbo engine default
				models[currA][engineAspiration] = "2"  #turbo engine default
				models[curr][engineLocation] = "1" #front engine default
				models[currA][engineLocation] = "1" #front engine default
				models[curr][poweredWheels] = "2" #rwd default
				models[currA][poweredWheels] = "2" #rwd default
				models[curr][adaptiveSuspension] = "0"
				models[currA][adaptiveSuspension] = "0"	
				models[curr][doorCount] = str(car["doors"])
				models[curr][widthMM] = str(car["width"])
				models[curr][heightMM] = str(car["height"])
				models[curr][lengthMM] = str(car["length"])
				models[curr][wheelDistanceMM] = str(car["wheelbase"])
				models[currA][doorCount] = str(car["doors"])
				models[currA][widthMM] = str(car["width"])
				models[currA][heightMM] = str(car["height"])
				models[currA][lengthMM] = str(car["length"])
				models[currA][wheelDistanceMM] = str(car["wheelbase"])
				models[curr][maxSeatCount] = str(car["seats"])
				models[currA][maxSeatCount] = str(car["seats"])
				models[curr][modelname] = curr
				models[currA][modelname] = currA
				if (model.find("xDrive") != -1):
					models[curr][poweredWheels] = "2" 
					models[currA][poweredWheels] = "2"
				shortmodel = curr.split(" ")[0]
				if (shortmodel.split(" ")[0].endswith("i")): 
					models[curr][fuelType] = "1" #super
					models[currA][fuelType] = "1" #super
				else:
					models[curr][fuelType] = "2" #diesel
					models[currA][fuelType] = "2" #diesel

			elif (line.find("CO2-Emission kombiniert in g/km<") != -1):
				tmp = line.split("CO2-Emission kombiniert in g/km<")[1].split("<p>")[1].split("</p>")[0]
				models[curr][co2Emission] = models[currA][co2Emission] = tmp.split("[")[0].split(",")[0]
				if (tmp.find("[") != -1):
					bla = tmp.split("[")[1].split("]")[0].split(",")[0]
					if (bla != "-"): models[currA][co2Emission] = bla
			elif (line.find("Tankinhalt (ca.) in l") != -1):
				tmp = line.split("Tankinhalt (ca.) in l")[1].split("<p>")[1].split("</p>")[0]
				models[curr][fuelTankSize] = models[currA][fuelTankSize] = tmp
			elif (line.find("Leergewicht EU in kg<") != -1):
				tmp = line.split("Leergewicht EU in kg")[1].split("<p>")[1].split("</p>")[0]
				models[curr][weightEU] = models[currA][weightEU] = tmp.split("[")[0].replace(" ","")
				if (tmp.find("[") != -1):
					models[currA][weightEU] = tmp.split("[")[1].split("]")[0].replace(" ","")
			elif (line.find("Leistung in kW (PS) bei 1/min") != -1):
				tmp = line.split("Leistung in kW (PS) bei 1/min")[1].split("<p>")[1].split("</p>")[0]
				tmp2 = tmp.split(")")[0].split("(")[1] 
				tmp3 = tmp.split("/")[1].split("-")[0]
				models[curr][maxHorsepower] = models[currA][maxHorsepower] = tmp2	
				models[curr][maxHorsepowerRRM] = models[currA][maxHorsepowerRRM] = tmp3	
			elif (line.find("Max. Drehmoment (Nm) bei 1/min") != -1):
				tmp = line.split("Max. Drehmoment (Nm) bei 1/min")[1].split("<p>")[1].split("</p>")[0]
				tmp2 = tmp.split("/")[0]
				tmp3 = tmp.split("/")[1].split("-")[0]
				models[curr][maxTorque] = models[currA][maxTorque] = tmp2
				models[curr][maxTorqueRPMLow] = models[currA][maxTorqueRPMLow] = tmp3
			elif (line.find("Zylinder/") != -1):
				tmp = line.split("Zylinder/")[1].split("<p>")[1].split("</p>")[0].split("/")[0]
				models[curr][cylinderCount] = models[currA][cylinderCount] = tmp
				if (tmp == "12"): 				models[curr][engineAspiration] = models[currA][engineAspiration] = "1"
			elif (line.find("Kombiniert in l/100 km") != -1): 
				tmp = line.split("Kombiniert in l/100 km")[1].split("<p>")[1].split("</p>")[0].split("/")[0]
				models[curr][fuelConsumptionEUCombined] = models[currA][fuelConsumptionEUCombined] = tmp.split("[")[0].replace(" ","").replace(",",".")
				if (tmp.find("[") != -1):
					models[currA][fuelConsumptionEUCombined] = tmp.split("[")[1].split("]")[0].replace(" ","").replace(",",".")
				if (models[curr][fuelConsumptionEUCombined] == "-" and line.split("Kombiniert in l/100 km")[1].split("<p>")[1].split("</p>")[0].find("/") != -1):
					tmp = line.split("Kombiniert in l/100 km")[1].split("<p>")[1].split("</p>")[0].split("/")[1]
					models[curr][fuelConsumptionEUCombined] = models[currA][fuelConsumptionEUCombined] = tmp.split("[")[0].replace(" ","").replace(",",".")
					if (tmp.find("[") != -1):
						models[currA][fuelConsumptionEUCombined] = tmp.split("[")[1].split("]")[0].replace(" ","").replace(",",".")
			elif (line.find("Hubraum in cm") != -1): 
				tmp = line.split("Hubraum in cm")[1].split("<p>")[1].split("</p>")[0]
				models[curr][displacementCCM] = models[currA][displacementCCM] = tmp
			elif (line.find("chstgeschwindigkeit in km") != -1): 
				tmp = line.split("chstgeschwindigkeit in km")[1].split("<p>")[1].split("</p>")[0]
				models[curr][maxSpeed] = models[currA][maxSpeed] = tmp.split("[")[0].replace(" ","")
				if (tmp.find("[") != -1):
					models[currA][maxSpeed] = tmp.split("[")[1].split("]")[0].replace(" ","")
			elif (line.find("Beschleunigung 0") != -1): 
				tmp = line.split("Beschleunigung 0")[1].split("<p>")[1].split("</p>")[0]
				models[curr][accelerationTo100] = models[currA][accelerationTo100] = tmp.split("[")[0].replace(" ","").replace(",",".")	
				if (tmp.find("[") != -1):
					models[currA][accelerationTo100] = tmp.split("[")[1].split("]")[0].replace(" ","").replace(",",".")	
			elif (line.find("Elastizit") != -1): 
				tmp = line.split("Elastizit")[1].split("<p>")[1].split("</p>")[0]
				tmp2 = min(float("100" if tmp.split("/")[0] == "-" else tmp.split("/")[0].replace(",",".")), float("100" if tmp.split("/")[1] == "-" else tmp.split("/")[1].replace(",",".")))
				if (tmp2 < 100): models[curr][elasticity80To120] = str(tmp2)
			elif (line.find("Reifengrößen vorne") != -1): 
				tmp = line.split("Reifengrößen vorne")[1].split("<p>")[1].split("</p>")[0]
				try:
					models[curr][wheelsWidthFront] = models[currA][wheelsWidthFront] = tmp.split("[")[0].split("/")[0].replace(" ", "")
					models[curr][wheelsRatioFront] = models[currA][wheelsRatioFront] = tmp.split("[")[0].split("/")[1].split("R")[0].replace(" ", "").replace("Z", "")
					models[curr][wheelsRadiusFront] = models[currA][wheelsRadiusFront] = tmp.split("[")[0].split("/")[1].split("R")[1].split(",")[0].split("(")[0].split(" ")[0].replace(" ", "")
				except:
					pass
				if (tmp.find("[") != -1):
					try:
						models[curr][wheelsWidthFront] = tmp.split("[")[1].split("/")[0].replace(" ", "")
						models[curr][wheelsRatioFront] = tmp.split("[")[1].split("/")[1].split("R")[0].replace(" ", "").replace("Z", "")
						models[curr][wheelsRadiusFront] = tmp.split("[")[1].split("/")[1].split("R")[1].split(",")[0].split("(")[0].split(" ")[0].replace(" ", "")
					except:
						pass
			elif (line.find("Reifengrößen hinten") != -1): 
				tmp = line.split("Reifengrößen hinten")[1].split("<p>")[1].split("</p>")[0]
				try:
					models[curr][wheelsWidthBack] = models[currA][wheelsWidthBack] = tmp.split("[")[0].split("/")[0].replace(" ", "")
					models[curr][wheelsRatioBack] = models[currA][wheelsRatioBack] = tmp.split("[")[0].split("/")[1].split("R")[0].replace(" ", "").replace("Z", "")
					models[curr][wheelsRadiusBack] = models[currA][wheelsRadiusBack] = tmp.split("[")[0].split("/")[1].split("R")[1].split(",")[0].split("(")[0].split(" ")[0].replace(" ", "")
				except:
					pass
				if (tmp.find("[") != -1):
					try:
						models[curr][wheelsWidthBack] = tmp.split("[")[1].split("/")[0].replace(" ", "")
						models[curr][wheelsRatioBack] = tmp.split("[")[1].split("/")[1].split("R")[0].replace(" ", "").replace("Z", "")
						models[curr][wheelsRadiusBack] = tmp.split("[")[1].split("/")[1].split("R")[1].split(",")[0].split("(")[0].split(" ")[0].replace(" ", "")
					except:
						pass

	for model in models:
		if models[model][2] != None and models[model][2] != '-':
			for i in range(num):
				if models[model][i] != None:
				 	sys.stdout.write(models[model][i].strip())
				sys.stdout.write(",")
			sys.stdout.write("\n")


def fetchJaguar():
	sites = [
"http://www.jaguar.de/jaguar-modelle/xe/pricing-specs/index.html",
"http://www.jaguar.de/jaguar-modelle/xf/specifications/index.html",
"http://www.jaguar.de/jaguar-modelle/xj/spezifikationen-preise/index.html",
"http://www.jaguar.de/jaguar-modelle/f-type/specifications/index.html",
"http://www.jaguar.de/jaguar-modelle/f-pace/specifications/index.html"]
	models = {}




	for site in sites:
		print site
		data = urllib2.urlopen(site)
		lines = data.readlines()
		full = "\n".join(lines)		


		matches = re.findall('<a href=".*" dropdown-updater="true" data-updater-regions="modelDropdown,engineDropdown,specifications"', full)
		if len(matches) == 0:
			matches=[site]

		for match in matches:
			newurl = match.replace('<a href="', "http://www.jaguar.de").replace('" dropdown-updater="true" data-updater-regions="modelDropdown,engineDropdown,specifications"', '')
			newurl = urllib.quote(newurl, ':/=&?')
		#	print newurl

			data2 = urllib2.urlopen(newurl)
			lines2 = data2.readlines()
			full2 = "\n".join(lines2)		
	

			for match2 in re.findall('<a href=".*" dropdown-updater="true" data-updater-regions="engineDropdown,specifications"', full2):

				newurl2 = match2.replace('<a href="', "http://www.jaguar.de").replace('" dropdown-updater="true" data-updater-regions="engineDropdown,specifications"', '')
				newurl2 = urllib.quote(newurl2, ':/=&?')
				#print newurl2



				data3 = urllib2.urlopen(newurl2)
				lines3 = data3.readlines()
				full3 = "\n".join(lines3)

				for match3 in re.findall('<a href=".*" dropdown-updater="true" data-updater-regions="specifications"', full3):

					newurl3 = match3.replace('<a href="', "http://www.jaguar.de").replace('" dropdown-updater="true" data-updater-regions="specifications"', '')
					newurl3 = urllib.quote(newurl3, ':/=&?')
					print newurl3



					data4 = urllib2.urlopen(newurl3)
					lines4 = data4.readlines()
					full4 = "\n".join(lines4)	


					name1 = full4.split('<h2 class="nameplateSpecification__intro__header">')[1].split('</h2>')[0]
					name2 = full4.split('<p class="nameplateSpecification__intro__subheader">')[1].split('</p>')[0]
					name2 = name2.replace(' UND', '')
					name2 = name2.replace(' MIT', '')
					name2 = name2.replace('ALLRADANTRIEB', 'AWD')
					name2 = name2.replace('AUTOMATIKGETRIEBE', 'AUTO')
					name2 = name2.replace('Automatikgetriebe', 'AUTO')
					name2 = name2.replace('Automatic', 'AUTO')
					name2 = name2.replace('Supercharged', 'SC')
					name2 = name2.replace('KOMPRESSOR', 'SC')
					name2 = name2.replace('Kompressormotor', 'SC')
					name2 = name2.replace(' LITER ', 'L ')
					name2 = name2.replace(' Liter ', 'L ')
					name2 = name2.replace(' Schaltgetriebe', '')
					name2 = name2.replace(' SCHALTGETRIEBE', '')
					name2 = name2.replace(' L ', 'L ')
					name2 = re.sub(r"[0-9][0-9][0-9] kW", "", name2, re.DOTALL)
					name2 = re.sub(r"\([0-9][0-9][0-9] PS\)", "", name2, re.DOTALL)
					name2 = name2.replace('  ', ' ')
					curr = name1 + " " + name2


					print curr
					models[curr] = [None] * num
					models[curr][brand] = "Jaguar"
					models[curr][modelname] = curr
					models[curr][engineLocation] = "1" #front engine default

					models[curr][minPriceEU] = full4.split('{"XPath":"tcm:Content/custom:accordion/custom:title"} -->PREISE</div>')[1].split(',-')[0].split('>')[-1].replace('.','')
					models[curr][displacementCCM] = full4.split('Hubraum')[1].split('<td>')[1].split('</td>')[0].replace('.','')
					models[curr][maxHorsepower] = full4.split('Max. Leistung kW')[1].split('<td>')[1]
					if models[curr][maxHorsepower].find('(') !=  -1:
						models[curr][maxHorsepower] = models[curr][maxHorsepower].split('(')[1].split(')')[0]
					models[curr][maxHorsepower] = models[curr][maxHorsepower].split('<')[0]
					models[curr][maxHorsepowerRRM] = full4.split('bei U/Min')[1].split('<td>')[1].split('</td>')[0].replace('.','')
					models[curr][maxTorque] = full4.split('Max. Drehmoment')[1].split('<td>')[1].split('</td>')[0].replace('.','').split(" (")[0]
					models[curr][maxTorqueRPMLow] = full4.split('bei U/Min')[2].split('<td>')[1].split('</td>')[0].replace('.','').split(" - ")[0]

					if full4.find('<th>Getriebe</th>') is -1:
						models[curr][transmissionType] = "1"
						models[curr][gearCount] = 6
					else:
						bla = full4.split('<th>Getriebe</th>')[1].split('<td>')[1].split('</td>')[0]
						if bla.find('Automatik') is -1:
							models[curr][transmissionType] = "1"
							models[curr][gearCount] = 6
						else:
							models[curr][transmissionType] = "2"
							models[curr][gearCount] = 8
					if full4.find('Beschleunigung') is -1:
						models[curr][accelerationTo100] = full4.split('Acceleration 0-')[1].split('<td>')[1].split('</td>')[0].replace(',','.').split('(')[1].split(')')[0]
						models[curr][maxSpeed] = full4.split('Top speed ')[1].split('<td>')[1].split('</td>')[0].replace(',','.').split('(')[1].split(')')[0]
					else:
						models[curr][accelerationTo100] = full4.split('Beschleunigung 0-')[1].split('<td>')[1].split('</td>')[0].replace(',','.')
						models[curr][maxSpeed] = full4.split('chstgeschwindigkeit (km')[1].split('<td>')[1].split('</td>')[0].replace(',','.').replace(' abgeregelt','')
					if full4.find('Gesamth') != -1:
						models[curr][heightMM] = full4.split('Gesamth')[1].split('<td>')[1].split('<')[0].replace('.','').strip()
					if full4.find('Gesamtbreite mit') != -1:
						models[curr][widthMM] = full4.split('Gesamtbreite mit')[1].split('<td>')[1].split('<')[0].replace('.','').strip()
					if full4.find('Gesamtbreite inkl') != -1:
						models[curr][widthMM] = full4.split('Gesamtbreite inkl')[1].split('<td>')[1].split('<')[0].replace('.','').strip()
					models[curr][lengthMM] = full4.split('Gesamtl')[1].split('<td>')[1].split('</td>')[0].replace('.','').strip()
					if full4.find('Kofferraumvolumen') != -1:
						models[curr][luggageSpaceMin] = full4.split('Kofferraumvolumen')[1].split('<td>')[1].split('</td>')[0].replace('.','')
						models[curr][luggageSpaceMax] = full4.split('Kofferraumvolumen')[1].split('<td>')[1].split('</td>')[0].replace('.','')
					models[curr][weightEU] = full4.split('Leergewicht')[1].split('<td>')[1].split('</td>')[0].replace('.','')

					models[curr][fuelConsumptionEUCombined] = full4.split('Kombiniert in')[1].split('<td>')[1].split('</td>')[0].replace(',','.')
					models[curr][co2Emission] = full4.split('Emissionen in')[1].split('<td>')[1].split('</td>')[0]
					models[curr][fuelTankSize] = full4.split('Tankinhalt')[1].split('<td>')[1].split('</td>')[0]
					if full4.find('Zylinder/') != -1:
						models[curr][cylinderCount] = full4.split('Zylinder/')[1].split('<td>')[1].split('</td>')[0].split('/')[0]
					else:
						models[curr][cylinderCount] = 4

					if site.find('f-type') != -1:
						models[curr][maxSeatCount] = 2
					else:
						models[curr][maxSeatCount] = 5

					if name2.find(' AWD') != -1:
						models[curr][poweredWheels] = 2
					else:
						models[curr][poweredWheels] = 3

					if name2.find(' SC') != -1:
						models[curr][engineAspiration] = 3
					else:
						models[curr][engineAspiration] = 2

					models[curr][cylinderLayout] = 2

					if name2.find('20d') != -1 or  name2.find('30d') != -1:
						models[curr][fuelType] = 2
					else:
						models[curr][fuelType] = 1




	for model in models:
		for i in range(num):
			if models[model][i] != None:
			 	sys.stdout.write(str(models[model][i]))
			sys.stdout.write(",")
		sys.stdout.write("\n")

			
brand,modelname,weightEU,cylinderCount,displacementCCM,maxHorsepower,maxHorsepowerRRM,maxTorque,maxTorqueRPMLow,maxSpeed,accelerationTo100,elasticity80To120,fuelType,fuelConsumptionEUCombined,co2Emission,fuelTankSize,wheelsWidthFront,wheelsRatioFront,wheelsRadiusFront,wheelsWidthBack,wheelsRatioBack,wheelsRadiusBack,transmissionType,gearCount,engineLocation,poweredWheels,maxSeatCount,minPriceEU,adaptiveSuspension,doorCount,luggageSpaceMin,luggageSpaceMax,engineAspiration,cylinderLayout,widthMM,heightMM,lengthMM,wheelDistanceMM = range(num)

#fetchAudi()
#fetchBMW()
#fetchPorsche()
fetchJaguar()

#39 items
