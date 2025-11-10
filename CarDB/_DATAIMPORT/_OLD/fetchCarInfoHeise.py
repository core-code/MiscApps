#!/usr/bin/python2.7
# -*- coding: UTF-8 -*-
import sys, os, signal, re, thread, threading, types, urllib2, objc, time
from socket import *
from struct import *
from urllib2 import HTTPError

num = 38
brand,modelname,weightEU,cylinderCount,displacementCCM,maxHorsepower,maxHorsepowerRRM,maxTorque,maxTorqueRPMLow,maxSpeed,accelerationTo100,elasticity80To120,fuelType,fuelConsumptionEUCombined,co2Emission,fuelTankSize,wheelsWidthFront,wheelsRatioFront,wheelsRadiusFront,wheelsWidthBack,wheelsRatioBack,wheelsRadiusBack,transmissionType,gearCount,engineLocation,poweredWheels,maxSeatCount,minPriceEU,adaptiveSuspension,doorCount,luggageSpaceMin,luggageSpaceMax,engineAspiration,cylinderLayout,widthMM,heightMM,lengthMM,wheelDistanceMM = range(num)
brandnames = ["Alfa Romeo", "Aston Martin", "Audi", "Bentley", "BMW", "Cadillac", "Chevrolet", "Citroen", "Dacia", "Ferrari", "Fiat", "Ford", "Honda", "Hyundai", "Infiniti", "Jaguar", "Jeep", "Kia", "Lada", "Lamborghini", "Lancia", "Land Rover", "Lexus", "Lotus", "Maserati", "Mazda", "McLaren", "Mercedes", "Mini", "Mitsubishi", "Morgan", "Nissan", "Opel", "Peugeot", "Porsche", "Renault", "Rolls-Royce", "Seat", "Skoda", "Smart", "SsangYong", "Subaru", "Suzuki", "Toyota", "Volvo", "VW"]
models = {}


numbers = []
data = urllib2.urlopen("http://www.heise.de/autos/neuwagenkatalog/liste.jsp?start=0")
lines = data.readlines()
full = "\n".join(lines)		
bla = full.split("autoid=")
for res in bla[1:]:
	numbers.append(res.split("\"")[0])
i = 20
while i < 2260:
	data = urllib2.urlopen("http://www.heise.de/autos/neuwagenkatalog/liste.jsp?start=" + str(i))
	lines = data.readlines()
	full = "\n".join(lines)		
	bla = full.split("autoid=")
	for res in bla[1:]:
		numbers.append(res.split("&")[0])
	i+=20


