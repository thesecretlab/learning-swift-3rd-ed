//
//  SettingsTableViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 12/9/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit
// BEGIN settings_import
import UserNotifications
// END settings_import

// BEGIN settings_enum
enum SettingsKey : String
{
    case saveLocation
}
// END settings_enum

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var reminderSwitch: UISwitch!
    
    // BEGIN settings_property
    private let notificationId = "SelfiegramReminder"
    // END settings_property
    
    // BEGIN settings_toggle_method
    @IBAction func reminderSwitchToggled(_ sender: Any)
    {
        // Get the notification center.
        let current = UNUserNotificationCenter.current()
        
        switch reminderSwitch.isOn
        {
        case true:
            // Defines what kinds of notifications we send.
            // In our case, a simple alert.
            let notificationOptions : UNAuthorizationOptions = [.alert]
            
            // The switch was turned on. Ask permission to send notifications.
            current.requestAuthorization(options: notificationOptions,
                               completionHandler: { (granted, error) in
                if granted
                {
                    // We've been granted permission. Queue the notification/
                    self.addNotificationRequest()
                }
                
                // Call updateReminderSwitch,
                // because we may have just learned that
                // we don't have permission to.
                self.updateReminderSwitch()
            })
        case false:
            // The switch was turned off.
            // Remove any pending notification request.
            current.removeAllPendingNotificationRequests()
        }
    }
    // END settings_toggle_method
    
    // BEGIN settings_add_notification
    func addNotificationRequest()
    {
        // Get the notification center
        let current = UNUserNotificationCenter.current()
        
        // Remove all existing notifications
        current.removeAllPendingNotificationRequests()
        
        // Prepare the notification content
        let content = UNMutableNotificationContent()
        content.title = "Take a selfie!"
        
        // Create date components to represent "10AM" (without specifying a day)
        var dateComponents = DateComponents()
        dateComponents.setValue(10, for: Calendar.Component.hour)
        
        // A trigger that goes off at this time, every day
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                    repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(identifier: self.notificationId,
                                            content: content,
                                            trigger: trigger)
        
        // Add it to the notification center
        current.add(request, withCompletionHandler: { (error) in
            self.updateReminderSwitch()
        })
    }
    // END settings_add_notification
    
    // BEGIN settings_update_switch
    func updateReminderSwitch()
    {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus
            {
            case .authorized:
                UNUserNotificationCenter.current()
                    .getPendingNotificationRequests(
                        completionHandler: { (requests) in
                    
                    // We are active if the list of requests contains one that's
                    // got the correct identifier
                    let active = requests
                        .filter({ $0.identifier == self.notificationId })
                        .count > 0
                    
                    // Our switch is enabled; it's on if we found our pending notification
                    self.updateReminderUI(enabled: true, active: active)
                })
                
            case .denied:
                // If the user has denied permission, the switch is off and disabled.
                self.updateReminderUI(enabled: false, active: false)
                
            case .notDetermined:
                // If the user hasn't been asked yet, the switch is enabled, but defaults to off.
                self.updateReminderUI(enabled: true, active: false)
            }
        }
    }
    // END settings_update_switch
    
    // BEGIN settings_update_ui
    private func updateReminderUI(enabled: Bool, active: Bool)
    {
        OperationQueue.main.addOperation {
            self.reminderSwitch.isEnabled = enabled
            self.reminderSwitch.isOn = active
        }
    }
    // END settings_update_ui
    
    @IBAction func locationSwitchToggled(_ sender: Any)
    {
        // Update the setting in UserDefaults.
        UserDefaults.standard.set(locationSwitch.isOn, forKey: SettingsKey.saveLocation.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure that the location switch is set correctly.
        locationSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKey.saveLocation.rawValue)
        
        // BEGIN settings_viewDidLoad
        updateReminderSwitch()
        // END settings_viewDidLoad
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
