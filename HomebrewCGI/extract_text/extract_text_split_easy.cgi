#!/usr/bin/python
import cgi
import urllib2


form = cgi.FieldStorage()
url = form.getvalue("url", "")
ua = form.getvalue("user_agent", "Mozilla")
encoding = form.getvalue("encoding", "")

splitters = []

for i in range(1, 10):
	s = form.getvalue("splitter_" + str(i), "")
	c = form.getvalue("index_" + str(i), "")
	if len(s) and len(c):
	 	splitters.append({'splitter' : s, 'index' : c})

   		

headers = { 'User-Agent' : ua }
	
try: 
	req = urllib2.Request(url, None, headers)
	response = urllib2.urlopen(req)
	text = response.read()
	if len(encoding) > 1:
		text = text.decode(encoding)
		if len(text) < 1:
			raise Exception('conversion to encoding failed {}'.format(encoding))
	
	for splitter in splitters:
		s = splitter["splitter"]
		i = int(splitter["index"])
		text = text.split(s)[i]
except Exception:
	import traceback
	text = 'generic exception: ' + traceback.format_exc()

print "Content-type: text/plain"
print
print cgi.escape(text.encode("utf8"))