for i in numbers:
	data = urllib2.urlopen("http://www.heise.de/autos/neuwagenkatalog/anzeige.jsp?autoid="+str(i))
	lines = data.readlines()

	full = "\n".join(lines)		
	if (full.find("<caption>") != -1):
		print "success at "+str(i)
		brandmodel = full.split("<caption>")[1].split("</caption>")[0].strip()
		t = filter(lambda x: brandmodel.startswith(x), brandnames)
		if len(t):
			br = t[0]
			curr = brandmodel.replace(br,"").strip()
			models[curr] = [None] * num
			models[curr][brand] = br
			models[curr][modelname] = curr
	#		models[curr][adaptiveSuspension] = 0
	#		models[curr][elasticity80To120] = 0
	#		models[curr][engineLocation] = 0
	#		models[curr][engineAspiration] = 0

			if (full.find("Preis</th>") != -1):
				models[curr][minPriceEU] = full.split("Preis</th>")[1].split(">")[1].split("<")[0].replace("Euro","").replace(".","").strip()
			if (full.find("Türen</th>") != -1):
				models[curr][doorCount] = full.split("Türen</th>")[1].split(">")[1].split("<")[0].strip()
			if (full.find("Sitze</th>") != -1):
				models[curr][maxSeatCount] = full.split("Sitze</th>")[1].split(">")[1].split("<")[0].strip()
			if (full.find("Länge</th>") != -1):
				models[curr][lengthMM] = full.split("Länge</th>")[1].split(">")[1].split("<")[0].replace("mm","").replace(".","").strip()
			if (full.find("Breite</th>") != -1):
				models[curr][widthMM] = full.split("Breite</th>")[1].split(">")[1].split("<")[0].replace("mm","").replace(".","").strip()
			if (full.find("Höhe</th>") != -1):
				models[curr][heightMM] = full.split("Höhe</th>")[1].split(">")[1].split("<")[0].replace("mm","").replace(".","").strip()
			if (full.find("Radstand</th>") != -1):
				models[curr][wheelDistanceMM] = full.split("Radstand</th>")[1].split(">")[1].split("<")[0].replace("mm","").replace(".","").strip()
			if (full.find("Motorbauart</th>") != -1):
				tmp = full.split("Motorbauart</th>")[1].split(">")[1].split("<")[0].strip()
				if (models[curr][modelname].find("W12") != -1):
					models[curr][cylinderLayout] = 4
				elif (tmp == "Reihenmotor"):
					models[curr][cylinderLayout] = 1
				elif (tmp == "V-Motor"):
					models[curr][cylinderLayout] = 2
				elif (tmp == "Boxermotor"):
					models[curr][cylinderLayout] = 3
				else:
					print tmp
					models[curr][cylinderLayout] = 99
			if (full.find("<td>Hybrid</td>") != -1):
				models[curr][engineAspiration] = 4
			elif (models[curr][modelname].find("TFSI") != -1 or models[curr][modelname].find("TSI") != -1 or models[curr][modelname].find("Turbo") != -1):
				models[curr][engineAspiration] = 2
			elif (models[curr][modelname].find("Kompressor") != -1 or models[curr][modelname].find("Supercharged") != -1):
				models[curr][engineAspiration] = 3
			if (full.find("Kraftstoff</th>") != -1):
				tmp = full.split("Kraftstoff</th>")[1].split(">")[1].split("<")[0].strip()
				if (tmp == "Super"):
					models[curr][fuelType] = 1
				elif (tmp == "Normal"):
					models[curr][fuelType] = 1
				elif (tmp == "Super Plus" or tmp == "Super plus"):
					models[curr][fuelType] = 1
				elif (tmp == "Diesel"):
					models[curr][fuelType] = 2
				else:
					print tmp
					models[curr][fuelType] = 99
			if (full.find("Zylinder</th>") != -1):
				models[curr][cylinderCount] = full.split("Zylinder</th>")[1].split(">")[1].split("<")[0].strip()
			if (full.find("Hubraum</th>") != -1):
				models[curr][displacementCCM] = full.split("Hubraum</th>")[1].split(">")[1].split("<")[0].replace("ccm","").replace(".","").strip()
			if (full.find("(PS)</th>") != -1):
				models[curr][maxHorsepower] = full.split("(PS)</th>")[1].split(">")[1].split("<")[0].strip()			
			if (full.split("Drehmoment</th>")[0].find("bei</th>") != -1):
				models[curr][maxHorsepowerRRM] = full.split("Drehmoment</th>")[0].split("bei</th>")[1].split(">")[1].split("<")[0].replace("U/min","").replace(".","").strip()
			if (full.find("Drehmoment</th>") != -1):
				models[curr][maxTorque] = full.split("Drehmoment</th>")[1].split(">")[1].split("<")[0].replace("Nm","").replace(".","").strip()
			if (full.split("Drehmoment</th>")[1].find("bei</th>") != -1):
				models[curr][maxTorqueRPMLow] = full.split("Drehmoment</th>")[1].split("bei</th>")[1].split(">")[1].split("<")[0].replace("U/min","").replace(".","").strip()
			if (full.find("Antrieb</th>") != -1):
				tmp = full.split("Antrieb</th>")[1].split(">")[1].split("<")[0].strip()
				if (tmp.find("Allrad") != -1):
					models[curr][poweredWheels] = 3
				elif (tmp == "Heckantrieb"):
					models[curr][poweredWheels] = 2
				elif (tmp == "Frontantrieb"):
					models[curr][poweredWheels] = 1
				else:
					print tmp
					models[curr][poweredWheels] = 99
			if (full.find("Getriebe</th>") != -1):
				tmp = full.split("Getriebe</th>")[1].split(">")[1].split("<")[0].strip()
				if (tmp == "Schaltung"):
					models[curr][transmissionType] = 1
				elif (tmp == "Doppelkupplung"):
					models[curr][transmissionType] = 3
				else:
					models[curr][transmissionType] = 2
			if (full.find("Gänge</th>") != -1):
				models[curr][gearCount] = full.split("Gänge</th>")[1].split(">")[1].split("<")[0].strip()
			if (full.find("vorn</th>") != -1):
				tmp = full.split("vorn</th>")[1].split(">")[1].split("<")[0].strip()
				if (tmp.find("/") != -1):
					models[curr][wheelsWidthFront] = tmp.split("/")[0].replace("P","")				
					models[curr][wheelsRatioFront] = tmp.split("/")[1].split("R")[0].replace("Z","").replace("F","")	
					models[curr][wheelsRadiusFront] = tmp.split("/")[1].split("R")[1].replace("Z","").replace("F","")	
			if (full.find("hinten</th>") != -1):
				tmp = full.split("hinten</th>")[1].split(">")[1].split("<")[0].strip()
				if (tmp.find("/") != -1):
					models[curr][wheelsWidthBack] = tmp.split("/")[0].replace("P","")					
					models[curr][wheelsRatioBack] = tmp.split("/")[1].split("R")[0].replace("Z","").replace("F","")
					models[curr][wheelsRadiusBack] = tmp.split("/")[1].split("R")[1].replace("Z","").replace("F","")	
			if (full.find("geschwindigkeit</th>") != -1):
				models[curr][maxSpeed] = full.split("geschwindigkeit</th>")[1].split(">")[1].split("<")[0].replace("km/h","").strip()
			if (full.find("km/h</th>") != -1):
				models[curr][accelerationTo100] = full.split("km/h</th>")[1].split(">")[1].split("<")[0].replace("Sek.","").strip()
			if (full.find("gesamt</th>") != -1):
				models[curr][fuelConsumptionEUCombined] = full.split("gesamt</th>")[1].split(">")[1].split("<")[0].replace("Liter/100 km","").strip()
			if (full.find("Ausstoß</th>") != -1):
				models[curr][co2Emission] = full.split("Ausstoß</th>")[1].split(">")[1].split("<")[0].replace("g/km","").strip()
			if (full.find("Leergewicht</th>") != -1):
				models[curr][weightEU] = full.split("Leergewicht</th>")[1].split(">")[1].split("<")[0].replace("kg","").replace(".","").strip()
			if (full.find("Kofferraumvolumen</th>") != -1):
				models[curr][luggageSpaceMin] = full.split("Kofferraumvolumen</th>")[1].split(">")[1].split("<")[0].replace("Liter","").replace(".","").strip()
				models[curr][luggageSpaceMax] = full.split("Kofferraumvolumen</th>")[1].split(">")[1].split("<")[0].replace("Liter","").replace(".","").strip()
			if (full.find("Tankvolumen</th>") != -1):
				models[curr][fuelTankSize] = full.split("Tankvolumen</th>")[1].split(">")[1].split("<")[0].replace("Liter","").replace(".","").strip()


