//
//  MasterViewController.swift
//  Selfiegram
//
//  Created by Jon Manning on 20/7/17.
//  Copyright © 2017 Secret Lab. All rights reserved.
//

import UIKit
import CoreLocation

class PhotoListViewController: UITableViewController {

    var detailViewController: PhotoDetailViewController? = nil
    
    // The list of Photo objects we're displaying
    var photos : [Photo] = []
    
    // The last location that we saw from the location system
    var lastLocation : CLLocation?
    
    let locationManager = CLLocationManager()
    
    // The formatter for creating the "1 minute ago"-style label
    let timeIntervalFormatter : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .spellOut
        formatter.maximumUnitCount = 1
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            // Get the list of photos, sorted by date (newer first)
            photos = try PhotoStore.shared
                .listPhotos()
                .sorted(by: { $0.created > $1.created })
            
        } catch let error {
            showError(message: "Failed to list photos: " +
                "\(error.localizedDescription)")
        }
        
        // Do any additional setup after loading the
        // view, typically from a nib.
        
        locationManager.delegate = self
        
        // Get the left bar content, if any
        var leftBarContent = navigationItem.leftBarButtonItems ?? []
        
        // Add the edit button to it
        leftBarContent.append(editButtonItem)
        
        // And make these items appear in the left of the bar
        navigationItem.leftBarButtonItems = leftBarContent
        
        // Create the add button and put it in the right hand side of the bar
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(createNewPhoto))
        
        navigationItem.rightBarButtonItem = addButton
        
        // If we're in a split view controller, keep a reference to the detail view
        // controller that's shown in the other pane
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? PhotoDetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    // Called when we tap on a row. The PhotoDetailViewController is given the photo.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let photo = photos[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! PhotoDetailViewController
                controller.photo = photo
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    // This table view has a single section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // There are as many rows in the table view as there are photos in the array
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    // Called to prepare a cell for use.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a cell from the table view
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Get a photo, and use it to configure the cell
        let photo = photos[indexPath.row]
        
        // Set up its main label
        cell.textLabel!.text = photo.title
        
        // Set up its time ago label
        if let interval = timeIntervalFormatter.string(from: photo.created, to: Date()) {
            cell.detailTextLabel!.text = "\(interval) ago"
        } else {
            cell.detailTextLabel!.text = nil
        }
        
        
        cell.imageView!.image = photo.image
        
        // Return the cell to the table view for use
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Called when the user performs an edit action, like deleting a row.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // If this was a deletion, we have deleting to do
        if editingStyle == .delete {
            
            // Get the object from the content array
            let photoToRemove = photos[indexPath.row]
            
            // Remove it from that array
            photos.remove(at: indexPath.row)
            
            // Attempt to delete the photo
            do {
                try PhotoStore.shared.delete(photo: photoToRemove)
            } catch {
                showError(message: "Failed to delete the image.")
            }
            
            // Remove the entry from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Displays an error dialog box
    func showError(message: String) {
        // Create an alert controller, with the message we received
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        // Add an action to it - it won't do anything, but
        // doing this means that it will have a button to dismiss it
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        // Show the alert and its message
        self.present(alert, animated: true, completion: nil)
    }
    
    // Called when the Add button is tapped.
    @objc func createNewPhoto() {
        
        // Create a new image picker
        let imagePicker = UIImagePickerController()
        
        // If a camera is available, use that; otherwise, use the photo library
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            
            // If the front-facing camera is available, use that
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = .front
            }
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        // We want this object to be notified when the user takes a photo
        imagePicker.delegate = self
        
        // Present the image picker
        self.present(imagePicker, animated: true, completion: nil)
        
        // Clear the last location, so that this next image doesn't
        // end up with an out-of-date location
        lastLocation = nil
        
        // Does the user want us to try to get the location?
        let shouldTryGettingLocation = UserDefaults
            .standard.bool(forKey: SettingsKeys.setLocation.rawValue)
        
        if shouldTryGettingLocation {
            // Prepare to ask for location info
            
            switch CLLocationManager.authorizationStatus() {
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
            
            // We want to be notified when we get the location
            locationManager.delegate = self
            
            // Request a one-time location update.
            locationManager.requestLocation()
        }
        
    }
    
    // Called when the user takes a photo via the image picker.
    func newPhotoTaken(image : UIImage) {
        
        // Create a new image
        let newPhoto = Photo(title: "New Photo")
        
        // Store the image
        newPhoto.image = image
        
        // We may have a location stored in 'lastLocation', as a result
        // of the action taken in locationManager(_, didUpdateLocations:).
        
        // Store the location if we have it.
        if let location = self.lastLocation {
            newPhoto.position = Photo.Coordinate(location: location)
        }
        
        // Attempt to save the photo
        do {
            try PhotoStore.shared.save(image: newPhoto)
        } catch let error {
            showError(message: "Can't save photo: \(error)")
        }
        
        // Insert this photo into this view controller's list
        photos.insert(newPhoto, at: 0)
        
        // Update the table view to show the new photo
        tableView.insertRows(at: [IndexPath(row: 0, section:0)], with: .automatic)
        
    }

}

// Contains methods that respond to things
// reported by the UIImagePickerController
extension PhotoListViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Called when the user takes or selects a photo
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Get either the edited or original image
        guard let
            image = info[UIImagePickerControllerEditedImage] as? UIImage
             ?? info[UIImagePickerControllerOriginalImage] as? UIImage else {
                showError(message: "Couldn't get the picture from the image picker!")
                return
        }
        
        // Provide the new image to the view controller
        self.newPhotoTaken(image: image)
        
        // Get rid of the view controller
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // Called when the user taps the Cancel button
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Get rid of the view controller
        self.dismiss(animated: true, completion: nil)
        
    }
}

// Contains methods that respond to things
// reported by the CLLocationManager

extension PhotoListViewController : CLLocationManagerDelegate {
    
    // Called when we get a location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // The most recent location is at the end of the array, so store that.
        lastLocation = locations.last
    }
    
    // Called when we fail to get the location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Failed to get the location: \(error)")
        
        // Store nil in lastLocation, so that we're sure to not accidentally
        // store an incorrect location in a photo
        lastLocation = nil
    }
}
