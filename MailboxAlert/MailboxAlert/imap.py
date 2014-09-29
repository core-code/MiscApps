#!/usr/bin/python
import sys, os, string, imaplib, re, socket

msgCount = 0
msgSize = 0
msgCount_sum = 0
msgSize_sum = 0

M = 0
socket.setdefaulttimeout(10)

try	:
	M = imaplib.IMAP4_SSL(sys.argv[1])
except:
	pass

if not M:
	try	:
		M = imaplib.IMAP4(sys.argv[1])
	except:
		print "ERRSERVER"
		sys.exit(1)		

try	:
	M.login(sys.argv[2], sys.argv[3])
except:
	print "ERRCREDENTIALS"
	sys.exit(1)		

result,mailboxList = M.list()

for mbox in mailboxList:
	x = ")".join(mbox.split(")")[1:]).strip()
	mailbox = ""

	if (x.find(" NIL ") != -1):
		mailbox = x.split(" NIL ")[1].replace('\"', '')
	elif (x.find("\" \"") != -1):
		mailbox = x.split("\" \"")[-1].replace('\"', '')
	elif (x.find("\"") != -1):
		mailbox = x.split("\"")[-1].strip()
	else:
		mailbox = " ".join(x.split(" ")[1:])

	if not "Noselect" in mbox:
		folderSize = 0

		result, num = M.select(mailbox, readonly=1)


		numnum = 0
		try: 
			numnum = int(num[0])
		except:
			print "SHIT"

		if "\All" in mbox:
			msgCount_sum += numnum
		else:
			msgCount += numnum
		
		typ, msg = M.search(None, 'ALL')
		m = [int(x) for x in msg[0].split()]
		m.sort()
		if m:
			messageSet = "%d:%d" % (m[0], m[-1])
			result, sizeResponse = M.fetch(messageSet, "(UID RFC822.SIZE)")
			for i in range(m[-1]):
				tmp = sizeResponse[i].split()
				folderSize += int(tmp[-1].replace(')', ''))
		else:
			folderSize = 0

		if "\All" in mbox:
			msgSize_sum += folderSize
		else:
			msgSize += folderSize
	
print "SumCalc %i %f" % (msgCount, msgSize/(1024*1024))
print "SumSum %i %f" % (msgCount_sum, msgSize_sum/(1024*1024))

quotaStr = M.getquotaroot("INBOX")[1][1][0]
p = re.compile('\d+')
r = p.findall(quotaStr)
if r != []:
  print "Quota %f %f" % ((float(r[0])/1024), (float(r[1])/1024))
 
M.logout()
