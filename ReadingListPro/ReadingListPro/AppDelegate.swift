//
//  AppDelegate.swift
//  ReadingListPro
//
//  Created by CoreCode on 18/05/16.
//  Copyright © 2016 CoreCode. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate, NSOutlineViewDataSource
{
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var sourceTable: NSTableView!
    @IBOutlet weak var detailTable: NSTableView!

    var results = [String: [[String : String]]]()

    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        let filePath = NSString(string: "~/Library/Safari/Bookmarks.plist").stringByExpandingTildeInPath

        if let d1 = NSDictionary(contentsOfFile: filePath) as? [String: AnyObject]
        {
            if let a1 = d1["Children"] as? [[String: AnyObject]]
            {
                for item in a1
                {
                    if "com.apple.ReadingList" == item["Title"] as? String
                    {
                        if let bookmarks = item["Children"] as? [[String: AnyObject]]
                        {
                            for bookmark in bookmarks
                            {
                                let urlstr = bookmark["URLString"] as! String,
                                urlstrfixed1 = urlstr.stringByReplacingOccurrencesOfString(".m.wikipedia.", withString: ".wikipedia."),
                                urlstrfixed2 = urlstrfixed1.stringByReplacingOccurrencesOfString("m.heise.", withString: "www.heise."),
                                urlstrfixed = urlstrfixed2.stringByReplacingOccurrencesOfString("m.faz.net", withString: "www.faz.net"),

                                url = NSURL(string: urlstrfixed),
                                titledict = bookmark["URIDictionary"] as! [String : AnyObject],
                                title = titledict["title"] as! String

                                print(url!.host!)

                                let newitem = ["url" : urlstrfixed, "title" : title]

                                if var bookmarkOnThisHost = results[url!.host!]
                                {
                                    bookmarkOnThisHost.append(newitem)
                                    results[url!.host!] = bookmarkOnThisHost
                                }
                                else
                                {
                                    results[url!.host!] = [newitem]
                                }

                            }
                        }
                    }
                }
            }
        }

        print(results)

        self.sourceTable.reloadData()
    }

    func applicationWillTerminate(aNotification: NSNotification)
    {
    }

    func numberOfRowsInTableView(tableView: NSTableView!) -> Int
    {
        if tableView == self.sourceTable
        {
            return self.results.count
        }
        else
        {
            let rowSource = self.sourceTable.selectedRow
            if (rowSource < 0) { return 0 }

            let key = Array(self.results.keys).sort( { self.results[$0]!.count > self.results[$1]!.count })[rowSource]
            let value = self.results[key]

            return value!.count;
        }
    }

    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject!
    {
        if tableView == self.sourceTable
        {
            let key = Array(self.results.keys).sort( { self.results[$0]!.count > self.results[$1]!.count })[row]
            let value = self.results[key]

            return "\(key) [\(value!.count)]"
        }
        else
        {

            let rowSource = self.sourceTable.selectedRow
            let key = Array(self.results.keys).sort( { self.results[$0]!.count > self.results[$1]!.count })[rowSource]
            let value = self.results[key]
            let website = value![row]


            if tableView.tableColumns.indexOf(tableColumn) == 0
            {
                return website["title"]
            }
            else
            {
                return website["url"]
            }
        }

    }


    func tableViewSelectionDidChange(notification: NSNotification)
    {
        if let tableView = notification.object as? NSTableView
        {
            if tableView == self.sourceTable
            {
                self.detailTable.reloadData()
            }
            else
            {
                if (self.detailTable.selectedRow < 0) { return; }

                let rowSource = self.sourceTable.selectedRow
                let key = Array(self.results.keys).sort( { self.results[$0]!.count > self.results[$1]!.count })[rowSource]
                let value = self.results[key]
                let website = value![self.detailTable.selectedRow]

                let urlstr = website["url"]
                let url = NSURL(string: urlstr!)

                NSWorkspace.sharedWorkspace().openURL(url!)
            }
        }
    }


    @IBAction func openAllSites(sender: AnyObject)
    {
       for key in self.results.keys
       {
            let value = self.results[key]
            for website in value!
            {

                let urlstr = website["url"]
                let url = NSURL(string: urlstr!)

                NSWorkspace.sharedWorkspace().openURL(url!)
            }
        }
    }

    @IBAction func openHostSites(sender: AnyObject)
    {

        let rowSource = self.sourceTable.selectedRow
        let key = Array(self.results.keys).sort( { self.results[$0]!.count > self.results[$1]!.count })[rowSource]
        let value = self.results[key]
        for website in value!
        {
            
            let urlstr = website["url"]
            let url = NSURL(string: urlstr!)
            
            NSWorkspace.sharedWorkspace().openURL(url!)
        }
        
    }
    
    @IBAction func exportCSV(sender: AnyObject)
    {

        let rowSource = self.sourceTable.selectedRow
        let key = Array(self.results.keys).sort( { self.results[$0]!.count > self.results[$1]!.count })[rowSource]
        let value = self.results[key]
        let export = NSMutableString(string: "URL,Title,Selection,Folder\n")

        for website in value!
        {
            let url = NSURL(string: website["url"]!)

            export.appendString("\"\(website["url"]!)\",\"\(website["title"]!)\",\"\",\"\(url!.host!)\"\n")
        }

		let filePath = NSString(string: "~/Desktop/export.csv").stringByExpandingTildeInPath

        try!
        export.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
    }
}

