//
//  SelfieListViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 14/8/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit

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

    // BEGIN selfie_list_viewDidLoad
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
    }
    // END selfie_list_viewDidLoad

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    // MARK: - Helper methods
    
    // BEGIN selfie_list_newSelfieTaken
    // called after the user has selected a photo
    func newSelfieTaken(image : UIImage)
    {
        // Create a new image
        let newSelfie = Selfie(title: "New Selfie")
        
        // Store the image
        newSelfie.image = image
        
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
    // END selfie_list_newSelfieTaken
    
    // BEGIN selfie_list_createNewSelfie
    @objc func createNewSelfie()
    {
        // Create a new image picker
        let imagePicker = UIImagePickerController()
        
        // If a camera is available, use that; otherwise, use the photo library
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            imagePicker.sourceType = .camera
            
            // If the front-facing camera is available, use that
            if UIImagePickerController.isCameraDeviceAvailable(.front)
            {
                imagePicker.cameraDevice = .front
            }
        }
        else
        {
            imagePicker.sourceType = .photoLibrary
        }
        
        // We want this object to be notified when the user takes a photo
        imagePicker.delegate = self
        
        // Present the image picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    // END selfie_list_createNewSelfie
    
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
    // END selfie_list_canEditRowAt
    // BEGIN selfie_list_commitEditingStyle
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        // If this was a deletion, we have deleting to do
        if editingStyle == .delete
        {
            // Get the object from the content array
            let selfieToRemove = selfies[indexPath.row]
            
            // Attempt to delete the selfie
            do
            {
                try SelfieStore.shared.delete(selfie: selfieToRemove)
                
                // Remove it from that array
                selfies.remove(at: indexPath.row)
                
                // Remove the entry from the table view
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch
            {
                showError(message: "Failed to delete \(selfieToRemove.title).")
            }
        }
    }
    // END selfie_list_commitEditingStyle
    
    // END selfie_list_tableview
}

// MARK: - Extensions
// BEGIN selfie_list_extension
extension SelfieListViewController : UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
    // BEGIN selfie_list_picker_delegate
    // called when the user cancels selecting an image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    // called when the user has finished selecting an image
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage
            ?? info[UIImagePickerControllerOriginalImage] as? UIImage else
        {
            showError(message: "Couldn't get a picture from the image picker!")
            return
        }
        
        self.newSelfieTaken(image:image)
        
        // Get rid of the view controller
        self.dismiss(animated: true, completion: nil)
    }
    // END selfie_list_picker_delegate
}
// END selfie_list_extension
