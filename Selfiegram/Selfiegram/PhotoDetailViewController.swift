//
//  DetailViewController.swift
//  Selfiegram
//
//  Created by Jon Manning on 20/7/17.
//  Copyright © 2017 Secret Lab. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PhotoDetailViewController: UIViewController {
    
    // The image view, which shows the photo
    @IBOutlet weak var imageView: UIImageView!
    
    // The text field, which shows the image name and
    // also allows editing
    @IBOutlet weak var imageName: UITextField!
    
    // The label that shows the time and date it was created
    @IBOutlet weak var dateCreatedLabel: UILabel!
    
    // The map view, which shows the location of the photo (if one exists)
    @IBOutlet weak var mapView: MKMapView!
    
    // The photo we're showing.
    var photo: Photo? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // The date formatter used to format the time and date of the photo
    // It's created in a closure like this so that when it's used, it's
    // already configured the way we need it
    let dateFormatter = { () -> DateFormatter in
        let d = DateFormatter()
        d.dateStyle = .short
        d.timeStyle = .short
        return d
    }()
    
    func configureView() {
        // Update the user interface for the detail item.
        
        // Ensure that we have the photo
        guard let photo = photo else {
            return
        }
        
        // Ensure that we have references to the controls we need
        guard let imageName = imageName,
              let imageView = imageView,
              let dateCreatedLabel = dateCreatedLabel,
              let mapView = mapView else {
            return
        }
        
        // Update the label and image view
        imageName.text = photo.title
        imageView.image = photo.image
        
        // Format the date into a string and display it
        let dateText = dateFormatter.string(from: photo.created)
        dateCreatedLabel.text = dateText
        
        // If the photo has a location, then center the map on it
        if let position = photo.position {
            
            let coordinates = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
            
            mapView.setCenter(coordinates, animated: false)
            
            // Show the map because we have a location
            mapView.isHidden = false
        } else {
            // If it doesn't have a location, don't show the map at all
            mapView.isHidden = true
        }
    
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }



    // Called when the user taps the Done button on the keyboard while
    // editing the imageName field.
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        // Ensure that we have a Photo to work with
        guard let photo = photo else {
            return
        }
        
        // Ensure that we have text in the field
        guard let text = imageName?.text else {
            return
        }
        
        // Update the Photo and save it
        photo.title = text
        
        do {
            try PhotoStore.shared.save(photo: photo)
        } catch let error {
            NSLog("Failed to save! \(error)")
        }
    }
}

