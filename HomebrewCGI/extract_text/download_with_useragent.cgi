#!/usr/bin/python
import cgi
import urllib2

form = cgi.FieldStorage()
url = form.getvalue("url", "")
ua = form.getvalue("user_agent", "Mozilla")
	
headers = { 'User-Agent' : ua }
	
try: 
	req = urllib2.Request(url, None, headers)
	response = urllib2.urlopen(req)
	text = response.read()

except Exception:
	import traceback
	text = 'generic exception: ' + traceback.format_exc()

print "Content-type: text/plain"
print
print text.encode("utf8")