//
//  SelfieStore.swift
//  Selfiegram
//
//  Created by Tim Nugent on 14/8/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import Foundation
// BEGIN model_imports
import UIKit.UIImage
// END model_imports

// BEGIN model_selfie_class_initial
class Selfie : Codable
{
    // BEGIN model_selfie_const_properties
    // When it was created.
    let created : Date
    
    // A unique ID, used to link this selfie to its image on disk.
    let id : UUID
    // END model_selfie_const_properties
    
    // BEGIN model_selfie_var_properties
    // The name of this selfie
    var title = "New Selfie!"
    // END model_selfie_var_properties
    
    // BEGIN model_selfie_computed
    // the image on disk for this selfie
    var image : UIImage?
    {
        get
        {
            return SelfieStore.shared.getImage(id: self.id)
        }
        set
        {
            try? SelfieStore.shared.setImage(id: self.id, image: newValue)
        }
    }
    // END model_selfie_computed
    
    // BEGIN model_selfie_init
    init(title: String)
    {
        self.title = title
        
        // the current time
        self.created = Date()
        // a new UUID
        self.id = UUID()
    }
    // END model_selfie_init
}
// END model_selfie_class_initial

// BEGIN selfie_error
enum SelfieStoreError : Error
{
    case cannotSaveImage(UIImage?)
}
// END selfie_error












