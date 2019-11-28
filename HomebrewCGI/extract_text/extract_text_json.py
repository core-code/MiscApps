#!/usr/bin/python
import sys
import urllib2
import json


keypath = sys.argv[1]
url = sys.argv[2]
headers = {'User-Agent' : 'Mozilla'}
if len(sys.argv) > 3:
	arg = sys.argv[3]
	headers = json.loads(arg)
	

try: 
 	req = urllib2.Request(url, None, headers)
 	response = urllib2.urlopen(req)
 	text = response.read()
	js = json.loads(text)
	keypatharray = json.loads(keypath)

	for item in keypatharray:
		js = js[item]

except Exception:
	import traceback
	js = 'generic exception: ' + traceback.format_exc()

print str(js)