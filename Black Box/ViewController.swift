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
        title = "\"Home\""
    }
    
    @IBAction func CreateNewSession(sender: AnyObject) {
        self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("InSessionViewController") as! UIViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

