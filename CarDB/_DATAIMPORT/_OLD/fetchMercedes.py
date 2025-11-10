#!/usr/bin/python2.7
# -*- coding: UTF-8 -*-

import sys, os, signal, re, thread, threading, types, urllib2, objc, time, json
from struct import *
from urllib2 import HTTPError

num = 40
brand,modelname,weightEU,cylinderCount,displacementCCM,maxHorsepower,maxHorsepowerRPM,maxTorque,maxTorqueRPMLow,maxSpeed,accelerationTo100,elasticity80To120,fuelType,fuelConsumptionEUCombined,co2Emission,fuelTankSize,wheelsWidthFront,wheelsRatioFront,wheelsRadiusFront,wheelsWidthBack,wheelsRatioBack,wheelsRadiusBack,transmissionType,gearCount,engineLocation,poweredWheels,maxSeatCount,minPriceEU,adaptiveSuspension,doorCount,luggageSpaceMin,luggageSpaceMax,engineAspiration,cylinderLayout,widthMM,heightMM,lengthMM,wheelDistanceMM,minPriceUSA,widthInclMirrorMM = range(num)

models = {}


req = urllib2.Request("http://www.mercedes-benz.de/content/germany/mpc/mpc_germany_website/de/home_mpc/passengercars.html", headers={ 'User-Agent': 'Mozilla/5.0' })
lines = urllib2.urlopen(req).read()


modelCodes = re.findall(r'passengercars/home/new_cars/models/[^"]*technicaldata', lines)
modelCode = modelCodes[0]
modelURL = "http://www.mercedes-benz.de/content/germany/mpc/mpc_germany_website/de/home_mpc/" + modelCode + "/models.html"
lines = urllib2.urlopen(urllib2.Request(modelURL, headers={'User-Agent':'Mozilla/5.0'})).read()


modelNames = re.findall(r'info\[0\] = "([^"]*)";', lines)
#print modelNames


