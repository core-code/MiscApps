#
#  main.py
#  TunesControllerServer
#
#  Created by CoreCode on 30.10.07.
#  Copyright © 2017 CoreCode Limited
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import sys, os, signal, re, thread, threading, objc, types, time
from socket import *
from struct import *
from AppKit import *
from Foundation import *
from ScriptingBridge import *
from PyObjCTools import AppHelper

class Music(NSObject):
	def handleNotification_(self, aNotification):
		#print 'Music->handleNotification_ (', threading.currentThread().getName(), ')'
		
		global current_info
		
		ui = aNotification.userInfo()
		name = aNotification.name()
		#print name
		#print ui
		if (name == NSWorkspaceDidTerminateApplicationNotification and ui['NSApplicationName'] == 'iTunes'):
			threading.Thread(target=worker.sendDictionary, args=({'Player State': 0},)).start()
		elif (name == NSWorkspaceDidLaunchApplicationNotification and ui['NSApplicationName'] == 'iTunes'):
			self.handleConnectRefresh()
		elif (name == "com.apple.iTunes.playerInfo"):
			if (not (len(ui) == 1 and ui['Player State'] == "Stopped")):
				if (not ui.has_key("Rating")):
					nui = {}
					for key, v in ui.iteritems():
						nui[key] = v
					nui["Rating"] = 0
				else:
					nui = ui
				threading.Thread(target=worker.sendDictionary, args=(nui,)).start()
			
		return

	def handleConnectRefresh(self):
		#print 'Music->handleConnectRefresh(', threading.currentThread().getName(), ')'

		threading.Thread(target=worker.sendDictionary, args=( dict(self.getSimpleState().items() +  self.getExtendedState().items()),)).start()

	def handleData(self, data):
		#print 'Music->handleData(', threading.currentThread().getName(), ')'
	
		command, value = unpack('BB', data)
		#print command
		iTunes = SBApplication.applicationWithBundleIdentifier_("com.apple.iTunes")

		if command == in_refresh:
			self.handleConnectRefresh()
		elif command == in_launchquit:
			if iTunes.isRunning():
				iTunes.quit()
			else:
				iTunes.activate()
		elif command == in_next:
			iTunes.nextTrack()
		elif command == in_previous:
			iTunes.previousTrack()
		elif command == in_playpause:
			iTunes.playpause()
		elif command == in_playlist_num:
			os.system("osascript -e 'tell application \"iTunes\"\nplay playlist " + str(value+1) + "\nend tell'") #iTunes.play(iTunes.playlists[value])
		elif command == in_repeat_num:
			if value == 0:
				iTunes.currentPlaylist().setSongRepeat_(1800564815) # iTunesERptOff = 'kRpO' = 1800564815
			elif value == 1:
				iTunes.currentPlaylist().setSongRepeat_(1800564801) # iTunesERptAll = 'kRpA' = 1800564801
			else:
				iTunes.currentPlaylist().setSongRepeat_(1800564785) # iTunesERptOne = 'kRp1' = 1800564785			
		elif command == in_shuffle_bool:
			if value == 0:
				iTunes.currentPlaylist().setShuffle_(0)
			else:
				iTunes.currentPlaylist().setShuffle_(1)
		elif command == in_volume_num:
			iTunes.setSoundVolume_(value)
		elif command == in_rating_num and value <= 100:
			iTunes.currentTrack().setRating_(value)
		else: 
			print "unknown command: " + data
			
		#print "Music->handleData OUT"

	def getSimpleState(self):
		#print 'Music->getSimpleState(', threading.currentThread().getName(), ')'
		iTunes = SBApplication.applicationWithBundleIdentifier_("com.apple.iTunes")

		ss = {}
		ss['Player State'] = 0
		if iTunes.isRunning():
			ss['Player State'] = iTunes.playerState() 
			try:
				ss['Year'] = iTunes.currentTrack().year()
				ss['Rating'] = iTunes.currentTrack().rating()
				ss['Name'] = iTunes.currentTrack().name()
				ss['Artist'] = iTunes.currentTrack().artist()
				ss['Album'] = iTunes.currentTrack().album()
				ss['Genre'] = iTunes.currentTrack().genre()
			except:
				pass
		return ss

	def getExtendedState(self):
		#print 'Music->getExtendedState(', threading.currentThread().getName(), ')'
		iTunes = SBApplication.applicationWithBundleIdentifier_("com.apple.iTunes")

		es = {}
		if iTunes.isRunning():
			if (iTunes.playerState() != 1800426323): # iTunesEPlSStopped = 'kPSS' = 1800426323
				es['Playlists'] = iTunes.sources()[0].userPlaylists().arrayByApplyingSelector_(objc.selector(None, selector='name',signature='@8@0:4'))
				es['Current Playlist'] = iTunes.currentPlaylist().name()
				es['Shuffle'] = iTunes.currentPlaylist().shuffle()
				es['Repeat'] = iTunes.currentPlaylist().songRepeat()
				es['Volume'] = iTunes.soundVolume()
		return es
		
