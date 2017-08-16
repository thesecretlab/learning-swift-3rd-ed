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

// BEGIN selfie_store_class
final class SelfieStore
{
    // BEGIN shared_property
    static let shared = SelfieStore()
    // END shared_property
    
    // BEGIN method_stubs
    /// Gets an image by ID. Will be cached in memory for future lookups.
    /// - parameter id: the id of the selfie who's image you are after
    /// - returns: the image for that selfie or nil if it doesn't exist
    func getImage(id:UUID) -> UIImage?
    {
        return nil
    }
    
    /// Saves an image to disk.
    /// - parameter id: the id of the selfie you want this image associated with
    /// - parameter image: the image you want saved
    /// - Throws: `SelfieStoreObject` if it fails to save to disk
    func setImage(id:UUID, image : UIImage?) throws
    {
        throw SelfieStoreError.cannotSaveImage(image)
    }
    
    /// Returns a list of Selfie objects loaded from disk.
    /// - returns: an array of all selfies previously saved
    /// - Throws: `SelfieStoreError` if it fails to load a selfie correctly from disk
    func listSelfies() throws -> [Selfie]
    {
        return []
    }
    
    /// Deletes a selfie, and its corresponding image, from disk.
    /// This function simply takes the ID from the Selfie you pass in,
    /// and gives it to the other version of the delete function.
    /// - parameter selfie: the selfie you want deleted
    /// - Throws: `SelfieStoreError` if it fails to delete the selfie from disk
    func delete(selfie: Selfie) throws
    {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
    
    /// Deletes a selfie, and its corresponding image, from disk.
    /// - parameter id: the id property of the Selfie you want deleted
    /// - Throws: `SelfieStoreError` if it fails to delete the selfie from the disk
    func delete(id: UUID) throws
    {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
    
    /// Attempts to load a selfie from disk.
    /// - parameter id: the id property of the Selfie object you want loaded from disk
    /// - returns: The selfie with the matching id, otherwise nil
    func load(id: UUID) -> Selfie?
    {
        return nil
    }
    
    /// Attempts to save a selfie to disk
    /// - parameter selfie: the selfie to save to disk
    /// - Throws: `SelfieStoreError` if it fails to write the data
    func save(selfie: Selfie) throws
    {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
    // END method_stubs
}
// END selfie_store_class











