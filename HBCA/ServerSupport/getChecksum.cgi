#!/usr/bin/env python

import os, cgi, urllib2, hashlib
import logging
import logging.handlers


	
	
try:
	form = cgi.FieldStorage()
	url = form.getvalue("url", "")
	ua = form.getvalue("user_agent", "Mozilla")
	headers = { 'User-Agent' : ua }
	req = urllib2.Request(url, None, headers)
	response = urllib2.urlopen(req)
	download = response.read()
	m = hashlib.sha256()
	m.update(download)
	result = "URL: " + url + "<br>SHA: " + m.hexdigest() + "<br>SIZE: " + str(len(download))
except Exception as e:
	result = str(e)


print "Content-type: text/html"
print

print """
<html>
<head><title></title></head>
<body>
"""
print result

print """
</body>
</html>
"""