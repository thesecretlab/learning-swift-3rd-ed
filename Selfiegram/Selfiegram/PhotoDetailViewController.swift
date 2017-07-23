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

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageName: UITextField!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    let dateFormatter = { () -> DateFormatter in
        let d = DateFormatter()
        d.dateStyle = .short
        d.timeStyle = .short
        return d
    }()
    
    func configureView() {
        // Update the user interface for the detail item.
        
        // Ensure that we have the photo
        guard let detail = detailItem else {
            return
        }
        
        // Ensure that we have references to the controls we need
        guard let imageName = imageName,
            let imageView = imageView,
            let dateCreatedLabel = dateCreatedLabel,
            let mapView = mapView else {
            return
        }
        
        imageName.text = detail.title
        imageView.image = detail.image
        
        let dateText = dateFormatter.string(from: detail.created)
        
        dateCreatedLabel.text = dateText
        
        // If the photo has a location, then center the map on it
        if let position = detail.position {
            
            let coordinates = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
            
            mapView.setCenter(coordinates, animated: false)
            
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Photo? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        
        guard let detail = detailItem else {
            return
        }
        
        guard let text = imageName?.text else {
            return
        }
        
        detail.title = text
        
        do {
            try PhotoStore.shared.save(image: detail)
        } catch let error {
            NSLog("Failed to save! \(error)")
        }
        
        
    }
    
}

