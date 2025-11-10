#!/usr/bin/python2.7
# -*- coding: UTF-8 -*-
import sys, os, signal, re, thread, threading, types, urllib2, objc, time
from socket import *
from struct import *
from urllib2 import HTTPError

def levdistance(a,b):
	"Calculates the Levenshtein distance between a and b."
	n, m = len(a), len(b)
	if n > m:
		# Make sure n <= m, to use O(min(n,m)) space
		a,b = b,a
		n,m = m,n
	current = range(0, n+1)
	for i in range(m):
		previous, current = current, [i+1]
		for j in range(n):
			add, delete = previous[j+1]+1, current[j]+1
			change = previous[j]
			if a[j] != b[i]:
				change = change + 1
			current.append(min(add, delete, change))
	return current[n]

dict = {}
f = open('DataImport/prices_motortrendcom.txt', 'r')
lines = f.readlines()
for line in lines:
	comp = line.split(" ")
	name = " ".join(comp[0:-4])
	name = name.replace("1-Series ","")
	name = name.replace("2-Series ","")
	name = name.replace("3-Series ","")
	name = name.replace("4-Series ","")
	name = name.replace("5-Series ","")
	name = name.replace("6-Series ","")
	name = name.replace("7-Series ","")
	name = name.replace("8-Series ","")
	name = name.replace("9-Series ","")
	name = name.replace("C-Class ","")
	name = name.replace("CL-Class ","")
	name = name.replace("CLA-Class ","")
	name = name.replace("CLS-Class ","")
	name = name.replace("E-Class ","")
	name = name.replace("GL-Class ","")
	name = name.replace("M-Class ","")
	name = name.replace("S-Class ","")
	name = name.replace("SL-Class ","")
	name = name.replace("SLK-Class ","")
	name = name.replace("SLS-Class ","")
	name = name.replace("G-Class ","")
	name = name.replace("Convertible","Cabrio")
	name = name.replace("Sedan","")

	price = comp[-1].replace("$","").replace("\n","")
	if (comp[-3].find("hp") == -1):
		continue
	if (comp[-4][-1] != 'L'):
		continue	
	bhp = comp[-3].replace("hp","")
	bhp = int(bhp)

	ps = bhp / 10.0 * 1.01386977

	litre = float(comp[-4].replace("L","")) * 10

	key = str(str(int(ps+0.5)) + "|" + str(int(litre)))
	if key in dict:
		dict[key] = dict[key] + [{name : price}]
	else:
		dict[key] = [{name : price}]

f = open('DataImport/data.csv', 'r')
lines = f.readlines()
minratio = 23423
maxratio = 0
for line in lines:
	comp = line.split(",")
	name = comp[0] + " " + comp[1]
	if (len(comp[38]) and int(comp[38]) > 0):
		print ",".join(comp)
	else:
		litre = int((float(comp[4]) / 100.0) + 0.5)
		ps = int((float(comp[5]) / 10.0) + 0.5)
		#print comp

		key = str(str(ps) + "|" + str(litre))
		if key in dict:
			results = dict[key]
			mindistance = 999999
			bestcar = ""
			bestprice = ""
			for res in results:
				carname = res.keys()[0]
				if carname.split(" ")[0] == name.split(" ")[0] and carname.split(" ")[1][0] == name.split(" ")[1][0]:
					distance = levdistance(carname, name)
					if distance < mindistance:
						mindistance = distance
						bestcar = carname
						bestprice = res[carname]
			if (mindistance < 999999) and (mindistance < 15):
				ratio = float(bestprice) / float(comp[27])
				if  ratio > maxratio: maxratio = ratio
				if  ratio < minratio: minratio = ratio
				if (ratio > 0.70 and ratio < 1.1):
					comp[38] = bestprice
					print ",".join(comp)
				else:
					print ",".join(comp)
			else:
				print ",".join(comp)
	
		else:
			print ",".join(comp)

#print minratio, maxratio