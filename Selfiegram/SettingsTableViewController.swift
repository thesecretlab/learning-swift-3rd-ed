//
//  SettingsTableViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 12/9/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var locationSwitch: UISwitch!
    
    @IBAction func locationSwitchToggled(_ sender: Any)
    {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
