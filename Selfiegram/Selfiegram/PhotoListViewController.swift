//
//  MasterViewController.swift
//  Selfiegram
//
//  Created by Jon Manning on 20/7/17.
//  Copyright © 2017 Secret Lab. All rights reserved.
//

import UIKit

class PhotoListViewController: UITableViewController {

    var detailViewController: PhotoDetailViewController? = nil
    var photos : [Photo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewPhoto))
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
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func createNewPhoto() {
        
        let sourceType : UIImagePickerControllerSourceType
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sourceType = .camera
        } else {
            sourceType = .photoLibrary
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func newPhotoTaken(image : UIImage) {
        
    }

}

extension PhotoListViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Get either the edited or original image
        guard let
            image = info[UIImagePickerControllerEditedImage] as? UIImage
             ?? info[UIImagePickerControllerOriginalImage] as? UIImage else {
                showError(message: "Couldn't get the picture from the image picker!")
                return
        }
        
        self.newPhotoTaken(image: image)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
}


