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
            let date = NSDate(timeIntervalSince1970: startTime)

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
            let dateString = dateFormatter.stringFromDate(date)
            
            cell!.textLabel!.text = dateString
            
            return cell!
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
        var csvData:String="pingTime,latitude,longitude,location,speed,bearing,altitude,accuracy_location,accuracy_altitude"
        for ping:NSManagedObject in pings {
            csvData = csvData.stringByAppendingString(
                "\n" +
                valueForKeyAsString(ping, key: "pingTime") +
                valueForKeyAsString(ping, key: "lat") +
                valueForKeyAsString(ping, key: "long") +
                valueForKeyAsString(ping, key: "lat") + "," + valueForKeyAsString(ping, key: "long") +
                valueForKeyAsString(ping, key: "speed") +
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
    
    let fileName = "sample.csv"//"sample.txt"
    func writeToFile(csvData:String) {
//        let documents:String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
//        let path = String(documents).stringByAppendingPathComponent("file.plist")
        
//        let tmpDir = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
//        let path = tmpDir.URLByAppendingPathExtension(fileName)

//        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
//        let path = documentsPath
//        
//        // Create directory if it doesn't exist already
//        do {
//            try NSFileManager.defaultManager().createDirectoryAtPath(path.path!, withIntermediateDirectories: true, attributes: nil)
//        } catch let error as NSError {
//            NSLog("Unable to create directory \(error.debugDescription)")
//        }
//        
        
        let tmpDir = NSTemporaryDirectory() as String
//        let file: NSFileHandle? = NSFileHandle(forUpdatingAtPath: tmpDir.stringByAppendingString("sample.csv"))
        let file = tmpDir.stringByAppendingString("sample.csv")
        let fileUrl:NSURL = NSURL(fileURLWithPath: file)
        // Write File
        
        print(file)
        
        let filemgr = NSFileManager.defaultManager()
        
        filemgr.createFileAtPath(file, contents: csvData.dataUsingEncoding(NSUTF8StringEncoding),
            attributes: nil)
        
/*        do {
            try csvData.writeToFile(String(file, atomically: true, encoding: NSUTF8StringEncoding)
            print("File sample.txt created at tmp directory")
        } catch {
            
            print("Failed to create file")
            print("\(error)")
        }*/

        
        // Now show share sheet
        var sharingItems = [AnyObject]()
        sharingItems.append(fileUrl)
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}