for mname in modelNames:
	
	separator = 'info[0] = "' + mname + '";'
	aftersep = lines.split(separator)[1]
	modelNum = re.search(r'info\[1\] = "([0-9]*)";', aftersep).group(1)
	groupNum = re.search(r'dropdown1\[([0-9]*)\] = dropdown2;', aftersep).group(1)
	groupNum = str(int(groupNum)+1)

	curr = mname.strip()
	currA = curr + " (Automatic)"

	models[curr] = [None] * num
	models[currA] = [None] * num
	models[curr][brand] = "Mercedes"
	models[curr][modelname] = curr
	models[currA][modelname] = currA
	models[curr][transmissionType] = "1" 	#default manual
	models[currA][transmissionType] = "2"	#default auto
	models[curr][cylinderCount] = "0"
	models[curr][displacementCCM] = "0"



	dataURL = "http://www.mercedes-benz.de/content/germany/mpc/mpc_germany_website/de/home_mpc/" + modelCode + "/models.ajax.component.filtertable.tabsystem_0001_tabcontent_0001." + groupNum + "." + modelNum + ".0.0.0.0.ngrb.html"
	#print dataURL
	datalines = urllib2.urlopen(urllib2.Request(dataURL, headers={'User-Agent':'Mozilla/5.0'})).read()




	tmp = datalines.split(">Zylinderanordnung")[1].split("<div>")[1].split("</div>")[0].strip()
	if (len(tmp) > 1):
		layout = tmp[0]
		models[curr][cylinderLayout] = layout
	zyl = tmp[1:]
	models[curr][cylinderCount] = zyl


	hubr = datalines.split(">Hubraum")[1].split("<div>")[1].split("</div>")[0].strip().replace('.','')
	models[curr][displacementCCM] = hubr

	leistungstring = datalines.split(">Nennleistung")[1].split("<div>")[1].split("</div>")[0].strip()
	if len(leistungstring) > 2:
		ps = leistungstring.split('/')[0].replace('– (','').split('–')[0]
		ps = ps.split(" [")[0]
		ps = str(int(int(ps) * 1.35962162 +0.5))
		models[curr][maxHorsepower] = ps

		rpm = leistungstring.replace('/ ','/').replace('– (','').replace('–','/').split('/')[1].split('-')[0].split(' ')[0].replace(')','').replace('.','')
		models[curr][maxHorsepowerRPM] = rpm

		nm = leistungstring.split('/')[0].replace('– (','').split('–')[0]
		models[curr][maxTorque] = nm

		nmrpm = leistungstring.replace('/ ','/').replace('– (','').replace('–','/').split('/')[1].split('-')[0].split(' ')[0].replace(')','').replace('.','')
		models[curr][maxTorqueRPMLow] = nmrpm
		

	kraf = datalines.split(">Kraftstoff <")[1].split("<div>")[1].split("</div>")[0].strip()
	if (kraf.find('Diesel') != -1):
		kraf = 2
	else:
		kraf = 1
	models[curr][fuelType] = kraf


	tank = datalines.split(">Tankinhalt")[1].split("<div>")[1].split("</div>")[0].strip().split('/')[0].replace('k. A. (k. A.)','')
	models[curr][fuelTankSize] = tank

	luggageMin = datalines.split(">Kofferraumvolumen")[1].split("<div>")[1].split("</div>")[0].replace('– (','').replace('k. A.','').strip().split('–')[0]
	luggageMax = luggageMin
	if (datalines.split(">Kofferraumvolumen")[1].split("<div>")[1].split("</div>")[0].replace('– (','').find('–') != -1):
		luggageMax = datalines.split(">Kofferraumvolumen")[1].split("<div>")[1].split("</div>")[0].replace('– (','').split('–')[1].replace(')','').replace('.','')
	models[curr][luggageSpaceMin] = luggageMin
	models[curr][luggageSpaceMax] = luggageMax

	tmp = datalines.split(">Antrieb")[1].split("<div>")[1].split("</div>")[0].strip()
	if (tmp.find('Allrad') != -1):
		antr = 3
	elif (tmp.find('Hinter') != -1):
		antr = 2
	else:
		antr = 1
	models[curr][poweredWheels] = antr		

	
	tmp = datalines.split(">Bereifung/Räder vorn")[1].split("<div>")[1].split("</div>")[0].strip()
	if tmp.find("/") != -1:
		rv1 = tmp.split('/')[0]
		rv2 = tmp.split('/')[1].split(' ')[0]
		rv3 = tmp.split('R')[1].lstrip().split(' ')[0]
		models[curr][wheelsWidthFront] = rv1
		models[curr][wheelsRatioFront] = rv2
		models[curr][wheelsRadiusFront] = rv3
	tmp = datalines.split(">Bereifung/Räder hinten")[1].split("<div>")[1].split("</div>")[0].strip()
	if tmp.find("/") != -1:
		rr1 = tmp.split('/')[0]
		rr2 = tmp.split('/')[1].split(' ')[0]
		rr3 = tmp.split('R')[1].lstrip().split(' ')[0]
		models[curr][wheelsWidthBack] = rv1
		models[curr][wheelsRatioBack] = rv2
		models[curr][wheelsRadiusBack] = rv3


	coline = datalines.split(">CO2-Emissionen")[1].split("<div>")[1].split("</div>")[0].strip()
	if coline.find("(") != -1:
		tmp = coline.split("(")[1].split("-")[0]
		models[currA][co2Emission] = tmp
	tmp = coline.split("(")[0].split("-")[0]
	models[curr][co2Emission] = tmp		


	gewichtsline = datalines.split(">Leergewicht")[1].split("<div>")[1].split("</div>")[0].strip()
	if gewichtsline.find("(") != -1:
		tmp = gewichtsline.split("(")[1].split("-")[0].split("/")[0].replace(".","").replace("-","")
		if len(tmp) > 2:
			models[currA][weightEU] = tmp
	tmp = gewichtsline.split("(")[0].split("-")[0].split("/")[0].replace(".","").replace("-","")
	models[curr][weightEU] = tmp
	#print gewichtsline




	#print datalines.split(">Kraftstoffverbrauch kombiniert")[1].split("<div>")[1].split("</div>")[0].strip()
	#print datalines.split(">Höchstgeschwindigkeit")[1].split("<div>")[1].split("</div>")[0].strip()
	#tmp = datalines.split(">Beschleunigung")[1].split("<div>")[1].split("</div>")[0].strip()
	#if tmp.find('(') != -1:
	#	tmp2 = tmp.split('(')
	




	#copy over from manual to auto
	for i in range(num):
		if models[currA][i] == None:
			models[currA][i] = models[curr][i]

	getrline = datalines.split(">Getriebe")[1].split("<div>")[1].split("</div>")[0].strip()
	#print getrline
	if getrline.find(" (") != -1: #both manual and auto
		firstmodel = getrline.split(" (")[0]
		secondmodel = getrline.split(" (")[1]
		if firstmodel == "–": #manual doesnt exist
			del models[curr]
			if secondmodel.find("DCT") != -1:
				models[currA][transmissionType] = "2"
			models[currA][gearCount] = ''.join(re.findall(r'\d+', secondmodel))
		elif firstmodel.find("Schaltgetriebe") != -1: #manual is manual
			models[curr][gearCount] = firstmodel[0]
		else:
			exit(1)
	else:
		if getrline.find("Schaltgetriebe") != -1:	# its manual like promised
			models[curr][gearCount] = getrline[0]
		else:										# our only model is actually auto
			models[curr][transmissionType] = "1"
			if getrline.find("DCT") != -1:
				models[curr][transmissionType] = "2"
			models[curr][gearCount] = ''.join(re.findall(r'\d+', getrline))
			models[curr][modelname] = models[currA][modelname]
		del models[currA]



