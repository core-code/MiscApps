#!/usr/bin/python
import cgi
import urllib2
import json
import base64


form = cgi.FieldStorage()
url = form.getvalue("url", "")
splitters = form.getvalue("splitters", "")
headers = form.getvalue("headers", "")
url_b64 = form.getvalue("ub64", "")
encoding = form.getvalue("encoding", "")
if len(url_b64) > 1:
	url = base64.b64decode(url_b64)


if len(headers) > 1:
	headers = json.loads(headers)
else:
	headers = { 'User-Agent' : "Mozilla" }
	
try: 
	req = urllib2.Request(url, None, headers)
	response = urllib2.urlopen(req)
	text = response.read()
	orig = text
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

print "Content-type: text/plain"
print
print cgi.escape(text.encode("utf8"))