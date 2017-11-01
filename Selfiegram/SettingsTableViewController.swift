//
//  SettingsTableViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 12/9/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit
import UserNotifications

/// List of keys for settings
enum SettingsKey : String
{
    case saveLocation
}

/// Responsible for Selfiegram settings.
/// From here:
/// * location can be enabled or disabled
/// * reminders can be enabled or disabled
class SettingsTableViewController: UITableViewController {

    /// the toggle switch for location setting
    @IBOutlet weak var locationSwitch: UISwitch!
    /// the toggle switch for reminder notifications setting
    @IBOutlet weak var reminderSwitch: UISwitch!
    
    /// used to uniquely identify the notification in the noticiation centre
    private let notificationId = "SelfiegramReminder"
    
    /// called when the user toggles the reminder switch.
    /// sets the switch state based on notification permissions
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
    
    /// Queues a notification to the notification centre.
    /// To be called by the reminderSwitchToggled method
    func addNotificationRequest()
    {
        // Get the notification center
        let current = UNUserNotificationCenter.current()
        
        // Remove all existing notifications
        current.removeAllPendingNotificationRequests()
        
        // Prepare the notification content
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Take a selfie!", arguments: nil)
        
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
    
    /// toggles the state of the reminder switch based on notification permissions.
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
    
    /// sets the state of the reminder switch.
    /// to be called by other methods, always runs on the main queue.
    /// - parameter enabled: should the switch be enabled
    /// - parameter active: should the switch be on
    private func updateReminderUI(enabled: Bool, active: Bool)
    {
        OperationQueue.main.addOperation {
            self.reminderSwitch.isEnabled = enabled
            self.reminderSwitch.isOn = active
        }
    }
    
    /// called when the user toggles the location switch.
    /// Adds this new state to the user defaults.
    @IBAction func locationSwitchToggled(_ sender: Any)
    {
        // Update the setting in UserDefaults.
        UserDefaults.standard.set(locationSwitch.isOn, forKey: SettingsKey.saveLocation.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure that the location switch is set correctly.
        locationSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKey.saveLocation.rawValue)
        
        updateReminderSwitch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
