#!/usr/bin/python2.3
# -*- coding: UTF-8 -*-


import os
import sys


prices = {}
years = {}

for root, subFolders, files in os.walk("~/Desktop/www.cars.com"):
	#for folder in subFolders:
	#	print "%s has subdirectory %s" % (root, folder)

	for filename in files:
		filePath = os.path.join(root, filename)
		if filePath.endswith("index.html") and filePath.find("consumer-reviews") == -1:
			with open( filePath, 'r' ) as f:
				data = f.read()
				if data.find("View, Compare &amp; Price</h2>") != -1 and data.find("<h1 class=\"inline-link\" itemprop=\"name\">") != -1:
			
					print filePath

					yearandname = data.split("<h1 class=\"inline-link\" itemprop=\"name\">")[1].split("</h1>")[0].split("&nbsp;")
					year = yearandname[0]
					name = " ".join(yearandname[1:])

					bla = data.split("View, Compare &amp; Price</h2>")[1].split("Side-by-Side")[0].split("<div class=\"row rule-bottom light\">")
					for shit in bla:
						if shit.find("See specs for optional engines") == -1:
							model = shit.split("col10\">")[1].split("<br>")[0].replace("<p>","").replace("\n","").strip()
							add = shit.split("\"col12\">")[1].split("/>")[1].split("<br")[0].strip()
							price = shit.split("\"col8\">")[1].split("/")[0].replace(",","").replace("\n","").strip()
							blam = name, model, add
							dink = " ".join(blam)
							prices[dink] = price
							years[dink] = year

for key in prices:
	if int(years[key].replace(".5","")) > 2003:
		print key, years[key], prices[key]