for model in models:
	for i in range(num):
		if models[model][i] != None:
			sys.stdout.write(str(models[model][i]))
		sys.stdout.write(",")
	sys.stdout.write("\n")



# passengercars/home/new_cars/models/cla-class/c117/facts_/technicaldata/models.ajax.component.filtertable.tabsystem_0001_tabcontent_0001.6.3.0.0.0.0.ngrb.html
# 
# 
# AMG GT
# http://www.mercedes-benz.de/content/germany/mpc/mpc_germany_website/de/home_mpc/passengercars/home/new_cars/models/mercedes_amg_gt/c190/facts_/technicaldata/models.ajax.component.filtertable.tabsystem_0001_tabcontent_0001.24.1.0.0.0.0.ngrb.html
# AMG GT S
# http://www.mercedes-benz.de/content/germany/mpc/mpc_germany_website/de/home_mpc/passengercars/home/new_cars/models/mercedes_amg_gt/c190/facts_/technicaldata/models.ajax.component.filtertable.tabsystem_0001_tabcontent_0001.24.2.0.0.0.0.ngrb.html
# 
# 
# http://www.mercedes-benz.de/content/germany/mpc/mpc_germany_website/de/home_mpc/passengercars/home/new_cars/models/mercedes-maybach/mercedes-maybach_s-class/facts_/technicaldata/models.ajax.component.filtertable.tabsystem_0001_tabcontent_0001.24.1.0.0.0.0.ngrb.html
# http://www.mercedes-benz.de/content/germany/mpc/mpc_germany_website/de/home_mpc/passengercars/home/new_cars/models/mercedes-maybach/mercedes-maybach_s-class/facts/technicaldata/models.ajax.component.filtertable.tabsystem_0001_tabcontent_0001.25.2.0.25.1.0.25.2.0.25.3.0.0.ngrb.html