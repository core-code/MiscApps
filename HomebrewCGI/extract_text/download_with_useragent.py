#!/usr/bin/python
import urllib2
import sys


url = sys.argv[1]
ua = sys.argv[2]
encoding = ""
if len(sys.argv) > 3:
	encoding = sys.argv[3]



headers = { 'User-Agent' : ua }
	
try: 
	req = urllib2.Request(url, None, headers)
	response = urllib2.urlopen(req)
	text = response.read()
	if len(encoding) > 1:
		text = text.decode(encoding)
		if len(text) < 1:
			raise Exception('conversion to encoding failed {}'.format(encoding))


except Exception:
	import traceback
	text = 'generic exception: ' + traceback.format_exc()

print "Content-type: text/plain"
print
print text.encode("utf8")