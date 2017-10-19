//
//  SelfieDetailViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 14/8/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit
// BEGIN selfie_detail_import
import MapKit
// END selfie_detail_import

class SelfieDetailViewController: UIViewController {

    @IBOutlet weak var selfieNameField: UITextField!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var selfieImageView: UIImageView!
    
    // BEGIN selfie_detail_properties
    @IBOutlet weak var mapview: MKMapView!
    // END selfie_detail_properties
    
    // BEGIN selfie_detail_item
    var selfie: Selfie? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    // END selfie_detail_item
    
    // BEGIN selfie_detail_update
    @IBAction func doneButtonTapped(_ sender: Any)
    {
        self.selfieNameField.resignFirstResponder();
        
        // Ensure that we have a selfie to work with
        guard let selfie = selfie else
        {
            return
        }
        
        // Ensure that we have text in the field
        guard let text = selfieNameField?.text else
        {
            return
        }
        
        // Update the Selfie and save it
        selfie.title = text
        
        try? SelfieStore.shared.save(selfie: selfie)
    }
    // END selfie_detail_update
    
    // BEGIN selfie_detail_formatter
    // The date formatter used to format the time and date of the photo
    // It's created in a closure like this so that when it's used, it's
    // already configured the way we need it
    let dateFormatter = { () -> DateFormatter in
        let d = DateFormatter()
        d.dateStyle = .short
        d.timeStyle = .short
        return d
    }()
    // END selfie_detail_formatter
    
    // BEGIN selfie_detail_sharing
    @IBAction func shareSelfie(_ sender: Any) {
        guard let image = self.selfie?.image else {
            
            // pop up an alert dialogue letting us know it has failed
            let alertTitle = NSLocalizedString("Error", comment: "The title of an error message popup")
            let errorMessage = NSLocalizedString("Unable to share selfie without an image", comment: "Error mesage to be displayed when failing to share an image")
            let actionTitle = NSLocalizedString("OK", comment: "Button confirmation label")
            
            let alert = UIAlertController(title: alertTitle,
                                          message: errorMessage,
                                          preferredStyle: .alert)
            
            let action = UIAlertAction(title: actionTitle,
                                       style: .default,
                                       handler: nil)
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let activity = UIActivityViewController(activityItems: [image],
                                                applicationActivities: nil)
        
        self.present(activity, animated: true, completion: nil)
    }
    // END selfie_detail_sharing
    
    func configureView()
    {
        guard let selfie = selfie else
        {
            return
        }
        // Ensure that we have references to the controls we need
        guard let selfieNameField = selfieNameField,
              let selfieImageView = selfieImageView,
              let dateCreatedLabel = dateCreatedLabel
            else
        {
            return
        }
        
        selfieNameField.text = selfie.title
        dateCreatedLabel.text = dateFormatter.string(from: selfie.created)
        selfieImageView.image = selfie.image
        
        // BEGIN selfie_detail_configure
        if let position = selfie.position
        {
            self.mapview.setCenter(position.location.coordinate, animated: false)
            mapview.isHidden = false
        }
        // END selfie_detail_configure
    }
    
    // BEGIN selfie_detail_expandMap
    @IBAction func expandMap(_ sender: Any)
    {
        if let coordinate = self.selfie?.position?.location
        {
            let options = [
                MKLaunchOptionsMapCenterKey:
                    NSValue(mkCoordinate: coordinate.coordinate),
                MKLaunchOptionsMapTypeKey:
                    NSNumber(value: MKMapType.mutedStandard.rawValue)]
            
            let placemark = MKPlacemark(coordinate: coordinate.coordinate,
                                        addressDictionary: nil)
            let item = MKMapItem(placemark: placemark)
            item.name = selfie?.title
            
            item.openInMaps(launchOptions: options)
        }
    }
    // END selfie_detail_expandMap
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

