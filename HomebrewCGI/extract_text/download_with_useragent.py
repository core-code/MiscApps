#!/usr/bin/python
import urllib2
import sys


url = sys.argv[1]
ua = sys.argv[2]
	


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