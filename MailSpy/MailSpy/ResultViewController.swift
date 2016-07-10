//
//  ResultViewController.swift
//  MailSpy
//
//  Created by CoreCode on 17.11.14.
/*	Copyright (c) 2016 CoreCode
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

import Cocoa
import MapKit
var kSomeKey = "s"

class ResultViewController: NSViewController {

	dynamic var mailer : String = ""
	dynamic var isWebmail : Bool = false
	var originMenuItem : NSMenuItem?
	@IBOutlet weak var historyPopup: NSPopUpButton!
	@IBOutlet weak var locationBox: NSBox!
	@IBOutlet weak var ipButton: NSButton!
	@IBOutlet weak var providerButton: NSButton!
	@IBOutlet weak var infoField: NSTextField!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var progressIndicator: NSProgressIndicator!



	@IBAction func didSelectSource(sender: AnyObject)
	{
		if let button = sender as? NSPopUpButton
		{
			if button.selectedItem != originMenuItem
			{
				let alert = NSAlert()
				alert.messageText = "Warning";
				alert.informativeText = "You've not selected the origin of the mail but a server the e-mail went through on its way to the destination."
				alert.addButtonWithTitle("Show origin location")
				alert.addButtonWithTitle("Show intermediate-stop location")
				let response = alert.runModal()
				if response == NSAlertFirstButtonReturn
				{
					button.selectItem(originMenuItem)
				}
			}
		}
		mapView.removeAnnotations(mapView.annotations)
		mapView.hidden = true;
		progressIndicator.startAnimation(self)


		let res =  historyPopup.titleOfSelectedItem!
		let str = res.componentsSeparatedByString(": \t")[1]
		let ip = extractBestIP(str)
		let priv =  ip !=  "<no-ip>" ? isPrivateIP(ip) : true;
		let host = extractBestHostname(str)



		if (priv == false && host != "<no-address>")
		{
			ipButton.enabled = true

			if sender.isKindOfClass(NSPopUpButton) == true
			{
				ipButton.state = NSOnState
			}
			locationBox.title = ipButton.state == NSOnState ? ip : host


		}
		else if (priv == true && host != "<no-address>")
		{
			ipButton.enabled = false
			locationBox.title = host

			ipButton.state = NSOffState
		}
		else if (priv == false && host == "<no-address>")
		{
			ipButton.enabled = false

			locationBox.title = ip
			ipButton.state = NSOnState
		}
		else if (priv == true && host == "<no-address>")
		{

		}

		assert(!(priv != false && host == "<no-address>"))

		dispatch_async(dispatch_get_global_queue(0, 0))
		{
			var location : IPGeoLocation?

			if self.ipButton.state == NSOnState
			{
				location = IPGeoLocation(self.locationBox.title)
			}
			else
			{
				if let ipaddressofhost = NSHost(name: self.locationBox.title).address
				{
					location = IPGeoLocation(ipaddressofhost)
				}
				else
				{
					print("Error no host")
				}
			}

			if let location = location
			{
				if location.latitude != nil
				{
					let ctrpoint : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!)

					self.displayCoordinate(ctrpoint, location: location, title: self.locationBox.title)
				}
				else
				{
					//println(location.city + ", " + location.region + ", " + location.country)
					let geocoder:CLGeocoder = CLGeocoder()
					geocoder.geocodeAddressString(location.city, completionHandler: { (placemarks: [CLPlacemark]?, error: NSError?) in

						if	let placemark = placemarks?[0] as CLPlacemark!,
							let coordinates : CLLocationCoordinate2D = placemark.location!.coordinate
						{
							self.displayCoordinate(coordinates, location: location, title: self.locationBox.title)
						}
						else if ((error) != nil)
						{
							print("Error", error)
						}
						else
						{
							print("Error: no coordinates")
						}
					})
				}
			}
		}

	}

	func displayCoordinate(coord : CLLocationCoordinate2D, location : IPGeoLocation, title : String) -> Void
	{
		dispatch_async(dispatch_get_main_queue())
		{
			let anno : MKPointAnnotation = MKPointAnnotation()
			anno.coordinate = coord;
			anno.title = title

			self.progressIndicator.stopAnimation(self)
			self.mapView.hidden = false;
			self.mapView.addAnnotation(anno)
			self.mapView.centerCoordinate = coord
			self.mapView.selectAnnotation(anno, animated: true)

			self.providerButton.title = location.msg
			objc_setAssociatedObject(self.providerButton, &kSomeKey, location.url, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)


			if location.longitude != nil
			{
				if (title == location.query)
				{
					self.infoField.stringValue = "\(location.query): \(location.longitude!)° \(location.latitude!)°\n"
				}
				else
				{
					self.infoField.stringValue = "\(title) (\(location.query)): \(location.longitude!)° \(location.latitude!)°\n"
				}
			}
			else
			{
				self.infoField.stringValue = "\(location.query):\n"
			}

			self.infoField.stringValue += location.city + ", " + location.zip + ", " + location.region + ", " + location.country + "\n"
			self.infoField.stringValue += location.isp + " | " + location.asn + "\n"
		}
	}

	var emlString: String = "" {
		didSet
		{
			//println(emlString)

			let subject = emlString.rangeOfString("\nSubject: ") != nil ? emlString.componentsSeparatedByString("\nSubject: ")[1].componentsSeparatedByString("\r")[0] as String : ""
			let sender = emlString.rangeOfString("\nFrom: ") != nil ? emlString.componentsSeparatedByString("\nFrom: ")[1].componentsSeparatedByString("\r")[0] as String : ""
			let receiver = emlString.rangeOfString("\nTo: ") != nil ? emlString.componentsSeparatedByString("\nTo: ")[1].componentsSeparatedByString("\r")[0] as String : ""


			var result : [String] = ["Destination: " + receiver]
			let comp = emlString.componentsSeparatedByString("\nReceived: ")
			let comp2 = comp[1..<comp.count]

			for (index, value) in comp2.enumerate()
			{
				var newLine = " "
				var first = true;

				for line in value.componentsSeparatedByString("\n")
				{
					//                        println(line)

					if line.hasPrefix("\t") || line.hasPrefix(" ") || first
					{
						newLine += line as String
					}
					else if (!line.hasPrefix("Received: ") && !first)
					{
						break
					}

					first = false
				}

				newLine = newLine.componentsSeparatedByString(";")[0]

				let fromLoc = newLine.rangeOfString("\\sfrom ", options: NSStringCompareOptions.RegularExpressionSearch)
				let byLoc = newLine.rangeOfString("\\sby ", options: NSStringCompareOptions.RegularExpressionSearch)
				let forLoc = newLine.rangeOfString("\\sfor ", options: NSStringCompareOptions.RegularExpressionSearch)

				var fromString = "", byString = "", forString = ""

				//println("RECEIVED")
				//println(newLine)

				if fromLoc != nil
				{
					var stopLoc : Range<String.Index>?
					if forLoc != nil {stopLoc = forLoc }
					if byLoc != nil {stopLoc = byLoc }

					//assert(stopLoc != nil)
					if (stopLoc != nil && stopLoc!.startIndex > fromLoc!.startIndex)
					{
						fromString = newLine.substringWithRange(fromLoc!.startIndex ..< stopLoc!.startIndex)
					}
					else
					{
						fromString = newLine.substringFromIndex(fromLoc!.startIndex)
					}
					fromString = fromString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
				}
				if byLoc != nil
				{
					var stopLoc : Range<String.Index>?
					if forLoc != nil {stopLoc = forLoc }

					//assert(stopLoc != nil)
					if (stopLoc != nil && stopLoc!.startIndex > byLoc!.startIndex)
					{
						byString = newLine.substringWithRange(byLoc!.startIndex ..< stopLoc!.startIndex)
					}
					else
					{
						byString = newLine.substringFromIndex(byLoc!.startIndex)
					}
					byString = byString.componentsSeparatedByString(" with ")[0]
					byString = byString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
				}
				if forLoc != nil
				{
					forString = newLine.substringFromIndex(forLoc!.startIndex)
					forString = forString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
				}


				//

				//println(i.description + " From:  " + extractBestIP(fromString) + " [" + extractBestHostname(fromString) + "]")
				//println(i.description + " By:    " + extractBestIP(byString) + " [" + extractBestHostname(byString) + "]")
				//                    //println(fromString)
				//                    //extractBestIP(fromString)
				//                    //extractBestHostname(fromString)
				//                    //println(byString)
				//                    //println(forString)
				//println(newLine)

				if fromString != "from network)" || byString.utf16.count > 1
				{
					let v = comp2.count-index
					result += [v.description + " By: \t" + byString]
					result += [v.description + " From: \t" + fromString]
				}
			}

			result += ["Origin: " + sender]


			originMenuItem = nil

			for res in Array(result.reverse())
			{
				self.historyPopup.addItemWithTitle(res)

				let item = self.historyPopup!.lastItem!

				item.enabled = false
				item.state = NSOffState

				if res.hasPrefix("Origin: ") || res.hasPrefix("Destination: ")
				{

				}
				else
				{
					let str = res.componentsSeparatedByString(": \t")[1]
					//                    let str = res.hasPrefix("By: \t") == true ? res.substringFromIndex(6) : res.substringFromIndex(8) // TODO

					let ip = extractBestIP(str)
					let priv =  ip !=  "<no-ip>" ? isPrivateIP(ip) : true;
					let host = extractBestHostname(str)

					if (host != "<no-address>")
					{
						item.enabled = true

					}
					else if (priv == false)
					{
						item.enabled = true
					}

					if (originMenuItem == nil && item.enabled == true)
					{
						self.historyPopup!.selectItem(item)
						originMenuItem = item
					}
				}
			}

			if (originMenuItem == nil)
			{
				let alert = NSAlert()
				alert.messageText = "Import Failed";
				alert.informativeText = "This e-mail does not contain a single valid sender address."
				alert.addButtonWithTitle("D'Oh")
				alert.runModal()
			}


			//println(result);



			let xmailer = emlString.rangeOfString("\nX-Mailer: ") != nil ? emlString.componentsSeparatedByString("\nX-Mailer: ")[1].componentsSeparatedByString("\r")[0] as String : ""
			let agent = emlString.rangeOfString("\nUser-Agent: ") != nil ? emlString.componentsSeparatedByString("\nUser-Agent: ")[1].componentsSeparatedByString("\r")[0] as String : ""
			mailer = "\(xmailer) \(agent)".stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
			if mailer == ""
			{
				mailer = "[none | webmail]"
			}

			if emlString.rangeOfString("\nMIME-version: ") != nil
			{
				let mime = emlString.rangeOfString("\nMIME-version: ") != nil ? emlString.componentsSeparatedByString("\nMIME-version: ")[1].componentsSeparatedByString("\r")[0] as String : ""

				let mc = mime.componentsSeparatedByString(" (")

				if mc.count > 1
				{
					let info = mc[1].componentsSeparatedByString(")")[0]
					mailer = "\(mailer) \(info))"
				}
			}
			NSLog(mailer)


			self.isWebmail = true;
			for validXMailer in ["Airmail", "Apple Mail", "Evolution", "GyazMail", "iPad Mail", "iPhone Mail", "Lotus Notes", "Microsoft Outlook", "Microsoft Windows Mail", "Mozilla", "QUALCOMM", "sparrow", "Thunderbird"]
			{
				if xmailer.rangeOfString(validXMailer) != nil
				{
					self.isWebmail = false
				}
			}
			for validAgent in ["KMail", "Microsoft-Entourage", "Microsoft-MacOutlook", "Microsoft-Outlook-Express-Macintosh-Edition", "Thunderbird", "Mutt", "Postbox"]
			{
				if agent.rangeOfString(validAgent) != nil
				{
					self.isWebmail = false
				}
			}



			let title = "\(sender): \(subject)"

			view.window?.title = title;

			if (originMenuItem != nil)
			{
				self.didSelectSource(historyPopup)
			}
		}

	}


	func extractBestIP(str: String) -> String
	{
		var iploc : Range<String.Index>?
		var ipstr = str
		var bestip : String?

		repeat
		{
			iploc = ipstr.rangeOfString("[\\s,\\[,\\(][0-9][0-9]?[0-9]?\\.[0-9][0-9]?[0-9]?\\.[0-9][0-9]?[0-9]?\\.[0-9][0-9]?[0-9]?[\\s,\\],\\)]?", options: NSStringCompareOptions.RegularExpressionSearch)

			if (iploc != nil)
			{
				var foundStr = ipstr.substringWithRange(iploc!)
				ipstr = ipstr.substringFromIndex(iploc!.endIndex)

				if foundStr[foundStr.startIndex] == Character.init("(")
				{
					if foundStr[foundStr.endIndex.predecessor()] != Character.init(")")
					{
						continue
					}
					else
					{
						foundStr = foundStr.substringFromIndex(foundStr.startIndex.successor())
						foundStr = foundStr.substringToIndex(foundStr.endIndex.predecessor())
					}
				}
				else if foundStr[foundStr.startIndex] == Character.init("[")
				{
					if foundStr[foundStr.endIndex.predecessor()] != Character.init("]")
					{
						continue
					}
					else
					{
						foundStr = foundStr.substringFromIndex(foundStr.startIndex.successor())
						foundStr = foundStr.substringToIndex(foundStr.endIndex.predecessor())
					}
				}

				let priv = isPrivateIP(foundStr)
				if priv == false
				{
					return foundStr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
				}
				else if bestip == nil
				{
					bestip = foundStr
				}

				//println(foundStr)
			}
		} while iploc != nil

		if (bestip == nil)
		{
			return "<no-ip>"
		}
		else
		{
			return bestip!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		}
	}

	func isPrivateIP(str: String) -> Bool
	{
		let comp = str.componentsSeparatedByString(".")
		assert(comp.count == 4)

		if Int(comp[0]) == 10
		{
			return true
		}
		else if Int(comp[0]) == 172 && Int(comp[1]) >= 16 && Int(comp[1]) <= 31
		{
			return true
		}
		else if Int(comp[0]) == 192 && Int(comp[1]) == 168
		{
			return true
		}
		else if Int(comp[0]) == 169 && Int(comp[1]) == 254
		{
			return true
		}
		else if Int(comp[0]) == 127 && Int(comp[1]) == 0 && Int(comp[2]) == 0 && Int(comp[3]) == 1
		{
			return true
		}
		return false
	}


	func extractBestHostname(str: String) -> String {
		//
		let tlds = ["\\.abogado", "\\.ac", "\\.academy", "\\.accountants", "\\.active", "\\.actor", "\\.ad", "\\.adult", "\\.ae", "\\.aero", "\\.af", "\\.ag", "\\.agency", "\\.ai", "\\.airforce", "\\.al", "\\.allfinanz", "\\.alsace", "\\.am", "\\.an", "\\.android", "\\.ao", "\\.aq", "\\.aquarelle", "\\.ar", "\\.archi", "\\.army", "\\.arpa", "\\.as", "\\.asia", "\\.associates", "\\.at", "\\.attorney", "\\.au", "\\.auction", "\\.audio", "\\.autos", "\\.aw", "\\.ax", "\\.axa", "\\.az", "\\.ba", "\\.band", "\\.bar", "\\.bargains", "\\.bayern", "\\.bb", "\\.bd", "\\.be", "\\.beer", "\\.berlin", "\\.best", "\\.bf", "\\.bg", "\\.bh", "\\.bi", "\\.bid", "\\.bike", "\\.bio", "\\.biz", "\\.bj", "\\.black", "\\.blackfriday", "\\.bloomberg", "\\.blue", "\\.bm", "\\.bmw", "\\.bn", "\\.bnpparibas", "\\.bo", "\\.boo", "\\.boutique", "\\.br", "\\.brussels", "\\.bs", "\\.bt", "\\.budapest", "\\.build", "\\.builders", "\\.business", "\\.buzz", "\\.bv", "\\.bw", "\\.by", "\\.bz", "\\.bzh", "\\.ca", "\\.cab", "\\.cal", "\\.camera", "\\.camp", "\\.cancerresearch", "\\.capetown", "\\.capital", "\\.caravan", "\\.cards", "\\.care", "\\.career", "\\.careers", "\\.cartier", "\\.casa", "\\.cash", "\\.cat", "\\.catering", "\\.cc", "\\.cd", "\\.center", "\\.ceo", "\\.cern", "\\.cf", "\\.cg", "\\.ch", "\\.channel", "\\.cheap", "\\.christmas", "\\.chrome", "\\.church", "\\.ci", "\\.citic", "\\.city", "\\.ck", "\\.cl", "\\.claims", "\\.cleaning", "\\.click", "\\.clinic", "\\.clothing", "\\.club", "\\.cm", "\\.cn", "\\.co", "\\.coach", "\\.codes", "\\.coffee", "\\.college", "\\.cologne", "\\.com", "\\.community", "\\.company", "\\.computer", "\\.condos", "\\.construction", "\\.consulting", "\\.contractors", "\\.cooking", "\\.cool", "\\.coop", "\\.country", "\\.cr", "\\.credit", "\\.creditcard", "\\.cricket", "\\.crs", "\\.cruises", "\\.cu", "\\.cuisinella", "\\.cv", "\\.cw", "\\.cx", "\\.cy", "\\.cymru", "\\.cz", "\\.dad", "\\.dance", "\\.dating", "\\.day", "\\.de", "\\.deals", "\\.degree", "\\.delivery", "\\.democrat", "\\.dental", "\\.dentist", "\\.desi", "\\.dev", "\\.diamonds", "\\.diet", "\\.digital", "\\.direct", "\\.directory", "\\.discount", "\\.dj", "\\.dk", "\\.dm", "\\.dnp", "\\.do", "\\.docs", "\\.domains", "\\.doosan", "\\.durban", "\\.dvag", "\\.dz", "\\.eat", "\\.ec", "\\.edu", "\\.education", "\\.ee", "\\.eg", "\\.email", "\\.emerck", "\\.energy", "\\.engineer", "\\.engineering", "\\.enterprises", "\\.equipment", "\\.er", "\\.es", "\\.esq", "\\.estate", "\\.et", "\\.eu", "\\.eurovision", "\\.eus", "\\.events", "\\.everbank", "\\.exchange", "\\.expert", "\\.exposed", "\\.fail", "\\.farm", "\\.fashion", "\\.feedback", "\\.fi", "\\.finance", "\\.financial", "\\.firmdale", "\\.fish", "\\.fishing", "\\.fitness", "\\.fj", "\\.fk", "\\.flights", "\\.florist", "\\.flsmidth", "\\.fly", "\\.fm", "\\.fo", "\\.foo", "\\.forsale", "\\.foundation", "\\.fr", "\\.frl", "\\.frogans", "\\.fund", "\\.furniture", "\\.futbol", "\\.ga", "\\.gal", "\\.gallery", "\\.garden", "\\.gb", "\\.gbiz", "\\.gd", "\\.ge", "\\.gent", "\\.gf", "\\.gg", "\\.gh", "\\.gi", "\\.gift", "\\.gifts", "\\.gives", "\\.gl", "\\.glass", "\\.gle", "\\.global", "\\.globo", "\\.gm", "\\.gmail", "\\.gmo", "\\.gmx", "\\.gn", "\\.google", "\\.gop", "\\.gov", "\\.gp", "\\.gq", "\\.gr", "\\.graphics", "\\.gratis", "\\.green", "\\.gripe", "\\.gs", "\\.gt", "\\.gu", "\\.guide", "\\.guitars", "\\.guru", "\\.gw", "\\.gy", "\\.hamburg", "\\.haus", "\\.healthcare", "\\.help", "\\.here", "\\.hiphop", "\\.hiv", "\\.hk", "\\.hm", "\\.hn", "\\.holdings", "\\.holiday", "\\.homes", "\\.horse", "\\.host", "\\.hosting", "\\.house", "\\.how", "\\.hr", "\\.ht", "\\.hu", "\\.ibm", "\\.id", "\\.ie", "\\.il", "\\.im", "\\.immo", "\\.immobilien", "\\.in", "\\.industries", "\\.info", "\\.ing", "\\.ink", "\\.institute", "\\.insure", "\\.int", "\\.international", "\\.investments", "\\.io", "\\.iq", "\\.ir", "\\.irish", "\\.is", "\\.it", "\\.iwc", "\\.je", "\\.jetzt", "\\.jm", "\\.jo", "\\.jobs", "\\.joburg", "\\.jp", "\\.juegos", "\\.kaufen", "\\.ke", "\\.kg", "\\.kh", "\\.ki", "\\.kim", "\\.kitchen", "\\.kiwi", "\\.km", "\\.kn", "\\.koeln", "\\.kp", "\\.kr", "\\.krd", "\\.kred", "\\.kw", "\\.ky", "\\.kz", "\\.la", "\\.lacaixa", "\\.land", "\\.latrobe", "\\.lawyer", "\\.lb", "\\.lc", "\\.lds", "\\.lease", "\\.legal", "\\.lgbt", "\\.li", "\\.lidl", "\\.life", "\\.lighting", "\\.limited", "\\.limo", "\\.link", "\\.lk", "\\.loans", "\\.london", "\\.lotto", "\\.lr", "\\.ls", "\\.lt", "\\.ltda", "\\.lu", "\\.luxe", "\\.luxury", "\\.lv", "\\.ly", "\\.ma", "\\.madrid", "\\.maison", "\\.management", "\\.mango", "\\.market", "\\.marketing", "\\.mc", "\\.md", "\\.me", "\\.media", "\\.meet", "\\.melbourne", "\\.meme", "\\.memorial", "\\.menu", "\\.mg", "\\.mh", "\\.miami", "\\.mil", "\\.mini", "\\.mk", "\\.ml", "\\.mm", "\\.mn", "\\.mo", "\\.mobi", "\\.moda", "\\.moe", "\\.monash", "\\.money", "\\.mormon", "\\.mortgage", "\\.moscow", "\\.motorcycles", "\\.mov", "\\.mp", "\\.mq", "\\.mr", "\\.ms", "\\.mt", "\\.mu", "\\.museum", "\\.mv", "\\.mw", "\\.mx", "\\.my", "\\.mz", "\\.na", "\\.nagoya", "\\.name", "\\.navy", "\\.nc", "\\.ne", "\\.net", "\\.network", "\\.neustar", "\\.new", "\\.nexus", "\\.nf", "\\.ng", "\\.ngo", "\\.nhk", "\\.ni", "\\.ninja", "\\.nl", "\\.no", "\\.np", "\\.nr", "\\.nra", "\\.nrw", "\\.nu", "\\.nyc", "\\.nz", "\\.okinawa", "\\.om", "\\.ong", "\\.onl", "\\.ooo", "\\.org", "\\.organic", "\\.osaka", "\\.otsuka", "\\.ovh", "\\.pa", "\\.paris", "\\.partners", "\\.parts", "\\.party", "\\.pe", "\\.pf", "\\.pg", "\\.ph", "\\.pharmacy", "\\.photo", "\\.photography", "\\.photos", "\\.physio", "\\.pics", "\\.pictures", "\\.pink", "\\.pizza", "\\.pk", "\\.pl", "\\.place", "\\.plumbing", "\\.pm", "\\.pn", "\\.pohl", "\\.poker", "\\.porn", "\\.post", "\\.pr", "\\.praxi", "\\.press", "\\.pro", "\\.prod", "\\.productions", "\\.prof", "\\.properties", "\\.property", "\\.ps", "\\.pt", "\\.pub", "\\.pw", "\\.py", "\\.qa", "\\.qpon", "\\.quebec", "\\.re", "\\.realtor", "\\.recipes", "\\.red", "\\.rehab", "\\.reise", "\\.reisen", "\\.reit", "\\.ren", "\\.rentals", "\\.repair", "\\.report", "\\.republican", "\\.rest", "\\.restaurant", "\\.reviews", "\\.rich", "\\.rio", "\\.rip", "\\.ro", "\\.rocks", "\\.rodeo", "\\.rs", "\\.rsvp", "\\.ru", "\\.ruhr", "\\.rw", "\\.ryukyu", "\\.sa", "\\.saarland", "\\.samsung", "\\.sarl", "\\.sb", "\\.sc", "\\.sca", "\\.scb", "\\.schmidt", "\\.schule", "\\.schwarz", "\\.science", "\\.scot", "\\.sd", "\\.se", "\\.services", "\\.sew", "\\.sexy", "\\.sg", "\\.sh", "\\.shiksha", "\\.shoes", "\\.si", "\\.singles", "\\.sj", "\\.sk", "\\.sky", "\\.sl", "\\.sm", "\\.sn", "\\.so", "\\.social", "\\.software", "\\.sohu", "\\.solar", "\\.solutions", "\\.soy", "\\.space", "\\.spiegel", "\\.sr", "\\.st", "\\.su", "\\.supplies", "\\.supply", "\\.support", "\\.surf", "\\.surgery", "\\.suzuki", "\\.sv", "\\.sx", "\\.sy", "\\.sydney", "\\.systems", "\\.sz", "\\.taipei", "\\.tatar", "\\.tattoo", "\\.tax", "\\.tc", "\\.td", "\\.technology", "\\.tel", "\\.tf", "\\.tg", "\\.th", "\\.tienda", "\\.tips", "\\.tires", "\\.tirol", "\\.tj", "\\.tk", "\\.tl", "\\.tm", "\\.tn", "\\.to", "\\.today", "\\.tokyo", "\\.tools", "\\.top", "\\.town", "\\.toys", "\\.tp", "\\.tr", "\\.trade", "\\.training", "\\.travel", "\\.trust", "\\.tt", "\\.tui", "\\.tv", "\\.tw", "\\.tz", "\\.ua", "\\.ug", "\\.uk", "\\.university", "\\.uno", "\\.uol", "\\.us", "\\.uy", "\\.uz", "\\.va", "\\.vacations", "\\.vc", "\\.ve", "\\.vegas", "\\.ventures", "\\.versicherung", "\\.vet", "\\.vg", "\\.vi", "\\.viajes", "\\.villas", "\\.vision", "\\.vlaanderen", "\\.vn", "\\.vodka", "\\.vote", "\\.voting", "\\.voto", "\\.voyage", "\\.vu", "\\.wales", "\\.wang", "\\.watch", "\\.webcam", "\\.website", "\\.wed", "\\.wedding", "\\.wf", "\\.whoswho", "\\.wien", "\\.wiki", "\\.williamhill", "\\.wme", "\\.work", "\\.works", "\\.world", "\\.ws", "\\.wtc", "\\.wtf", "\\.xn--1qqw23a", "\\.xn--3bst00m", "\\.xn--3ds443g", "\\.xn--3e0b707e", "\\.xn--45brj9c", "\\.xn--45q11c", "\\.xn--4gbrim", "\\.xn--55qw42g", "\\.xn--55qx5d", "\\.xn--6frz82g", "\\.xn--6qq986b3xl", "\\.xn--80adxhks", "\\.xn--80ao21a", "\\.xn--80asehdb", "\\.xn--80aswg", "\\.xn--90a3ac", "\\.xn--c1avg", "\\.xn--cg4bki", "\\.xn--clchc0ea0b2g2a9gcd", "\\.xn--czr694b", "\\.xn--czrs0t", "\\.xn--czru2d", "\\.xn--d1acj3b", "\\.xn--d1alf", "\\.xn--fiq228c5hs", "\\.xn--fiq64b", "\\.xn--fiqs8s", "\\.xn--fiqz9s", "\\.xn--flw351e", "\\.xn--fpcrj9c3d", "\\.xn--fzc2c9e2c", "\\.xn--gecrj9c", "\\.xn--h2brj9c", "\\.xn--hxt814e", "\\.xn--i1b6b1a6a2e", "\\.xn--io0a7i", "\\.xn--j1amh", "\\.xn--j6w193g", "\\.xn--kprw13d", "\\.xn--kpry57d", "\\.xn--kput3i", "\\.xn--l1acc", "\\.xn--lgbbat1ad8j", "\\.xn--mgb9awbf", "\\.xn--mgba3a4f16a", "\\.xn--mgbaam7a8h", "\\.xn--mgbab2bd", "\\.xn--mgbayh7gpa", "\\.xn--mgbbh1a71e", "\\.xn--mgbc0a9azcg", "\\.xn--mgberp4a5d4ar", "\\.xn--mgbx4cd0ab", "\\.xn--ngbc5azd", "\\.xn--node", "\\.xn--nqv7f", "\\.xn--nqv7fs00ema", "\\.xn--o3cw4h", "\\.xn--ogbpf8fl", "\\.xn--p1acf", "\\.xn--p1ai", "\\.xn--pgbs0dh", "\\.xn--q9jyb4c", "\\.xn--qcka1pmc", "\\.xn--rhqv96g", "\\.xn--s9brj9c", "\\.xn--ses554g", "\\.xn--unup4y", "\\.xn--vermgensberater-ctb", "\\.xn--vermgensberatung-pwb", "\\.xn--vhquv", "\\.xn--wgbh1c", "\\.xn--wgbl6a", "\\.xn--xhq521b", "\\.xn--xkc2al3hye2a", "\\.xn--xkc2dl3a5ee0h", "\\.xn--yfro4i67o", "\\.xn--ygbi2ammx", "\\.xn--zfr164b", "\\.xxx", "\\.xyz", "\\.yachts", "\\.yandex", "\\.ye", "\\.yoga", "\\.yokohama", "\\.youtube", "\\.yt", "\\.za", "\\.zip", "\\.zm", "\\.zone", "\\.zw"]
		for tld in tlds
		{
			if let loc = str.rangeOfString("[a-z,A-Z,\\.,0-9,-]*" + tld + "[\\),\\s,\\.]", options: NSStringCompareOptions.RegularExpressionSearch)
			{
				let host = str.substringWithRange(loc.startIndex ..< loc.endIndex.advancedBy(-1))
				if NSHost(name: host).address != nil
				{
					return host
				}
			}
		}
		for tld in tlds
		{
			if let loc = str.rangeOfString("[a-z,A-Z,\\.,0-9,-]*" + tld + "\\z", options: NSStringCompareOptions.RegularExpressionSearch)
			{
				let host = str.substringWithRange(loc)
				if NSHost(name: host).address != nil
				{
					return host
				}
			}
		}

		return "<no-address>"
	}

	@IBAction func urlButtonClicked(sender: AnyObject)
	{
		let urlstr = objc_getAssociatedObject(self.providerButton, &kSomeKey) as! String?

		if urlstr != nil
		{
			if let url = NSURL(string: urlstr!)
			{
				NSWorkspace.sharedWorkspace().openURL(url)
			}
		}
	}

	@IBAction func helpButtonClicked(sender: AnyObject)
	{
		let hm = NSHelpManager.sharedHelpManager()
		hm.setContextHelp(NSAttributedString(string: "The email IP history contains all 'IP-addresses' the mail went through from the sender to you.\nThe topmost entry is closest to the sender, the bottommost entry is clostest to you.\nMailSpy automatically selects the closest displayable address to the sender.\nYou will be asked for confirmation if you want to display any other address, as it may not be near the sender."), forObject: sender)
		hm.showContextHelpForObject(sender, locationHint: NSEvent.mouseLocation())
		hm.removeContextHelpForObject(sender)
	}
}
