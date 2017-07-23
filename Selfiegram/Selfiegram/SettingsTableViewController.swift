//
//  SettingsTableViewController.swift
//  Selfiegram
//
//  Created by Jon Manning on 23/7/17.
//  Copyright © 2017 Secret Lab. All rights reserved.
//

import UIKit

enum SettingsKeys : String {
    case setLocation
}

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var setLocationSwitch: UISwitch!
    
    @IBAction func locationSwitchUpdated(_ sender: Any) {
        UserDefaults.standard.set(setLocationSwitch.isOn, forKey: SettingsKeys.setLocation.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocationSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.setLocation.rawValue)
    }
        

}
