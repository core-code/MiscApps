#!/usr/bin/python
import sys
import urllib2
import json


splitters = sys.argv[1]
url = sys.argv[2]
headers = {'User-Agent' : 'Mozilla'}
if len(sys.argv) > 3:
	arg = sys.argv[3]
	headers = json.loads(arg)

if len(sys.argv) > 4:
	encoding = sys.argv[4]
else:
	encoding = ""

try: 
	req = urllib2.Request(url, None, headers)
	response = urllib2.urlopen(req)
	text = response.read()
	if len(encoding) > 1:
		text = text.decode(encoding)
		if len(text) < 1:
			raise Exception('conversion to encoding failed {}'.format(encoding))
	
	splitarray = json.loads(splitters)
	for splitdict in splitarray:
		splitter = splitdict["s"]
		index = int(splitdict["i"])
		text = text.split(splitter)[index]

except Exception:
	import traceback
	text = 'generic exception: ' + traceback.format_exc()

print text

