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

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        let filePath = NSString(string: "~/Library/Safari/Bookmarks.plist").expandingTildeInPath

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
                                urlstrfixed1 = urlstr.replacingOccurrences(of: ".m.wikipedia.", with: ".wikipedia."),
                                urlstrfixed2 = urlstrfixed1.replacingOccurrences(of: "m.heise.", with: "www.heise."),
                                urlstrfixed = urlstrfixed2.replacingOccurrences(of: "m.faz.net", with: "www.faz.net"),

                                url = URL(string: urlstrfixed),
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

    func applicationWillTerminate(_ aNotification: Notification)
    {
    }

    func numberOfRowsInTableView(_ tableView: NSTableView!) -> Int
    {
        if tableView == self.sourceTable
        {
            return self.results.count
        }
        else
        {
            let rowSource = self.sourceTable.selectedRow
            if (rowSource < 0) { return 0 }

            let key = Array(self.results.keys).sorted( isOrderedBefore: { self.results[$0]!.count > self.results[$1]!.count })[rowSource]
            let value = self.results[key]

            return value!.count;
        }
    }

    func tableView(_ tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject!
    {
        if tableView == self.sourceTable
        {
            let key = Array(self.results.keys).sorted( isOrderedBefore: { self.results[$0]!.count > self.results[$1]!.count })[row]
            let value = self.results[key]

            return "\(key) [\(value!.count)]"
        }
        else
        {

            let rowSource = self.sourceTable.selectedRow
            let key = Array(self.results.keys).sorted( isOrderedBefore: { self.results[$0]!.count > self.results[$1]!.count })[rowSource]
            let value = self.results[key]
            let website = value![row]


            if tableView.tableColumns.index(of: tableColumn) == 0
            {
                return website["title"]
            }
            else
            {
                return website["url"]
            }
        }

    }


    func tableViewSelectionDidChange(_ notification: Notification)
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
                let key = Array(self.results.keys).sorted( isOrderedBefore: { self.results[$0]!.count > self.results[$1]!.count })[rowSource]
                let value = self.results[key]
                let website = value![self.detailTable.selectedRow]

                let urlstr = website["url"]
                let url = URL(string: urlstr!)

                NSWorkspace.shared().open(url!)
            }
        }
    }


    @IBAction func openAllSites(_ sender: AnyObject)
    {
       for key in self.results.keys
       {
            let value = self.results[key]
            for website in value!
            {

                let urlstr = website["url"]
                let url = URL(string: urlstr!)

                NSWorkspace.shared().open(url!)
            }
        }
    }

    @IBAction func openHostSites(_ sender: AnyObject)
    {

        let rowSource = self.sourceTable.selectedRow
        let key = Array(self.results.keys).sorted( isOrderedBefore: { self.results[$0]!.count > self.results[$1]!.count })[rowSource]
        let value = self.results[key]
        for website in value!
        {
            
            let urlstr = website["url"]
            let url = URL(string: urlstr!)
            
            NSWorkspace.shared().open(url!)
        }
        
    }
    
    @IBAction func exportCSV(_ sender: AnyObject)
    {

        let rowSource = self.sourceTable.selectedRow
        let key = Array(self.results.keys).sorted( isOrderedBefore: { self.results[$0]!.count > self.results[$1]!.count })[rowSource]
        let value = self.results[key]
        let export = NSMutableString(string: "URL,Title,Selection,Folder\n")

        for website in value!
        {
            let url = URL(string: website["url"]!)

            export.append("\"\(website["url"]!)\",\"\(website["title"]!)\",\"\",\"\(url!.host!)\"\n")
        }

		let filePath = NSString(string: "~/Desktop/export.csv").expandingTildeInPath

        try!
        export.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8.rawValue)
    }
}

