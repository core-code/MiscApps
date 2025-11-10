#!/usr/bin/python2.7
# -*- coding: UTF-8 -*-
import sys, os, signal, re, thread, threading, types, urllib2, objc, time, json, re, urllib
from socket import *
from struct import *
from urllib2 import HTTPError

num = 38



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
					name2 = name2.replace('AUTOMATIK', 'AUTO')
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
					name2 = re.sub(r"[0-9][0-9][0-9]", "", name2, re.DOTALL)


					curr = name1 + " " + name2
					curr = curr.replace('  ', ' ')
					curr = curr.replace('  ', ' ')
					curr = curr.replace('  ', ' ')
					curr = curr.replace(' S S ', ' S ')
					curr = curr.replace(' SC SC ', ' SC ')
					curr = curr.replace('CABRIOLET F‑TYPE', 'F‑TYPE CABRIOLET')
					curr = curr.replace('CABRIOLET F-TYPE', 'F‑TYPE CABRIOLET')

					curr = re.sub(r"COUP.. ", "", curr, re.DOTALL)
					curr = curr.strip()

					#print curr
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
					models[curr][maxHorsepowerRRM] = full4.split('bei U/Min')[1].split('<td>')[1].split('</td>')[0].replace('.','').split("-")[0].strip()
					models[curr][maxTorque] = full4.split('Max. Drehmoment')[1].split('<td>')[1].split('</td>')[0].replace('.','').split(" (")[0].strip()
					models[curr][maxTorqueRPMLow] = full4.split('bei U/Min')[2].split('<td>')[1].split('</td>')[0].replace('.','').split("-")[0].strip()

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
					models[curr][maxSpeed] = models[curr][maxSpeed].split('<')[0]
					if models[curr][maxSpeed].find('(') != -1:
						models[curr][maxSpeed] = models[curr][maxSpeed].split('(')[1].split(')')[0]
					if models[curr][accelerationTo100].find('(') != -1:
						models[curr][accelerationTo100] = models[curr][accelerationTo100].split('(')[1].split(')')[0]

					if full4.find('Radstand (') != -1:
						models[curr][wheelDistanceMM] = full4.split('Radstand (')[1].split('<td>')[1].split('<')[0].replace('.','').strip()

					if full4.find('Gesamth') != -1:
						models[curr][heightMM] = full4.split('Gesamth')[1].split('<td>')[1].split('<')[0].replace('.','').strip()
					elif full4.find('inkl. Antenne') != -1:
						models[curr][heightMM] = full4.split('inkl. Antenne')[1].split('<td>')[1].split('<')[0].replace('.','').strip()
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
					models[curr][co2Emission] = full4.split('Emissionen in')[1].split('<td>')[1].split('</td>')[0].split('-')[0]
					models[curr][fuelTankSize] = full4.split('Tankinhalt')[1].split('<td>')[1].split('</td>')[0].replace(',','.')
					if full4.find('Zylinder/') != -1:
						models[curr][cylinderCount] = full4.split('Zylinder/')[1].split('<td>')[1].split('</td>')[0].split('/')[0]
					else:
						models[curr][cylinderCount] = 4

					if site.find('f-type') != -1:
						models[curr][maxSeatCount] = 2
						models[curr][doorCount] = 2
					elif site.find('f-pace') != -1:
						models[curr][maxSeatCount] = 5
						models[curr][doorCount] = 5
					else:
						models[curr][maxSeatCount] = 5
						models[curr][doorCount] = 4

					if curr.find(' AWD') != -1:
						models[curr][poweredWheels] = 2
					else:
						models[curr][poweredWheels] = 3

					if name2.find(' SC') != -1:
						models[curr][engineAspiration] = 3
					else:
						models[curr][engineAspiration] = 2

					models[curr][cylinderLayout] = 2

					if name2.find('20d') != -1 or  name2.find('30d') != -1 or name2.find('DIESEL') != -1:
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


fetchJaguar()

#39 items
