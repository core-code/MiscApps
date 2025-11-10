
import os
import sys


prices = {}
years = {}

for root, subFolders, files in os.walk("~/Desktop/www.motortrend.com/cars/"):
	#for folder in subFolders:
	#	print "%s has subdirectory %s" % (root, folder)

	for filename in files:
		filePath = os.path.join(root, filename)
		if filePath.endswith("index.html"):
			with open( filePath, 'r' ) as f:
				data = f.read()

				if data.find("itemprop=\"name\"") != -1 and data.find("class=\"options-chart\">") != -1:
			

					yearandname = data.split("itemprop=\"name\"")[1].split(">")[1].split("<")[0].replace(" Overview","").split(" ")
					year = yearandname[0]
					name = " ".join(yearandname[1:])



					bla = data.split("<tr class=\"options-titles\">")[1].split("<div class=\"options-footer\">")[0].split("class=\"opt-row")
					for shit in bla:
						if shit.find("\"opt-col1\"><a href=") != -1:
							model = shit.split("\"opt-col1\"><a href=")[1].split(">")[1].split("<")[0].strip()
							add = shit.split("\"opt-col2\">")[1].split("</")[0].strip()
							price = shit.split("\"opt-col4\">")[1].split("</")[0].replace(",","").strip()

							if (add.find("$") != -1 and price.find("$") == -1):
								newadd = price
								price = add.replace(",","")
								add = newadd
							if add.find("city") !=-1:
								add = ""
							blam = name, model, add
							dink = " ".join(blam)
							dink = dink.strip()
							prices[dink] = price
							years[dink] = year


for key in prices:
	if int(years[key]) > 2003:
		print key, years[key], prices[key]





