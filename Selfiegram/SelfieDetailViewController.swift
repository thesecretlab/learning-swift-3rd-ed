//
//  SelfieDetailViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 14/8/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit
import MapKit

/// Responsible for showing a single selfie in detail
/// From here:
/// * selfie title can be edited
/// * Selfie information can be viewed
class SelfieDetailViewController: UIViewController {

    /// displays the title of the selfie, can be edited
    @IBOutlet weak var selfieNameField: UITextField!
    /// displays the date the selfie was created
    @IBOutlet weak var dateCreatedLabel: UILabel!
    /// displays the photo associated with the selfie
    @IBOutlet weak var selfieImageView: UIImageView!
    
    /// the preview map showing where the selfie was taken.
    /// Only appears when the selfie has a location
    @IBOutlet weak var mapview: MKMapView!
    
    /// the selfie being shown in detail.
    /// When changed it triggers an updates to the view
    var selfie: Selfie? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    /// called when the done button in the navigation bar is tapped
    /// updates the selfie with the store
    @IBAction func doneButtonTapped(_ sender: Any)
    {
        self.selfieNameField.resignFirstResponder()
        
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
    
    /// The date formatter used to format the time and date of the photo.
    /// It's created in a closure like this so that when it's used, it's
    /// already configured the way we need it
    let dateFormatter = { () -> DateFormatter in
        let d = DateFormatter()
        d.dateStyle = .short
        d.timeStyle = .short
        return d
    }()
    
    /// called when the user taps on the share button in the navigation bar.
    /// Creates an activity view controller to perform the sharing or an error display otherwise
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
        // creating the sharing activity view controller
        let activity = UIActivityViewController(activityItems: [image],
                                                applicationActivities: nil)
        // presenting it
        self.present(activity, animated: true, completion: nil)
    }
    
    /// sets the various UI elements to display their information from the selfie
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
        
        // setting each element to display their relevant selfie information
        selfieNameField.text = selfie.title
        dateCreatedLabel.text = dateFormatter.string(from: selfie.created)
        selfieImageView.image = selfie.image
        
        if let position = selfie.position
        {
            self.mapview.setCenter(position.location.coordinate, animated: false)
            mapview.isHidden = false
        }
    }
    
    /// called when the user taps on the preview map.
    /// Moves to the Maps app itself.
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
