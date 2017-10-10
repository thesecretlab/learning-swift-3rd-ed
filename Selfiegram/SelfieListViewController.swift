//
//  SelfieListViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 14/8/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit
// BEGIN selfie_list_import
import CoreLocation
// END selfie_list_import

class SelfieListViewController: UITableViewController {

    var detailViewController: SelfieDetailViewController? = nil
    
    // BEGIN selfie_array
    // The list of Photo objects we're going to display
    var selfies : [Selfie] = []
    // END selfie_array
    
    // BEGIN selfie_list_formatter
    // The formatter for creating the "1 minute ago"-style label
    let timeIntervalFormatter : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .spellOut
        formatter.maximumUnitCount = 1
        return formatter
    }()
    // END selfie_list_formatter
    
    // BEGIN selfie_list_lastLocation
    // stores the last location the core location was able to determine
    var lastLocation : CLLocation?
    // END selfie_list_lastLocation
    
    // BEGIN selfie_list_manager
    let locationManager = CLLocationManager()
    // END selfie_list_manager
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // BEGIN selfie_list_add_button
        let addSelfieButton = UIBarButtonItem(barButtonSystemItem: .add,
                                              target: self,
                                              action: #selector(createNewSelfie))
        navigationItem.rightBarButtonItem = addSelfieButton
        // END selfie_list_add_button
        
        // loading the list of selfies from the selfie store
        do
        {
            // Get the list of photos, sorted by date (newer first)
            selfies = try SelfieStore.shared.listSelfies()
                .sorted(by: { $0.created > $1.created })
        }
        catch let error
        {
            showError(message: "Failed to load selfies: \(error.localizedDescription)")
        }
        
        if let split = splitViewController
        {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1]
                as? UINavigationController)?.topViewController
                as? SelfieDetailViewController
        }
        
        // BEGIN selfie_list_viewDidLoad
        self.locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // END selfie_list_viewDidLoad
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        // BEGIN selfie_list_viewWillAppear
        // reload all data in the tableview
        tableView.reloadData()
        // END selfie_list_viewWillAppear
    }
    
    // MARK: - Helper methods
    
    // called after the user has selected a photo
    func newSelfieTaken(image : UIImage)
    {
        // Create a new image
        let newSelfie = Selfie(title: "New Selfie")
        
        // Store the image
        newSelfie.image = image
        
        // BEGIN selfie_list_newSelfieTaken
        if let location = self.lastLocation
        {
            newSelfie.position = Selfie.Coordinate(location: location)
        }
        // END selfie_list_newSelfieTaken
        
        // Attempt to save the photo
        do
        {
            try SelfieStore.shared.save(selfie: newSelfie)
        }
        catch let error
        {
            showError(message: "Can't save photo: \(error)")
            return
        }
        
        // Insert this photo into this view controller's list
        selfies.insert(newSelfie, at: 0)
        
        // Update the table view to show the new photo
        tableView.insertRows(at: [IndexPath(row: 0, section:0)], with: .automatic)
    }
    
    @objc func createNewSelfie()
    {
        // Clear the last location, so that this next image doesn't
        // end up with an out-of-date location
        lastLocation = nil
        
        // BEGIN selfie_list_createNewSelfie
        let shouldGetLocation =
            UserDefaults.standard.bool(forKey: SettingsKey.saveLocation.rawValue)
        
        if shouldGetLocation
        {
            // Handle our authorisation status
            switch CLLocationManager.authorizationStatus()
            {
            case .denied, .restricted:
                // We either don't have permission, or the user is
                // not permitted to use location services at all.
                // Give up at this point.
                return
            case .notDetermined:
                // We don't know if we have permission or not. Ask for it.
                locationManager.requestWhenInUseAuthorization()
            default:
                // We have permission; nothing to do here.
                break
            }
            // setting us to be the location manager delegate
            locationManager.delegate = self
            // Request a one-time location update.
            locationManager.requestLocation()
        }
        // END selfie_list_createNewSelfie
        
        // BEGIN selfie_list_capture_view_init
        guard let navigation = self.storyboard?
                .instantiateViewController(withIdentifier: "CaptureScene")
                as? UINavigationController,
              let capture = navigation.viewControllers.first
                as? CaptureViewController
        else {
            fatalError("Failed to create the capture view controller!")
        }
        // END selfie_list_capture_view_init
        
        //BEGIN selfie_list_capture_view_closure
        capture.completion = {(image : UIImage?) in
            
            if let image = image {
                self.newSelfieTaken(image: image)
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        // END selfie_list_capture_view_closure
        
        // BEGIN selfie_list_capture_present
        self.present(navigation, animated: true, completion: nil)
        // END selfie_list_capture_present
    }
    
    // BEGIN selfie_list_showError
    func showError(message : String)
    {
        // Create an alert controller, with the message we received
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        
        // Add an action to it - it won't do anything, but
        // doing this means that it will have a button to dismiss it
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        // Show the alert and its message
        self.present(alert, animated: true, completion: nil)
    }
    // END selfie_list_showError

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Segues
    
    // BEGIN selfie_list_segue
    // Called when we tap on a row.
    // The SelfieDetailViewController is given the photo.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showDetail"
        {
            if let indexPath = tableView.indexPathForSelectedRow
            {
                let selfie = selfies[indexPath.row]
                if let controller = (segue.destination as? UINavigationController)?
                    .topViewController as? SelfieDetailViewController
                {
                    controller.selfie = selfie
                    controller.navigationItem.leftBarButtonItem =
                        splitViewController?.displayModeButtonItem
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }
    // END selfie_list_segue

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // BEGIN selfie_list_tableview
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return selfies.count
    }
    override func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Get a cell from the table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)
        
        // Get a selfie and use it to configure the cell
        let selfie = selfies[indexPath.row]
        
        // Setting up the main label
        cell.textLabel?.text = selfie.title
        
        // Set up its time ago sub label
        if let interval =
            timeIntervalFormatter.string(from: selfie.created, to: Date())
        {
            cell.detailTextLabel?.text = "\(interval) ago"
        }
        else
        {
            cell.detailTextLabel?.text = nil
        }
        
        // Showing the selfie image to the left of the cell
        cell.imageView?.image = selfie.image
        
        return cell
    }
    // BEGIN selfie_list_canEditRowAt
    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    // BEGIN selfie_list_editActionsForRowAt
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let share = UITableViewRowAction(style: .normal, title: "Share")
        { (action, indexPath) in
        
            guard let image = self.selfies[indexPath.row].image else
            {
                self.showError(message: "Unable to share selfie without an image")
                return
            }
            let activity = UIActivityViewController(activityItems: [image],
                                                applicationActivities: nil)
        
            self.present(activity, animated: true, completion: nil)
        }
        share.backgroundColor = self.view.tintColor
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete")
        { (action, indexPath) in
            // Get the object from the content array
            let selfieToRemove = self.selfies[indexPath.row]
            
            // Attempt to delete the selfie
            do
            {
                try SelfieStore.shared.delete(selfie: selfieToRemove)
                
                // Remove it from that array
                self.selfies.remove(at: indexPath.row)
                
                // Remove the entry from the table view
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch
            {
                self.showError(message: "Failed to delete \(selfieToRemove.title).")
            }
        }
        
        return [delete,share]
    }
    // END selfie_list_editActionsForRowAt
    
    // END selfie_list_tableview
}

// MARK: - Extensions

// BEGIN selfie_list_extension
extension SelfieListViewController : CLLocationManagerDelegate
{
    // BEGIN selfie_list_didUpdateLocations
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        self.lastLocation = locations.last
    }
    // END selfie_list_didUpdateLocations
    // BEGIN selfie_list_location_error
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error)
    {
        showError(message: error.localizedDescription)
    }
    // END selfie_list_location_error
}
// END selfie_list_extension
