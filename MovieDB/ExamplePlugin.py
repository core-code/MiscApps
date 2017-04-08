from CoreData import *
from AppKit import *
from Foundation import *
import sys


class ExamplePlugin (NSObject):
	def execute_(self, obj):
		try:
			movieArrayController = obj[0]
			movieArrayFilesController = obj[1]
			
			# access current movie
			m = movieArrayController.selection()
			print m
			if (m.valueForKey_(u"title") is NSNoSelectionMarker): return
			
			
			print m.valueForKey_(u"file_audio_codec")
			print m.valueForKey_(u"file_container")
			print m.valueForKey_(u"file_type")
			print m.valueForKey_(u"file_video_codec")
			print m.valueForKey_(u"file_video_height")
			print m.valueForKey_(u"file_video_width")
			print m.valueForKey_(u"imdb_id")
			print m.valueForKey_(u"imdb_rating")
			print m.valueForKey_(u"imdb_year")
#			print m.valueForKey_(u"imdb_poster").bytes()	# lot of output
#			print m.valueForKey_(u"imdb_cast").encode('latin-1')
#			print m.valueForKey_(u"imdb_director").encode('latin-1')
#			print m.valueForKey_(u"imdb_genre").encode('latin-1')
#			print m.valueForKey_(u"imdb_plot").encode('latin-1')
#			print m.valueForKey_(u"imdb_title").encode('latin-1')
#			print m.valueForKey_(u"imdb_writer").encode('latin-1')
			print m.valueForKey_(u"language")
			print m.valueForKey_(u"rating")
			print m.valueForKey_(u"title")

			# access all movies
			am = movieArrayController.arrangedObjects()
			for sm in am:
				print sm.valueForKey_(u"title")

			# todo examples for adding movies

		except:
   			print "Unexpected error:", sys.exc_info()[0]
			raise