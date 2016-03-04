//
//  ViewController.swift
//  KisarazuTrafficSafetyMap
//
//  Created by Kouta on 2016/03/02.
//  Copyright © 2016年 Kouta. All rights reserved.
//

import UIKit

class ConfigViewController: UITableViewController {

    
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var sleepSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let restrainSleep = appDelegate.restrainSleep
        
        sleepSwitch.on = restrainSleep
        
        sleepSwitch.addTarget(self, action: "onChangeSleepSwitch:", forControlEvents: .ValueChanged)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onChangeSleepSwitch(sender: UISwitch) {
        if sender.on {
            UIApplication.sharedApplication().idleTimerDisabled = true
            appDelegate.restrainSleep = true
        }
        else {
            UIApplication.sharedApplication().idleTimerDisabled = false
            appDelegate.restrainSleep = false
        }
    }
 
}

