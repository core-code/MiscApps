#!/usr/bin/env python

# example TunesController.py

import pygtk
pygtk.require('2.0')
import gtk
import socket
from struct import *

HOST = ''		# The remote host
PORT = 60000	# The same port as used by the server

class TunesController:
    def callback(self, widget, data):
		s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		s.connect((HOST, PORT))
		
		if data == "1":
			s.send(pack('BB', 3, 0))
		elif data == "2":
			s.send(pack('BB', 4, 0))
		else:
			s.send(pack('BB', 2, 0))
		
		data = s.recv(1024)
		s.close()

    def delete_event(self, widget, event, data=None):
        gtk.main_quit()
        return False

    def __init__(self):
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.set_title("TunesController")
        self.window.connect("delete_event", self.delete_event)
        self.window.set_border_width(0)

        self.box1 = gtk.HBox(False, 0)
        self.window.add(self.box1)

        self.button1 = gtk.Button("Prev")
        self.button1.connect("clicked", self.callback, "1")
        self.box1.pack_start(self.button1, True, True, 0)
        self.button1.show()

        self.button2 = gtk.Button("Play/Pause")
        self.button2.connect("clicked", self.callback, "2")
        self.box1.pack_start(self.button2, True, True, 0)
        self.button2.show()
        
        self.button3 = gtk.Button("Next")
        self.button3.connect("clicked", self.callback, "3")
        self.box1.pack_start(self.button3, True, True, 0)
        self.button3.show()
        
        self.box1.show()
        self.window.show()

def main():
    gtk.main()

if __name__ == "__main__":
    hello = TunesController()
    main()