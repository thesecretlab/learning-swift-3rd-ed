//
//  SelfieListViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 14/8/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit
import CoreLocation

/// Responsible for the presentation of all selfies.
/// The jump off point for all Selfiegram actions.
/// From here:
/// * new selfies can be created
/// * existing selfies can be shared, deleted and viewed in detail
/// * settings can be configured
class SelfieListViewController: UITableViewController {

    var detailViewController: SelfieDetailViewController? = nil
    
    /// The list of Photo objects we're going to display
    var selfies : [Selfie] = []
    
    /// The formatter for creating the "1 minute ago"-style label
    let timeIntervalFormatter : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .spellOut
        formatter.maximumUnitCount = 1
        return formatter
    }()
    
    /// stores the last location the core location was able to determine
    var lastLocation : CLLocation?
    
    /// our location manager responsible for determining location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // adding a take a selfie button to the navigation bar
        let addSelfieButton = UIBarButtonItem(barButtonSystemItem: .add,
                                              target: self,
                                              action: #selector(createNewSelfie))
        navigationItem.rightBarButtonItem = addSelfieButton
        
        // loading the list of selfies from the selfie store
        do
        {
            // Get the list of photos, sorted by date (newer first)
            selfies = try SelfieStore.shared.listSelfies()
                .sorted(by: { $0.created > $1.created })
        }
        catch let error
        {
            let errorMessage = NSLocalizedString("Failed to load selfies:", comment: "error message will be appended")
            showError(message: "\(errorMessage) \(error.localizedDescription)")
        }
        
        if let split = splitViewController
        {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1]
                as? UINavigationController)?.topViewController
                as? SelfieDetailViewController
        }
        
        // configuring the location manager ready to determine locations
        self.locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        // reload all data in the tableview
        tableView.reloadData()
    }
    
    // MARK: - Helper methods
    
    /// Creates a new selfie and adds it to the store.
    /// Called after the user has selected a photo
    /// - parameter image: the image to be stored as part of the selfie
    func newSelfieTaken(image : UIImage)
    {
        // Create a new image
        let selfieTitle = NSLocalizedString("New Selfie", comment: "default name for a newly-created selfie")
        let newSelfie = Selfie(title: selfieTitle)
        
        // Store the image
        newSelfie.image = image
        
        if let location = self.lastLocation
        {
            newSelfie.position = Selfie.Coordinate(location: location)
        }
        
        // Attempt to save the photo
        do
        {
            try SelfieStore.shared.save(selfie: newSelfie)
        }
        catch let error
        {
            let errorMessage = NSLocalizedString("Can't save photo:", comment: "error message will be appended")
            showError(message: "\(errorMessage) \(error)")
            return
        }
        
        // Insert this photo into this view controller's list
        selfies.insert(newSelfie, at: 0)
        
        // Update the table view to show the new photo
        tableView.insertRows(at: [IndexPath(row: 0, section:0)], with: .automatic)
    }
    
    /// Starts the process of creating a new selfie.
    /// Called by the user pressing the + button in the navigation bar.
    /// Starts the location manager and brings up the camera view controller.
    @objc func createNewSelfie()
    {
        // Clear the last location, so that this next image doesn't
        // end up with an out-of-date location
        lastLocation = nil
        
        // checking if we should be getting location based on users prefrences
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
        
        // creating a camera view controller from the storyboard
        guard let navigation = self.storyboard?
                .instantiateViewController(withIdentifier: "CaptureScene")
                as? UINavigationController,
              let capture = navigation.viewControllers.first
                as? CaptureViewController
        else {
            fatalError("Failed to create the capture view controller!")
        }
        
        // configuring the camera to run the newSelfieTaken method on completion
        capture.completion = {(image : UIImage?) in
            
            if let image = image {
                self.newSelfieTaken(image: image)
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
        self.present(navigation, animated: true, completion: nil)
    }
    
    /// Convenience method to present an error alert
    /// - parameter message: the dialogue explaining the issue to the user
    func showError(message : String)
    {
        // Create an alert controller, with the message we received
        let alertTitle = NSLocalizedString("Error", comment: "The title of an error message popup")
        let alert = UIAlertController(title: alertTitle,
                                      message: message,
                                      preferredStyle: .alert)
        
        // Add an action to it - it won't do anything, but
        // doing this means that it will have a button to dismiss it
        let actionTitle = NSLocalizedString("OK", comment: "Button confirmation label")
        let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(action)
        
        // Show the alert and its message
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Segues
    
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

    // MARK: - Table View

    // called by the tableview, returns how many sections the tableview has
    // in our case we only have one section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // called by the tableview, returns how many rows each section has
    // as we only have one section, this is just the number of selfies
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return selfies.count
    }
    // called by the tableview, returns a ready to use cell
    // all of our cells are selfie cells and are configured the same way
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
            let agoText = NSLocalizedString("ago", comment: "to be appened to a measure of time, such as 'ten seconds ago'")
            cell.detailTextLabel?.text = "\(interval) \(agoText)"
        }
        else
        {
            cell.detailTextLabel?.text = nil
        }
        
        // Showing the selfie image to the left of the cell
        cell.imageView?.image = selfie.image
        
        return cell
    }
    // called by the tableview, ensures if a cell can be edited
    // as all our cells can be deleted and shared, always returns true.
    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    // called by the tableview, returns a list of allowed actions on this cell
    // in our case we have two actions, delete and share.
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // setting up the sharing action
        // giving it a title
        let shareActionTitle = NSLocalizedString("Share", comment: "title of a button that shares a selfie")
        // add a handler that will run a standard activity view controller when this action is triggered.
        let share = UITableViewRowAction(style: .normal, title: shareActionTitle)
        { (action, indexPath) in
        
            guard let image = self.selfies[indexPath.row].image else
            {
                let errorMessage = NSLocalizedString("Unable to share selfie without an image", comment: "Error mesage to be displayed when failing to share an image")
                self.showError(message: errorMessage)
                return
            }
            let activity = UIActivityViewController(activityItems: [image],
                                                applicationActivities: nil)
        
            self.present(activity, animated: true, completion: nil)
        }
        // giving the action the standard Selfiegram colour
        share.backgroundColor = self.view.tintColor
        
        // creating the delete action
        let deleteActionTitle = NSLocalizedString("Delete", comment: "title of a button that deletes a selfie")
        // add a handler that will remove the cell from the tableview and the selfie from the selfie store
        let delete = UITableViewRowAction(style: .destructive, title: deleteActionTitle)
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
                let errorMessage = NSLocalizedString("Failed to delete", comment: "title of the selfie that was deleted to be appended")
                self.showError(message: "\(errorMessage) \(selfieToRemove.title).")
            }
        }
        
        // returning our two actions in the order we want them to appear
        return [delete,share]
    }
}

// MARK: - Extensions

// extension to support handling location events
extension SelfieListViewController : CLLocationManagerDelegate
{
    // called when a location has been determined, this is stored locally.
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        self.lastLocation = locations.last
    }
    // called when an error occurs, presents an error message to the user.
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error)
    {
        showError(message: error.localizedDescription)
    }
}
