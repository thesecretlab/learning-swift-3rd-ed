//
//  SelfieDetailViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 14/8/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit

class SelfieDetailViewController: UIViewController {

    // BEGIN selfie_detail_properties
    @IBOutlet weak var selfieNameField: UITextField!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var selfieImageView: UIImageView!
    // END selfie_detail_properties
    
    // BEGIN selfie_detail_item
    var selfie: Selfie? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    // END selfie_detail_item
    
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
    
    // BEGIN selfie_detail_configure
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
    }
    // END selfie_detail_configure

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

