//
//  InSessionViewController.swift
//  Black Box
//
//  Created by Samuel B Heather on 06/02/2016.
//  Copyright © 2016 Samuel Brendon Heather. All rights reserved.
//

import UIKit
import CoreData

class InSessionViewController: UIViewController {
    
    var sessionKey:String!
    var pingTimer:NSTimer!
    
    override func viewDidLoad() {
        print("view loaded")
        super.viewDidLoad()
        title = "Monitoring Journey"
        
        // Set session key
        let defaults = NSUserDefaults.standardUserDefaults()
        sessionKey = String(defaults.objectForKey("sessionKey"))
        
        // Start the Location Service
        LocationService.sharedInstance.startUpdatingLocation()
        
        pingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("ping"), userInfo: nil, repeats: true)
    }
    
    func ping() {
        let position = LocationService.sharedInstance.getLastLocation()
        
        if (position == nil) {
            print("Position was nil, not saving")
            return
        }

        let pingTime:Double = NSDate().timeIntervalSince1970
        let lat:Double! = position.coordinate.latitude
        let long:Double! = position.coordinate.longitude
        let speed:Double! = position.speed
        let bearing:Double! = position.course
        let altitude:Double! = position.altitude
        let accuracy_location:Double! = position.horizontalAccuracy
        let accuracy_altitude:Double! = position.verticalAccuracy
        
        if !savePing(pingTime, lat: lat, long: long, speed: speed, bearing: bearing, altitude: altitude, accuracy_location: accuracy_location, accuracy_altitude: accuracy_altitude, sessionKey: sessionKey) {
            print("Ping didn't save successfully")
        }
        else {
            print("Ping saved successfully")
        }
        
    }
    
    func savePing(pingTime:Double, lat:Double, long:Double, speed:Double,
        bearing:Double, altitude:Double, accuracy_location:Double,
        accuracy_altitude:Double, sessionKey:String) -> Bool {
            //1
            let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            //2
            let entity =  NSEntityDescription.entityForName("Ping",
                inManagedObjectContext:managedContext)
            
            let ping = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext: managedContext)
            
            //3
            ping.setValue(pingTime, forKey: "pingTime")
            ping.setValue(lat, forKey: "lat")
            ping.setValue(long, forKey: "long")
            ping.setValue(speed, forKey: "speed")
            ping.setValue(bearing, forKey: "bearing")
            ping.setValue(altitude, forKey: "altitude")
            ping.setValue(accuracy_location, forKey: "accuracy_location")
            ping.setValue(accuracy_altitude, forKey: "accuracy_altitude")
            ping.setValue(sessionKey, forKey: "sessionKey")
            
            //4
            do {
                try managedContext.save()
                //5
                return true
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
                return false
            }
    }
    
    override func viewWillDisappear(animated: Bool) {
        LocationService.sharedInstance.stopUpdatingLocation()
        pingTimer.invalidate()
        pingTimer = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

