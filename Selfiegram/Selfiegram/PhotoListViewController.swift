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
    var photos : [Photo] = []
    
    // The last location that we saw from the location system
    var lastLocation : CLLocation?
    
    let locationManager = CLLocationManager()

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
        
        

        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(createNewPhoto))
        
        navigationItem.rightBarButtonItem = addButton
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = photos[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! PhotoDetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = photos[indexPath.row]
        cell.textLabel!.text = object.title
        cell.imageView!.image = object.image
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let photoToRemove = photos[indexPath.row]
            
            photos.remove(at: indexPath.row)
            
            do {
                try PhotoStore.shared.delete(image: photoToRemove)
            } catch {
                showError(message: "Failed to delete the image.")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Displays an error dialog box
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Called when the Add button is tapped.
    @objc func createNewPhoto() {
        
        // Create a new image picker
        let sourceType : UIImagePickerControllerSourceType
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sourceType = .camera
        } else {
            sourceType = .photoLibrary
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        
        // Present the image picker
        self.present(imagePicker, animated: true, completion: nil)
        
        // Clear the last location, so that this next image doesn't
        // end up with an out-of-date location
        lastLocation = nil
        
        // Does the user want us to try to get the location?
        let shouldTryGettingLocation = UserDefaults.standard.bool(forKey: SettingsKeys.setLocation.rawValue)
        
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
        
        // Store the location if we have one
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Failed to get the location: \(error)")
        lastLocation = nil
    }
}
