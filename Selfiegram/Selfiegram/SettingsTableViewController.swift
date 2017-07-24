//
//  SettingsTableViewController.swift
//  Selfiegram
//
//  Created by Jon Manning on 23/7/17.
//  Copyright © 2017 Secret Lab. All rights reserved.
//

import UIKit
import UserNotifications

// Contains the hard-coded strings used to get and set
// user settings via the UserDefaults system.
enum SettingsKeys : String {
    case setLocation
}

class SettingsTableViewController: UITableViewController {

    // The switch that controls whether locations should be added to photos.
    @IBOutlet weak var setLocationSwitch: UISwitch!
    
    // The switch that controls whether a reminder to take a photo should be sent.
    @IBOutlet weak var reminderSwitch: UISwitch!
    
    // Defines what kinds of notifications we send. In our case, a simple alert.
    let notificationOptions : UNAuthorizationOptions = [.alert]
    
    // Called when the reminder switch changes state.
    @IBAction func reminderSwitchUpdated(_ sender: Any) {
        
        // Get the notification center.
        let current = UNUserNotificationCenter.current()
        
        switch reminderSwitch.isOn {
        case true:
            
            // The switch was turned on. Ask permission to send notifications.
            current.requestAuthorization(options: notificationOptions, completionHandler: { (granted, error) in
                
                if granted {
                    // We've been granted permission. Queue the notification/
                    self.addNotificationRequest()
                }
                
                // Call updateNotificationsSwitch, because we may have just learned that
                // we don't have permission to.
                self.updateNotificationsSwitch()
                
            })
        case false:
            
            // The switch was turned off. Remove any pending notification request.
            current.removeAllPendingNotificationRequests()
        }
    }
    
    // Called when the location switch is turned on or off.
    @IBAction func locationSwitchUpdated(_ sender: Any) {
        
        // Update the setting in UserDefaults.
        UserDefaults.standard.set(setLocationSwitch.isOn, forKey: SettingsKeys.setLocation.rawValue)
    }
    
    // Called when the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure that the location switch is set correctly.
        setLocationSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.setLocation.rawValue)
        
        // And likewise for the notifications switch.
        updateNotificationsSwitch()
        
    }
    
    let notificationIdentifier = "SelfiegramReminder"
    
    func addNotificationRequest() {
        
        OperationQueue.main.addOperation {
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
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Create the request
            let request = UNNotificationRequest(identifier: self.notificationIdentifier,
                                                content: content,
                                                trigger: trigger)
            
            // Add it to the notification center
            current.add(request, withCompletionHandler: nil)
            
            self.updateNotificationsSwitch()
        }
        
        
    }
    
    // Perform the UI updates to the notification switch.
    // This can be called from any operation queue; it will
    // always perform its work on the main queue.
    func updateNotificationSwitchUI(enabled: Bool, active: Bool) {
        OperationQueue.main.addOperation {
            self.reminderSwitch.isOn = active
            self.reminderSwitch.isEnabled = enabled
        }
    }
    
    // Queries the notification system to see if we have permission to send notifications,
    // and whether a notification is queued. The switch is updated accordingly.
    func updateNotificationsSwitch() {
        
        // Find out if the user has granted permission to send notifications.
        // This is different to having a notification scheduled or not.
        
        // This won't pop up a request to grant permission (requestAuthorization does that),
        // so the user will only be asked to grant permission when they turn the switch
        // on for the first time.
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
            
            switch settings.authorizationStatus {
            case .authorized:
                
                // If we're authorized, the switch is enabled, and we need to
                // query the notification system to find out if the the switch
                // should be on or not
                
                UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
                    
                    // We are active if the list of requests contains one that's
                    // got the correct identifier
                    
                    let active = requests
                        .filter({ $0.identifier == self.notificationIdentifier })
                        .count > 0
                    
                    // Our switch is enabled; it's on if we found our pending notification
                    self.updateNotificationSwitchUI(enabled: true, active: active)
                })
                
                
            case .denied:
                
                // If the user has denied permission, the switch is off and disabled.
                self.updateNotificationSwitchUI(enabled: false, active: false)
                
            case .notDetermined:
                
                // If the user hasn't been asked yet, the switch is enabled, but defaults to off.
                self.updateNotificationSwitchUI(enabled: true, active: false)
            }
            
        }
    }
        

}
