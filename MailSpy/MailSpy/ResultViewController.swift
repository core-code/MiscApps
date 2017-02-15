//
//  ResultViewController.swift
//  MailSpy
//
//  Created by CoreCode on 17.11.14.
/*	Copyright © 2017 CoreCode Limited
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



	@IBAction func didSelectSource(_ sender: AnyObject)
	{
		//print("didSelectSource")
		if let button = sender as? NSPopUpButton
		{
			if button.selectedItem != originMenuItem
			{
				let alert = NSAlert()
				alert.messageText = "Warning";
				alert.informativeText = "You've not selected the origin of the mail but a server the e-mail went through on its way to the destination."
				alert.addButton(withTitle: "Show origin location")
				alert.addButton(withTitle: "Show intermediate-stop location")
				let response = alert.runModal()
				if response == NSAlertFirstButtonReturn
				{
					button.select(originMenuItem)
				}
			}
		}
		mapView.removeAnnotations(mapView.annotations)
		mapView.isHidden = true;
		progressIndicator.startAnimation(self)


		let res =  historyPopup.titleOfSelectedItem!
		let str = res.components(separatedBy: ": \t")[1]
		let ip = extractBestIP(str: str)
		let priv =  ip !=  "<no-ip>" ? isPrivateIP(str: ip) : true;
		let host = extractBestHostname(str: str)



		if (priv == false && host != "<no-address>")
		{
			ipButton.isEnabled = true

			if sender is NSPopUpButton
			{
				ipButton.state = NSOnState
			}
			locationBox.title = ipButton.state == NSOnState ? ip : host


		}
		else if (priv == true && host != "<no-address>")
		{
			ipButton.isEnabled = false
			locationBox.title = host

			ipButton.state = NSOffState
		}
		else if (priv == false && host == "<no-address>")
		{
			ipButton.isEnabled = false

			locationBox.title = ip
			ipButton.state = NSOnState
		}
		else if (priv == true && host == "<no-address>")
		{

		}

		assert(!(priv != false && host == "<no-address>"))

		DispatchQueue.global().async
		{
			var location : IPGeoLocation?

			if self.ipButton.state == NSOnState
			{
				location = IPGeoLocation(self.locationBox.title)
			}
			else
			{
				if let ipaddressofhost = Host(name: self.locationBox.title).address
				{
					location = IPGeoLocation(ipaddressofhost)
				}
				else
				{
					print("Error: no host")
				}
			}

			if let location = location
			{
				if location.latitude != nil
				{
					//print("long \(location.latitude) lat \(location.longitude)")

					let ctrpoint : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude!, longitude: location.longitude!)

					self.displayCoordinate(coord: ctrpoint, location: location, title: self.locationBox.title)
				}
				else
				{
					//print(location.city + ", " + location.region + ", " + location.country)
					let geocoder:CLGeocoder = CLGeocoder()
					geocoder.geocodeAddressString(location.city, completionHandler:
					{(placemarks: [CLPlacemark]?, error: Error?) -> Void in

						if	let placemark = placemarks?[0] as CLPlacemark!,
							let loc = placemark.location
						{
							let coordinates : CLLocationCoordinate2D = loc.coordinate

							self.displayCoordinate(coord: coordinates, location: location, title: self.locationBox.title)
						}
						else if let error = error
						{
							print("Error", error.localizedDescription)
						}
						else
						{
							print("Error: no coordinates")
						}
					})
				}
			}
			else
			{
				print("Error: couldn't  get coordinates of ip: \(self.locationBox.title)")

				DispatchQueue.main.async
				{
					self.progressIndicator.stopAnimation(self)

//					let alert = NSAlert()
//					alert.messageText = "Converting IP to Location Failed";
//					alert.informativeText = "Error: couldn't  get coordinates of ip: \(self.locationBox.title)"
//					alert.addButton(withTitle: "OK")
//					alert.runModal()
//                    
                    //TODO: Clean up this code after testing
                    
                    
				}
			}

		}

	}

	func displayCoordinate(coord : CLLocationCoordinate2D, location : IPGeoLocation, title : String) -> Void
	{
		DispatchQueue.main.async
		{
			let anno : MKPointAnnotation = MKPointAnnotation()
			anno.coordinate = coord;
			anno.title = title

			self.progressIndicator.stopAnimation(self)
			self.mapView.isHidden = false;
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
            emlString = emlString.replacingOccurrences(of: "\r\n", with: "\n")
            emlString = emlString.replacingOccurrences(of: "\r", with: "\n")

            //println(emlString)

			let subject = emlString.range(of:"\nSubject: ") != nil ? emlString.components(separatedBy: "\nSubject: ")[1].components(separatedBy: "\n")[0] as String : ""
			let sender = emlString.range(of:"\nFrom: ") != nil ? emlString.components(separatedBy: "\nFrom: ")[1].components(separatedBy: "\n")[0] as String : ""
			let receiver = emlString.range(of:"\nTo: ") != nil ? emlString.components(separatedBy: "\nTo: ")[1].components(separatedBy: "\n")[0] as String : ""


			var result : [String] = ["Destination: " + receiver]
			let comp = emlString.components(separatedBy: "\nReceived: ")
			let comp2 = comp[1..<comp.count]

			for (index, value) in comp2.enumerated()
			{
				var newLine = " "
				var first = true;

				for line in value.components(separatedBy: "\n")
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

				newLine = newLine.components(separatedBy: ";")[0]

				let fromLoc = newLine.range(of:"\\sfrom ", options: .regularExpression)
				let byLoc = newLine.range(of:"\\sby ", options: .regularExpression)
				let forLoc = newLine.range(of:"\\sfor ", options: .regularExpression)

				var fromString = "", byString = "", forString = ""

				//println("RECEIVED")
				//println(newLine)

				if fromLoc != nil
				{
					var stopLoc : Range<String.Index>?
					if forLoc != nil {stopLoc = forLoc }
					if byLoc != nil {stopLoc = byLoc }

					//assert(stopLoc != nil)
					if (stopLoc != nil && stopLoc!.lowerBound > fromLoc!.lowerBound)
					{
						fromString = newLine.substring(with: fromLoc!.lowerBound ..< stopLoc!.lowerBound)
					}
					else
					{
						fromString = newLine.substring(from: fromLoc!.lowerBound)
					}
					fromString = fromString.trimmingCharacters(in: .whitespacesAndNewlines)
				}
				if byLoc != nil
				{
					var stopLoc : Range<String.Index>?
					if forLoc != nil {stopLoc = forLoc }

					//assert(stopLoc != nil)
					if (stopLoc != nil && stopLoc!.lowerBound > byLoc!.lowerBound)
					{
						byString = newLine.substring(with: byLoc!.lowerBound ..< stopLoc!.lowerBound)
					}
					else
					{
						byString = newLine.substring(from: byLoc!.lowerBound)
					}
					byString = byString.components(separatedBy: " with ")[0]
					byString = byString.trimmingCharacters(in: .whitespacesAndNewlines)
				}
				if forLoc != nil
				{
					forString = newLine.substring(from: forLoc!.lowerBound)
					forString = forString.trimmingCharacters(in: .whitespacesAndNewlines)
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

			for res in Array(result.reversed())
			{
				self.historyPopup.addItem(withTitle: res)

				let item = self.historyPopup!.lastItem!

				item.isEnabled = false
				item.state = NSOffState

				if res.hasPrefix("Origin: ") || res.hasPrefix("Destination: ")
				{

				}
				else
				{
					let str = res.components(separatedBy: ": \t")[1]
					//                    let str = res.hasPrefix("By: \t") == true ? res.substringFromIndex(6) : res.substringFromIndex(8) // TODO

					let ip = extractBestIP(str: str)
					let priv =  ip !=  "<no-ip>" ? isPrivateIP(str: ip) : true;
					let host = extractBestHostname(str: str)

					if (host != "<no-address>")
					{
						item.isEnabled = true

					}
					else if (priv == false)
					{
						item.isEnabled = true
					}

					if (originMenuItem == nil && item.isEnabled == true)
					{
						self.historyPopup!.select(item)
						originMenuItem = item
					}
				}
			}

			if (originMenuItem == nil)
			{
//				let alert = NSAlert()
//				alert.messageText = "Import Failed";
//				alert.informativeText = "This e-mail does not contain a single valid sender address."
//				alert.addButton(withTitle: "D'Oh")
//				alert.runModal()
                
                //TODO: Clean up this code after testing
                
                
                print("Error: email does not contain a valid sender address")
			}


			//println(result);



			let xmailer = emlString.range(of:"\nX-Mailer: ") != nil ? emlString.components(separatedBy: "\nX-Mailer: ")[1].components(separatedBy: "\n")[0] as String : ""
			let agent = emlString.range(of:"\nUser-Agent: ") != nil ? emlString.components(separatedBy: "\nUser-Agent: ")[1].components(separatedBy: "\n")[0] as String : ""
			mailer = "\(xmailer) \(agent)".trimmingCharacters(in: .whitespacesAndNewlines)
			if mailer == ""
			{
				mailer = "[none | webmail]"
			}

			if emlString.range(of:"\nMIME-version: ") != nil
			{
				let mime = emlString.range(of:"\nMIME-version: ") != nil ? emlString.components(separatedBy: "\nMIME-version: ")[1].components(separatedBy: "\n")[0] as String : ""

				let mc = mime.components(separatedBy: " (")

				if mc.count > 1
				{
					let info = mc[1].components(separatedBy: ")")[0]
					mailer = "\(mailer) \(info))"
				}
			}


			self.isWebmail = true;
			for validXMailer in ["Airmail", "Apple Mail", "Evolution", "GyazMail", "iPad Mail", "iPhone Mail", "Lotus Notes", "Microsoft Outlook", "Microsoft Windows Mail", "Mozilla", "QUALCOMM", "sparrow", "Thunderbird"]
			{
				if xmailer.range(of:validXMailer) != nil
				{
					self.isWebmail = false
				}
			}
			for validAgent in ["KMail", "Microsoft-Entourage", "Microsoft-MacOutlook", "Microsoft-Outlook-Express-Macintosh-Edition", "Thunderbird", "Mutt", "Postbox"]
			{
				if agent.range(of:validAgent) != nil
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
			iploc = ipstr.range(of:"[\\s,\\[,\\(][0-9][0-9]?[0-9]?\\.[0-9][0-9]?[0-9]?\\.[0-9][0-9]?[0-9]?\\.[0-9][0-9]?[0-9]?[\\s,\\],\\)]?", options: .regularExpression)

			if (iploc != nil)
			{
				var foundStr = ipstr.substring(with: iploc!)
				ipstr = ipstr.substring(from: iploc!.upperBound)

				if foundStr[foundStr.startIndex] == Character.init("(")
				{
					if foundStr[foundStr.index(before:foundStr.endIndex)] != Character.init(")")
					{
						continue
					}
					else
					{
						foundStr = foundStr.substring(from: foundStr.index(after:foundStr.startIndex))
						foundStr = foundStr.substring(to: foundStr.index(before:foundStr.endIndex))
					}
				}
				else if foundStr[foundStr.startIndex] == Character.init("[")
				{
					if foundStr[foundStr.index(before:foundStr.endIndex)] != Character.init("]")
					{
						continue
					}
					else
					{
						foundStr = foundStr.substring(from: foundStr.index(after:foundStr.startIndex))
						foundStr = foundStr.substring(to: foundStr.index(before:foundStr.endIndex))
					}
				}

				let priv = isPrivateIP(str: foundStr)
				if priv == false
				{
					return foundStr.trimmingCharacters(in: .whitespacesAndNewlines)
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
			return bestip!.trimmingCharacters(in: .whitespacesAndNewlines)
		}
	}

	func isPrivateIP(str: String) -> Bool
	{
		let comp = str.components(separatedBy: ".")
		assert(comp.count == 4)
        
        let cs = NSCharacterSet.decimalDigits.inverted
        
		let int0 = Int(comp[0].trimmingCharacters(in: cs))!
		let int1 = Int(comp[1].trimmingCharacters(in: cs))!
		let int2 = Int(comp[2].trimmingCharacters(in: cs))!
		let int3 = Int(comp[3].trimmingCharacters(in: cs))!

		if int0 == 10
		{
			return true
		}
		else if int0 == 172 && int1 >= 16 && int1 <= 31
		{
			return true
		}
		else if int0 == 192 && int1 == 168
		{
			return true
		}
		else if int0 == 169 && int1 == 254
		{
			return true
		}
		else if int0 == 127 && int1 == 0 && int2 == 0 && int3 == 1
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
			if let loc = str.range(of:"[a-z,A-Z,\\.,0-9,-]*" + tld + "[\\),\\s,\\.]", options: .regularExpression)
			{
				let host = str.substring(with: loc.lowerBound ..< str.index(loc.upperBound, offsetBy:-1))
				if Host(name: host).address != nil
				{
					return host
				}
			}
		}
		for tld in tlds
		{
			if let loc = str.range(of:"[a-z,A-Z,\\.,0-9,-]*" + tld + "\\z", options: .regularExpression)
			{
				let host = str.substring(with: loc)
				if Host(name: host).address != nil
				{
					return host
				}
			}
		}

		return "<no-address>"
	}


	@IBAction func urlButtonClicked(_ sender: AnyObject)
	{
		let urlstr = objc_getAssociatedObject(self.providerButton, &kSomeKey) as! String?

		if urlstr != nil
		{
			if let url = NSURL(string: urlstr!)
			{
				NSWorkspace.shared().open(url as URL)
			}
		}
	}

	@IBAction func helpButtonClicked(_ sender: AnyObject)
	{
		let hm = NSHelpManager.shared()
		hm.setContextHelp(NSAttributedString(string: "The email IP history contains all 'IP-addresses' the mail went through from the sender to you.\nThe topmost entry is closest to the sender, the bottommost entry is clostest to you.\nMailSpy automatically selects the closest displayable address to the sender.\nYou will be asked for confirmation if you want to display any other address, as it may not be near the sender."), for: sender)
		hm.showContextHelp(for: sender, locationHint: NSEvent.mouseLocation())
		hm.removeContextHelp(for: sender)
	}
}
