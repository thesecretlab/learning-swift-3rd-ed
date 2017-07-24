//
//  PhotoStore.swift
//  Selfiegram
//
//  Created by Jon Manning on 20/7/17.
//  Copyright © 2017 Secret Lab. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Photo : Codable {
    
    // Stores latitude and longitude in a Codable form.
    // (Basically, this is done because CLLocation isn't codable.)
    struct Coordinate: Codable {
        var latitude: Double
        var longitude: Double
        
        init (location : CLLocation) {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
        
        var location : CLLocation {
            return CLLocation(latitude: self.latitude, longitude: self.longitude)
        }
    }
    
    // The name of this photo
    var title : String = "New image"
    
    // When it was created.
    var created : Date = Date()
    
    // The coordinates for where the photo was taken. Optional.
    var position : Coordinate?
    
    // A unique ID, used to link this photo to its image on disk.
    var id : String = UUID().uuidString
    
    init(title: String) {
        self.title = title
    }
    
    
    var image : UIImage? {
        get {
            return PhotoStore.shared.getImage(id: self.id)
        }
        set {
            try! PhotoStore.shared.setImage(id: self.id, image: newValue)
        }
    }
    
}

enum PhotoStoreError : Error {
    case cannotSaveImage(UIImage)
}

class PhotoStore {
    
    // The single shared instance
    static let shared = PhotoStore()
    
    // Caches previously loaded images
    var imageCache : [String:UIImage] = [:]
    
    // The URL to the folder that contains all
    // files for this app
    var documentsFolder : URL {
        
        return FileManager
            .default
            .urls(for: .documentDirectory,
                  in: .allDomainsMask)
            .first!
    }
    
    // Gets an image by ID. It's cached in memory for future lookups.
    func getImage(id:String) -> UIImage? {
        // If this image is already in the cache, return it
        if let image = imageCache[id] {
            return image
        }
        
        // Figure out where this image should live
        let imageURL = documentsFolder
            .appendingPathComponent("\(id)-image.jpg")
        
        // Get the data from this file; exit if we fail
        guard let imageData = try? Data(contentsOf: imageURL) else {
            return nil
        }
        
        // Get the image from this data; exit if we fail
        guard let image = UIImage(data: imageData) else {
            return nil
        }
        
        // Store the loaded image in the cache for next time
        imageCache[id] = image
        
        // Return the loaded image
        return image
    }
    
    // Saves an image to disk.
    func setImage(id:String, image : UIImage?) throws {
        
        // Figure out where the file would end up
        let fileName = "\(id)-image.jpg"
        let destinationURL = self.documentsFolder.appendingPathComponent(fileName)
        
        if let image = image {
            
            // We have an image to work with, so save it out
            
            // Attempt to convert the image into JPEG data
            guard let data = UIImageJPEGRepresentation(image, 0.9) else {
                
                // Throw an error if this failed
                throw PhotoStoreError.cannotSaveImage(image)
            }
            
            // Attempt to write the data out
            try data.write(to: destinationURL)
            
        } else {
            // The image is nil, indicating that we want to remove the image.
            
            // Attempt to perform the deletion.
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        // Cache this image in memory. (If image is nil, this has the effect of
        // removing the entry from the cache dictionary.)
        imageCache[id] = image
        
    }
    
    // Returns a list of Photo objects loaded from disk.
    func listPhotos() throws -> [Photo] {
        
        // Get the list of files in the documents directory
        let contents = try FileManager
            .default
            .contentsOfDirectory(at: self.documentsFolder,
                                 includingPropertiesForKeys: nil)
        
        // Get all files whose path extension is 'json',
        // load them as data, and decode them from JSON
        // into
        return try contents
            .filter { $0.pathExtension == "json" }
            .map { try Data(contentsOf: $0) }
            .map { try JSONDecoder().decode(Photo.self, from: $0) }
        
        
        
    }
    
    // Deletes a photo, and its corresponding image, from disk.
    // This function simply takes the ID from the Photo you pass in,
    // and gives it to the other version of the delete function.
    func delete(photo : Photo) throws {
        try delete(imageID: photo.id)
    }
    
    // Deletes a photo, and its corresponding image, from disk.
    func delete(photoID : String) throws {
        
        let photoDataFileName = "\(photoID).json"
        let imageFileName = "\(photoID)-image.jpg"
        
        let photoDataURL = self.documentsFolder.appendingPathComponent(photoDataFileName)
        let imageURL = self.documentsFolder.appendingPathComponent(imageFileName)
        
        // Remove the two files if they exist
        if FileManager.default.fileExists(atPath: photoDataURL.path) {
            try FileManager.default.removeItem(at: photoDataURL)
        }
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            try FileManager.default.removeItem(at: imageURL)
        }
        
    }
    
    // Attempts to save a photo, and its image, to disk.
    func save(image : Photo) throws {
        
        let photoData = try JSONEncoder().encode(image)
        
        let fileName = "\(image.id).json"
        let destinationURL = self.documentsFolder.appendingPathComponent(fileName)
        
        try photoData.write(to: destinationURL)
    }
    
    func load(imageID : String) -> Photo? {
        let dataFileName = "\(imageID).json"
        
        let dataURL = self.documentsFolder.appendingPathComponent(dataFileName)
        
        // Attempt to load the data in this file,
        // and then attempt to convert the data into an Photo,
        // and then return it.
        // Return nil if any of these steps fail.
        if let data = try? Data(contentsOf: dataURL),
            let photo = try? JSONDecoder().decode(Photo.self, from: data) {
            return photo
        } else {
            return nil
        }
        
    }
    
}