class Worker(threading.Thread):
	def sendDictionary(self, dict):
		#print 'Worker->sendDictionary(', threading.currentThread().getName(), ')'
		
		pool = NSAutoreleasePool.alloc().init()
		data = ''
		
		for key, v in dict.iteritems():
			if key in ['Player State', 'Year', 'Name', 'Artist', 'Album', 'Genre', 'Rating', 'Playlists', 'Current Playlist', 'Shuffle', 'Repeat', 'Volume']:
				data += pack('b',len(key.encode('utf-8')))
				data += pack(str(len(key.encode('utf-8')))+'s',key.encode('utf-8'))
				
				if key == "Player State":
					if (v == "Stopped") or (v == 1800426323):	# iTunesEPlSStopped = 'kPSS' = 1800426323
						if dict.has_key('Name'):
							data += pack('i', 2)
						else:
							data += pack('i', 1)
					elif v == ("Paused") or (v == 1800426352):	# iTunesEPlSPaused = 'kPSp' = 1800426352
						data += pack('i', 2)
					elif v == ("Playing") or (v == 1800426320):	# iTunesEPlSPlaying = 'kPSP' = 1800426320
						data += pack('i', 3)
					else:
						data += pack('i', 0)
				elif key == "Repeat":
					if v == 1800564801:		# iTunesERptAll = 'kRpA' = 1800564801
						data += pack('i', 1)
					elif v == 1800564785:
						data += pack('i', 2)	# iTunesERptOne = 'kRp1' = 1800564785
					else:						# iTunesERptOff = 'kRpO' = 1800564815
						data += pack('i', 0)
				else:
					if type(v) in (types.IntType, types.BooleanType):
						data += pack('i', v)					
					elif (type(v) is types.ListType) or (isinstance(v, NSCFArray)):
						#print v
						l = 0
						for i in v:
							l += len(i.encode('utf-8'))
						data += pack('i', l+len(v))
						for i in v:
							data += pack('b',len(i.encode('utf-8')))
							data += pack(str(len(i.encode('utf-8')))+'s',i.encode('utf-8'))
					elif isinstance(v, NSCFNumber):
						data += pack('i', v.intValue())
					else:
						data += pack('b',len(v.encode('utf-8')))
						data += pack(str(len(v.encode('utf-8')))+'s',v.encode('utf-8'))
						
		#print 'SENDING', data
		info = pack('i', 666)
		info += pack('i', len(data))
		info += data 
		del pool
		
		try:
			conn.send(info)
			
		except:
			pass
			
	def killHandler(signum, frame, sig=signal.SIGTERM):
		#print 'Worker->killHandler(', threading.currentThread().getName(), ')'
		
		conn.close()
		s.close()
		raise "killed"

	def run(self):
		#print 'Worker->run(', threading.currentThread().getName(), ')'
		
		global conn
		global s
		
		s = socket(AF_INET, SOCK_STREAM)
		try:
			s.bind(('', 60000))
		except:
			NSLog("Could not start listening for network traffic. Maybe another version is already running, or port 60000 is otherwise used.")
			raise
		s.listen(1)
		
		try:
			while 1:
				#print 'Waiting for connection'
				conn, addr = s.accept()
				
				music = Music.new()
				pool = NSAutoreleasePool.new()
				NSDistributedNotificationCenter.defaultCenter().addObserver_selector_name_object_(music, "handleNotification:", "com.apple.iTunes.playerInfo", "com.apple.iTunes.player")
				NSWorkspace.sharedWorkspace().notificationCenter().addObserver_selector_name_object_(music, "handleNotification:", NSWorkspaceDidTerminateApplicationNotification, None)
				NSWorkspace.sharedWorkspace().notificationCenter().addObserver_selector_name_object_(music, "handleNotification:", NSWorkspaceDidLaunchApplicationNotification, None)
				
				#print 'Connected by', addr
				music.performSelectorOnMainThread_withObject_waitUntilDone_("handleConnectRefresh", "", False);
				  
				while 1:
					data = conn.recv(2)
					
					if not data: 
						#print "no data, breaking"
						NSDistributedNotificationCenter.defaultCenter().removeObserver_name_object_(music, "com.apple.iTunes.playerInfo", "com.apple.iTunes.player")
						NSWorkspace.sharedWorkspace().notificationCenter().removeObserver_name_object_(music, NSWorkspaceDidTerminateApplicationNotification, None)
						NSWorkspace.sharedWorkspace().notificationCenter().removeObserver_name_object_(music, NSWorkspaceDidLaunchApplicationNotification, None)
						del music
						del pool
						break
					else:
						music.performSelectorOnMainThread_withObject_waitUntilDone_("handleData", data, False);
						
		except:
			print "excpetion, closing all"
			conn.close()
			s.close()
			raise



in_refresh, in_launchquit, in_next, in_previous, in_playpause, in_rating_num, in_playlist_num, in_repeat_num, in_shuffle_bool, in_volume_num = range(10)

worker = Worker()

signal.signal(signal.SIGHUP, worker.killHandler)
signal.signal(signal.SIGINT, worker.killHandler)
signal.signal(signal.SIGQUIT, worker.killHandler)

worker.start()

#AppHelper.runConsoleEventLoop()
#NSApplication.sharedApplication().run()
AppHelper.runEventLoop()