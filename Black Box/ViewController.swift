//
//  ViewController.swift
//  Black Box
//
//  Created by Samuel B Heather on 06/02/2016.
//  Copyright © 2016 Samuel Brendon Heather. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        
        // TODO - if in session, go straight to in-session page!
    }
    
    @IBAction func CreateNewSession(sender: AnyObject) {
        // Generate a new session key
        let sessionKey = NSUUID().UUIDString
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(sessionKey, forKey: "sessionKey");
        defaults.synchronize()
        
        if (createSessionObject(sessionKey, startTime: Int(NSDate().timeIntervalSince1970))) {
            self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("InSessionViewController") , animated: true)
        }
    }
    
    func createSessionObject(sessionKey:String, startTime:Int) -> Bool {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Session",
            inManagedObjectContext:managedContext)
        
        let session = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        session.setValue(sessionKey, forKey: "sessionKey")
        session.setValue(startTime, forKey: "startTime")
        
        do {
            try managedContext.save()
            return true
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
            return false
        }

    }
    
    @IBAction func ViewSessions(sender: AnyObject) {
        self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("ViewSessionsViewController") , animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

