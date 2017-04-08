from CoreData import *
from AppKit import *
from Foundation import *
import sys


class ExportHTMLPlugin (NSObject):
	def html(self, movieArrayController, movieArrayFilesController):
		string = ""
		string = string + ("<html>")
		string = string + ("<head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\"></head>")
		string = string + ("<body>")
		string = string + ("<table border=\"1\">")
		string = string + ("<tr>")
		string = string + ("<th>Title</th>")
		string = string + ("<th>Rating</th>")
		string = string + ("<th>Language</th>")
		string = string + ("<th>IMDB-#</th>")
		string = string + ("<th>IMDB-Title</th>")
		string = string + ("<th>IMDB-Rating</th>")
		string = string + ("<th>IMDB-Year</th>")
		string = string + ("<th>IMDB-Director</th>")
		string = string + ("<th>IMDB-Writer</th>")
		string = string + ("<th>IMDB-Genre</th>")
		string = string + ("</tr>")		
		
		# loop through all movies
		am = movieArrayController.arrangedObjects()
		for m in am:
			string = string + ("<tr>")
			string = string + ("<td>" + (m.valueForKey_(u"title") or "").encode('utf-8')  + "</td>")
			string = string + ("<td>" + str(m.valueForKey_(u"rating")) + "</td>")
			string = string + ("<td>" + str(m.valueForKey_(u"language")) + "</td>")
			string = string + ("<td>" + str(m.valueForKey_(u"imdb_id")) + "</td>")
			string = string + ("<td>" + (m.valueForKey_(u"imdb_title") or "").encode('utf-8') + "</td>")
			rating = str(m.valueForKey_(u"imdb_rating"))
			string = string + ("<td>" + ((rating[:4]) if len(rating) > 4 else rating) + "</td>")
			string = string + ("<td>" + str(m.valueForKey_(u"imdb_year")) + "</td>")
			string = string + ("<td>" + (m.valueForKey_(u"imdb_director") or "").encode('utf-8') + "</td>")
			string = string + ("<td>" + (m.valueForKey_(u"imdb_writer") or "").encode('utf-8') + "</td>")
			string = string + ("<td>" + (m.valueForKey_(u"imdb_genre") or "").encode('utf-8') + "</td>")
			string = string + ("</tr>")
		
		string = string + ("</table>")					
		string = string + ("</body>")
		string = string + ("</html>")

		return string

	def getHTML_(self, obj):
		try:
			movieArrayController = obj[0]
			movieArrayFilesController = obj[1]
			

					
			string = self.html(movieArrayController, movieArrayController)

			return string	
		except:
   			print "Unexpected error:", sys.exc_info()[0]
			raise

	def execute_(self, obj):
		try:
			movieArrayController = obj[0]
			movieArrayFilesController = obj[1]
			
			
			panel = NSSavePanel.savePanel()
			panel.setAllowedFileTypes_(["html"])
			if panel.runModal() is not NSOKButton:
				return
					
			string = self.html(movieArrayController, movieArrayController)

			f = open(panel.filename(), 'w')
			f.write(string)
			f.close()
							
		except:
   			print "Unexpected error:", sys.exc_info()[0]
			raise