#!/usr/bin/python
import cgi
import urllib2
import json


form = cgi.FieldStorage()
url = form.getvalue("url", "")
keypath = form.getvalue("keypath", "")
headers = form.getvalue("headers", "")

if len(headers) > 1:
	headers = json.loads(headers)
else:
	headers = { 'User-Agent' : "Mozilla" }

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


print "Content-type: text/html"
print

print """
<html>
<head><title></title></head>
<body>
  %s

</body>
</html>
""" % cgi.escape(str(js))
