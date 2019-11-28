#!/usr/bin/python3
import cgi
import json
from urllib.parse import urlencode
from urllib.request import Request, urlopen

form = cgi.FieldStorage()
url = form.getvalue("url", "")
headers = form.getvalue("headers", "")
params = form.getvalue("params", "")

if len(headers) > 1:
	headers = json.loads(headers)
else:
	headers = { 'User-Agent' : "Mozilla" }


if len(params) > 1:
	params = json.loads(params)
else:
	params = {  }	

	
try: 
	request = Request(url, urlencode(params).encode())
	text = urlopen(request).read().decode()
except Exception:
	import traceback
	text = 'generic exception: ' + traceback.format_exc()

print("Content-Type: text/html") 
print()
print(cgi.escape(text))