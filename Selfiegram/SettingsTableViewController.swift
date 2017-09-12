//
//  SettingsTableViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 12/9/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit

// BEGIN settings_enum
enum SettingsKey : String
{
    case saveLocation
}
// END settings_enum

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var locationSwitch: UISwitch!
    
    // BEGIN settings_toggle_method
    @IBAction func locationSwitchToggled(_ sender: Any)
    {
        // Update the setting in UserDefaults.
        UserDefaults.standard.set(locationSwitch.isOn, forKey: SettingsKey.saveLocation.rawValue)
    }
    // END settings_toggle_method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // BEGIN settings_viewDidLoad
        // Make sure that the location switch is set correctly.
        locationSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKey.saveLocation.rawValue)
        // END settings_viewDidLoad
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
