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
    
    // BEGIN imageCache_property
    private var imageCache : [UUID:UIImage] = [:]
    // END imageCache_property
    
    // BEGIN documents_property
    var documentsFolder : URL
    {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .allDomainsMask).first!
    }
    // END documents_property
    
    // BEGIN store_get_image
    /// Gets an image by ID. Will be cached in memory for future lookups.
    /// - parameter id: the id of the selfie who's image you are after
    /// - returns: the image for that selfie or nil if it doesn't exist
    func getImage(id:UUID) -> UIImage?
    {
        // If this image is already in the cache, return it
        if let image = imageCache[id]
        {
            return image
        }
        
        // Figure out where this image should live
        let imageURL = documentsFolder.appendingPathComponent("\(id.uuidString)-image.jpg")
        
        // Get the data from this file; exit if we fail
        guard let imageData = try? Data(contentsOf: imageURL) else
        {
            return nil
        }
        
        // Get the image from this data; exit if we fail
        guard let image = UIImage(data: imageData) else
        {
            return nil
        }
        
        // Store the loaded image in the cache for next time
        imageCache[id] = image
        
        // Return the loaded image
        return image
    }
    // END store_get_image
    
    // BEGIN store_set_image
    /// Saves an image to disk.
    /// - parameter id: the id of the selfie you want this image associated with
    /// - parameter image: the image you want saved
    /// - Throws: `SelfieStoreObject` if it fails to save to disk
    func setImage(id:UUID, image : UIImage?) throws
    {
        // Figure out where the file would end up
        let fileName = "\(id.uuidString)-image.jpg"
        let destinationURL =
            self.documentsFolder.appendingPathComponent(fileName)
        
        if let image = image
        {
            // We have an image to work with, so save it out
            // Attempt to convert the image into JPEG data
            guard let data = UIImageJPEGRepresentation(image, 0.9) else
            {
                // Throw an error if this failed
                throw SelfieStoreError.cannotSaveImage(image)
            }
            
            // Attempt to write the data out
            try data.write(to: destinationURL)
        }
        else
        {
            // The image is nil, indicating that we want to remove the image.
            // Attempt to perform the deletion.
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        // Cache this image in memory. (If image is nil, this has the effect of
        // removing the entry from the cache dictionary.)
        imageCache[id] = image
    }
    // END store_set_image
    
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
}
// END selfie_store_class
