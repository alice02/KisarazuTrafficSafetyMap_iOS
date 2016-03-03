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
        print("back")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

