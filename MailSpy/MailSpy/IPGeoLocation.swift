//
//  IPGeoLocation.swift
//  MailSpy
//
//  Created by CoreCode on 14.12.14.
/*	Copyright © 2018 CoreCode Limited
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitationthe rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

import Foundation

class IPGeoLocation
{
    var longitude : Double?
    var latitude : Double?
    var country : String
    var region : String
    var city : String
    var zip : String
    var isp : String
    var asn : String
    var msg : String
    var url : String
    var query : String
    
    init?(_ ipstring: String)
	{
        longitude = nil
        latitude = nil
        country = ""
        region = ""
        city = ""
        zip = ""
        isp = ""
        asn = ""
        msg = ""
        url = ""
        query = ""

        if let data = NSData(contentsOf: NSURL(string: "http://ip-api.com/json/" + ipstring)! as URL)
        {
            let json = (try! JSONSerialization.jsonObject(with: data as Data, options: [])) as! NSDictionary
            
            if json["status"] as! String == "success"
            {
                longitude = json["lon"] as? Double
                latitude = json["lat"] as? Double
                country = json["country"] as! String
                region = json["regionName"] as! String
                city = json["city"] as! String
                zip = json["zip"] as! String
                isp = json["isp"] as! String
                asn = json["as"] as! String
                query = json["query"] as! String
  
                msg = "Geolocation by IP-API.com"
                url = "http://ip-api.com"
                
                return
            }
        }
                
        
        if let data = NSData(contentsOf: NSURL(string: "http://api.db-ip.com/addrinfo?addr=" + ipstring + "&api_key=bed383fd5e8efe3355ef79bb717dfcbd82850bb1")! as URL)
        {
            let json = (try! JSONSerialization.jsonObject(with: data as Data, options: [])) as! NSDictionary
            
            if let bla = json["city"] as! String?
            {
                if (bla.utf16.count > 2)
                {
                    
                    longitude = nil
                    latitude = nil
                    zip = ""
                    isp = ""
                    asn = ""
                    
                    country = json["country"] as! String
                    region = json["stateprov"] as! String
                    city = json["city"] as! String
                    query = json["address"] as! String

                    
                    msg = "Geolocation by db-ip.com"
                    url = "http://www.db-ip.com"
                    
                    return
                }
            }
        }

        
        return nil
    }
}