for model in models:
	if 	(models[model][modelname].find(" (ab ") != -1):	models[model][modelname] = models[model][modelname].split(" (ab ")[0]
	models[model][modelname] = models[model][modelname].replace("VTi","VTI")
	models[model][modelname] = models[model][modelname].replace("HDi","HDI")
	models[model][modelname] = models[model][modelname].replace("Multijet","MultiJet")
	models[model][modelname] = models[model][modelname].replace("Twinair","TwinAir")
	models[model][modelname] = models[model][modelname].replace("Multiair","MultiAir")
	models[model][modelname] = models[model][modelname].replace("Sportshift","SportShift")
	models[model][modelname] = models[model][modelname].replace("Up!","Up")
	models[model][modelname] = models[model][modelname].replace("TDCi","TDCI")
	models[model][modelname] = models[model][modelname].replace("TiVCT","TIVCT")
	models[model][modelname] = models[model][modelname].replace("iVTEC","IVTEC")
	models[model][modelname] = models[model][modelname].replace("iDTEC","IDTEC")
	models[model][modelname] = models[model][modelname].replace("CRDi","CRDI")
	models[model][modelname] = models[model][modelname].replace("Pro_Cee","pro_cee")
	models[model][modelname] = models[model][modelname].replace("4Matic","4MATIC")
	models[model][modelname] = models[model][modelname].replace("4Motion","4MOTION")
	models[model][modelname] = models[model][modelname].replace("-Tronic","-TRONIC")
	models[model][modelname] = models[model][modelname].replace(" Doppelkabine","")
	models[model][modelname] = models[model][modelname].replace(" Langkabine","")
	models[model][modelname] = models[model][modelname].replace(" Kurzkabine","")
	models[model][modelname] = models[model][modelname].replace(" Einzelkabine","")
	models[model][modelname] = models[model][modelname].replace(" Extrakabine","")
	models[model][modelname] = models[model][modelname].replace("dCi","DCI")
	models[model][brand] = models[model][brand].replace("VW", "Volkswagen")
	models[model][modelname] = models[model][modelname].replace("mit Competition-Paket","Competition-Paket)")

	if ((models[model][brand] == "Alfa Romeo") or (models[model][brand] == "Volkswagen")):
		models[model][engineAspiration] = 2

	if 	((models[model][modelname].find("Dreitürer") != -1) or
		(models[model][modelname].find("3Türer") != -1)):
		models[model][modelname] = models[model][modelname].replace("Dreitürer","").replace("3Türer","").strip()

	if 	((models[model][modelname].find("Viertürer") != -1) or
		(models[model][modelname].find("4Türer") != -1)):
		models[model][modelname] = models[model][modelname].replace("Viertürer","").replace("4Türer","").strip()

	if 	((models[model][modelname].find("Fünftürer") != -1) or
		(models[model][modelname].find("5Türer") != -1)):
		models[model][modelname] = models[model][modelname].replace("Fünftürer","").replace("5Türer","").strip()
	models[model][modelname].replace("  "," ")

	if (models[model][fuelType] == 2):
		models[model][engineAspiration] = 2
	if ((models[model][modelname].find("TFSI") != -1) or (models[model][modelname].find("TSI") != -1)):
		models[model][engineAspiration] = 2

	if (models[model][modelname].lower().find("2.0 sidi") != -1):
		models[model][displacementCCM] = 1998
	if 	((models[model][modelname].find("R8 ") != -1) or
		(models[model][modelname].find("4C") != -1) or
		(models[model][modelname].lower().find("boxster") != -1) or
		(models[model][modelname].lower().find("cayman") != -1) or
		(models[model][modelname].find("918") != -1) or
		(models[model][modelname].find("458") != -1) or
		(models[model][modelname].lower().find("laferrari") != -1) or
		(models[model][modelname].lower().find("elise") != -1) or
		(models[model][modelname].lower().find("zonda") != -1) or
		(models[model][modelname].lower().find("agera") != -1) or
		(models[model][modelname].lower().find("huayra") != -1) or
		(models[model][modelname].lower().find("veyron") != -1) or
		(models[model][modelname].lower().find("aventador") != -1) or
		(models[model][modelname].lower().find("hurac") != -1)):
		models[model][engineLocation] = 2
	elif ((models[model][modelname].find("911") != -1) or
		(models[model][modelname].lower().find("twingo") != -1) or
		(models[model][modelname].lower().find("fortwo") != -1) or
		(models[model][modelname].lower().find("model s") != -1) or
		(models[model][modelname].lower().find("i3") != -1)):
		models[model][engineLocation] = 3
	else:
		models[model][engineLocation] = 1


	for i in range(num):
		if models[model][i] != None:
			newstr = str(models[model][i]);
			newstr = newstr.replace(",",".")
			if (len(newstr) == 1):
				newstr = newstr.replace("-","")
#			if (len(newstr) == 0): newstr = "0"
		 	sys.stdout.write(newstr)
		sys.stdout.write(",")
	sys.stdout.write(",0,\n")

			

