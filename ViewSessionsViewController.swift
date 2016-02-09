//
//  ViewSessionsViewController.swift
//  Black Box
//
//  Created by Samuel B Heather on 06/02/2016.
//  Copyright © 2016 Samuel Brendon Heather. All rights reserved.
//

import UIKit
import CoreData

class ViewSessionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var sessions = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Past Journeys"
        tableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Session")
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            sessions = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return sessions.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
            
            let session = sessions[indexPath.row]
            
            print(session.valueForKey("startTime"))
            let startTime:Double! = session.valueForKey("startTime")?.doubleValue
            let dateString = unixTimeToString(startTime)
            
            cell!.textLabel!.text = dateString
            
            return cell!
    }
    
    func unixTimeToString(unixTime:Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        return dateFormatter.stringFromDate(date)
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        var pings = [NSManagedObject]()
        
        // Get the requested session id
        let session:NSManagedObject = sessions[indexPath.row]
        let sessionKey:String = String(session.valueForKey("sessionKey"))
        print(sessionKey)
        
        // Now retrieve the pings from CoreData
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Ping")
        
        // Restrict to pings from this session:
        let predicate = NSPredicate(format: "sessionKey == %@", sessionKey)
        fetchRequest.predicate = predicate
        
        // Sort by pingTime
        let sortDescriptor = NSSortDescriptor(key: "pingTime", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            pings = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        // Pings now populated, need to export to CSV format
        let csvData:String = pingsToCsv(pings)
        print(csvData)
        
        writeToFile(csvData)
        
    }
    
    func pingsToCsv(pings:[NSManagedObject]) -> String {
        var csvData:String="pingTime,date,latitude,longitude,location,speed(m/s),speed(mph),bearing,altitude(m),accuracy_location(m),accuracy_altitude(m)"
        for ping:NSManagedObject in pings {
            csvData = csvData.stringByAppendingString(
                "\n" +
                valueForKeyAsString(ping, key: "pingTime") +
                "\"" + unixTimeToString((ping.valueForKey("pingTime")?.doubleValue)!) + "\"" + "," +
                valueForKeyAsString(ping, key: "lat") +
                valueForKeyAsString(ping, key: "long") +
                String(ping.valueForKey("lat")!) + "\",\"" + String(ping.valueForKey("long")!) + "," +
                valueForKeyAsString(ping, key: "speed") +
                valueForSpeedInMphString(ping, key: "speed") +
                valueForKeyAsString(ping, key: "bearing") +
                valueForKeyAsString(ping, key: "altitude") +
                valueForKeyAsString(ping, key: "accuracy_location") +
                valueForKeyAsString(ping, key: "accuracy_altitude")
            )
        }
        return csvData
    }
    
    func valueForKeyAsString(object:NSManagedObject, key:String) -> String {
        return String(object.valueForKey(key)!) + ","
    }
    
    func valueForSpeedInMphString(object:NSManagedObject, key:String) -> String {
        return String(Double(object.valueForKey(key)! as! NSNumber) * 2.23694) + ","
    }
    
    func writeToFile(csvData:String) {
        let fileName = "data.csv"
        let tmpDir = NSTemporaryDirectory() as String
        let filePath = tmpDir.stringByAppendingString(fileName)
        let filePathUrl:NSURL = NSURL(fileURLWithPath: filePath)
        
        // Write File
        let filemgr = NSFileManager.defaultManager()
        
        filemgr.createFileAtPath(filePath, contents: csvData.dataUsingEncoding(NSUTF8StringEncoding),
            attributes: nil)
        
        // Now show share sheet
        var sharingItems = [AnyObject]()
        sharingItems.append(filePathUrl)
        
        // TODO - should exclude incompatible services like social networks and gmail in the below
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}