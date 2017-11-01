//
//  SelfieStore.swift
//  Selfiegram
//
//  Created by Tim Nugent on 14/8/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import Foundation
import UIKit.UIImage
import CoreLocation.CLLocation

/// Container object for the Selfie and all the data that combine to make a selfie.
/// Intended to be displayed to the user and stored locally.
class Selfie : Codable
{
    /// A coordinate class to hold latitude and longitude.
    /// Effectively a Codable wrapper to CLLocation.
    /// Location data will come from CoreLocation, be converted and saved.
    /// When used it will be loaded from disk and converted back to a CLLocation.
    struct Coordinate : Codable, Equatable
    {
        /// The latitude of the coordinate.
        /// Contains the same data as a CLLocationCoordinate2D
        var latitude : Double
        /// The longitude of the coordinate.
        /// Contains the same data as a CLLocationCoordinate2D
        var longitude : Double
        
        /// required equality method to conform to the Equatable protocol
        public static func == (lhs: Selfie.Coordinate, rhs: Selfie.Coordinate) -> Bool
        {
            return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
        }
        
        /// computed property to change the coordinate into a CoreLocation location
        var location : CLLocation
        {
            get
            {
                return CLLocation(latitude: self.latitude, longitude: self.longitude)
            }
            set
            {
                self.latitude = newValue.coordinate.latitude
                self.longitude = newValue.coordinate.longitude
            }
        }
        
        /// Initialiser that strips the lat/lon out of the location and saves it into the properties.
        /// - parameter location: The location will come from CoreLocation
        init (location : CLLocation)
        {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
    
    /// When it was created.
    let created : Date
    
    /// A unique ID, used to link this selfie to its image on disk.
    let id : UUID
    
    /// The name of this selfie
    var title = "New Selfie!"
    
    /// The location the selfie was taken
    var position : Coordinate?
    
    /// The image on disk for this selfie.
    /// Can fail to be set if the SelfieStore is unable to save the image to disk.
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
    
    /// Creates a new selfie with the title parameter as the title of the selfie.
    /// Initialises both created and id with relevant values.
    /// - parameter title: the name of the new selfie
    init(title: String)
    {
        self.title = title
        
        // the current time
        self.created = Date()
        // a new UUID
        self.id = UUID()
    }
}

/// Different types of errors that can occur with a selfie.
/// There are only one possible issue:
/// * unable to save image data
enum SelfieStoreError : Error
{
    case cannotSaveImage(UIImage?)
}

/// Singleton manager of the selfies.
/// Responsible for:
/// * Saving encoded selfies to disk
/// * Loading selfies from disk
/// * Saving images to disk
/// * Loading images to disk
/// * Deleting selfies and associated images
/// * Caches images once loaded
final class SelfieStore
{
    /// The shared instance used as part of the singleton.
    /// Is the primary interface into the class.
    static let shared = SelfieStore()
    
    /// The image cache.
    /// As selfies are loaded their images are cached here for faster retrieval.
    /// Will be lost whenever the application is exited.
    /// The disk form is always the canonical version.
    private var imageCache : [UUID:UIImage] = [:]
    
    /// Location of the documents directory.
    /// Used to save and load selfies and their images.
    var documentsFolder : URL
    {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .allDomainsMask).first!
    }
    
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
    
    /// Returns a list of Selfie objects loaded from disk.
    /// - returns: an array of all selfies previously saved
    /// - Throws: `SelfieStoreError` if it fails to load a selfie correctly from disk
    func listSelfies() throws -> [Selfie]
    {
        // Get the list of files in the documents directory
        let contents = try FileManager.default
            .contentsOfDirectory(at: self.documentsFolder,
         includingPropertiesForKeys: nil)
        
        // Get all files whose path extension is 'json',
        // load them as data, and decode them from JSON
        return try contents.filter { $0.pathExtension == "json" }
            .map { try Data(contentsOf: $0) }
            .map { try JSONDecoder().decode(Selfie.self, from: $0) }
    }
    
    /// Deletes a selfie, and its corresponding image, from disk.
    /// This function simply takes the ID from the Selfie you pass in,
    /// and gives it to the other version of the delete function.
    /// - parameter selfie: the selfie you want deleted
    /// - Throws: `SelfieStoreError` if it fails to delete the selfie from disk
    func delete(selfie: Selfie) throws
    {
        try delete(id: selfie.id)
    }
    
    /// Deletes a selfie, and its corresponding image, from disk.
    /// - parameter id: the id property of the Selfie you want deleted
    /// - Throws: `SelfieStoreError` if it fails to delete the selfie from the disk
    func delete(id: UUID) throws
    {
        let selfieDataFileName = "\(id.uuidString).json"
        let imageFileName = "\(id.uuidString)-image.jpg"
        
        let selfieDataURL = self.documentsFolder.appendingPathComponent(selfieDataFileName)
        let imageURL = self.documentsFolder.appendingPathComponent(imageFileName)
        
        // Remove the two files if they exist
        if FileManager.default.fileExists(atPath: selfieDataURL.path)
        {
            try FileManager.default.removeItem(at: selfieDataURL)
        }
        
        if FileManager.default.fileExists(atPath: imageURL.path)
        {
            try FileManager.default.removeItem(at: imageURL)
        }
        
        // wiping the image from the cache if its there
        imageCache[id] = nil
    }
    
    /// Attempts to load a selfie from disk.
    /// - parameter id: the id property of the Selfie object you want loaded from disk
    /// - returns: The selfie with the matching id, otherwise nil
    func load(id: UUID) -> Selfie?
    {
        let dataFileName = "\(id.uuidString).json"
        
        let dataURL = self.documentsFolder.appendingPathComponent(dataFileName)
        
        // Attempt to load the data in this file,
        // and then attempt to convert the data into an Photo,
        // and then return it.
        // Return nil if any of these steps fail.
        if let data = try? Data(contentsOf: dataURL),
           let selfie = try? JSONDecoder().decode(Selfie.self, from: data)
        {
            return selfie
        }
        else
        {
            return nil
        }
    }
    
    /// Attempts to save a selfie to disk
    /// - parameter selfie: the selfie to save to disk
    /// - Throws: `SelfieStoreError` if it fails to write the data
    func save(selfie: Selfie) throws
    {
        let selfieData = try JSONEncoder().encode(selfie)
        
        let fileName = "\(selfie.id.uuidString).json"
        let destinationURL = self.documentsFolder.appendingPathComponent(fileName)
        
        try selfieData.write(to: destinationURL)
    }
}
