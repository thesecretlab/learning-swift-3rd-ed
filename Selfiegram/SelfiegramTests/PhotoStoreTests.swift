//
//  PhotoStoreTests.swift
//  SelfiegramTests
//
//  Created by Jon Manning on 20/7/17.
//  Copyright © 2017 Secret Lab. All rights reserved.
//

import XCTest
@testable import Selfiegram
import CoreLocation

// Needed for UILabel and UIGraphicsBegin/EndImageContext
import UIKit

class PhotoStoreTests: XCTestCase {
    
    // A helper function that creates an image filled with text.
    func createImage(text: String) -> UIImage {
        
        // Start a drawing canvas
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        
        // Close the canvas after we return from this function
        defer {
            UIGraphicsEndImageContext()
        }
        
        // Create a label
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.font = UIFont.systemFont(ofSize: 50)
        label.text = text
        
        // Draw the label in the current drawing context
        label.drawHierarchy(in: label.frame, afterScreenUpdates: true)
        
        // Return the image
        // (the ! means we either successfully get an image, or we crash)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    // A helper class for handling location updates,
    // used in 'testCreatingImagesWithLocation'
    class LocationManagerDelegate : NSObject, CLLocationManagerDelegate {
        
        // A convenience typealias to save us some potential confusion
        typealias LocationHandler = (CLLocation) -> Void
        
        // The (optional) code to run when we've received a location
        var locationHandler : LocationHandler?
        
        func locationManager(_ manager: CLLocationManager,
                             didUpdateLocations locations: [CLLocation]) {
            
            // Get the location (the most recent one is at the end of the 'locations' list
            guard let currentLocation = locations.last else {
                return
            }
            
            // Call the location handler if we have one
            locationHandler?(currentLocation)
        }
    }
    
    // Tests getting the location from the location system, and saving
    // an image that contains it.
    func testCreatingImagesWithLocation() {
        
        // Arrange
        
        // The location manager is how we ask for location data
        let manager = CLLocationManager()
        
        // Do we have permission to get the location?
        switch CLLocationManager.authorizationStatus() {
        case .restricted:
            // If the user isn't allowed to turn it on...
            fallthrough
        case .denied:
            // ...or if the user has explicitly turned if off,
            // then we can't run this test
            XCTFail("Location services are not available.")
            return
        case .notDetermined:
            // We don't know if we have permission. Ask for it.
            // The location won't be delivered until the user makes a decision,
            // so it's safe to carry on and call 'manager.requestLocation' in the meantime.
            manager.requestWhenInUseAuthorization()
        default:
            // We have permission.
            break
        }
        
        // Create a new photo to store.
        let newPhoto = Photo(title: "Photo with location")
        
        // Create an expectation; the test will not complete until
        // the expectation is fulfilled or broken.
        let expectation = XCTestExpectation(description: "Waiting for location to appear")
        
        // Create a LocationManagerDelegate so we can be told about the location,
        // and use it in this test
        let delegate = LocationManagerDelegate()
        manager.delegate = delegate
        
        // Tell the delegate what to do when we get a location
        delegate.locationHandler = { (location : CLLocation) in
            
            // We have a location store it in the photo.
            newPhoto.position = Photo.Coordinate(location: location)
            
            // Mark the expectation as fulfilled, so that the test can continue.
            expectation.fulfill()
        }
        
        // Act
        
        // Request a one-time delivery of the location from the manager.
        manager.requestLocation()
        
        // Pause the test, and wait up to 5 seconds for the expectation to be fulfilled.
        self.wait(for: [expectation], timeout: 5.0)
        
        // Assert
        
        // We should now have position data in the photo.
        XCTAssertNotNil(newPhoto.position)
        
        // Ensure that it can be saved.
        try! PhotoStore.shared.save(photo: newPhoto)
    }
    
    func testCreatingImages() {
        
        // Arrange
        let newImage = Photo(title: "test image")
        
        // Act
        try! PhotoStore.shared.save(photo: newImage)
        
        // Assert
        let allPhotos = try! PhotoStore.shared.listPhotos()
        
        guard let theImage = allPhotos.first(where: {$0.id == newImage.id }) else {
            XCTFail("The list of images should contain the one we just created.")
            return
        }
        
        XCTAssertEqual(theImage.title, newImage.title)
    }
    
    func testSavingImages() {
        // Arrange
        let newImage = Photo(title: "test image")
        
        // Act
        newImage.image = createImage(text: "😀")
        
        // Assert
        let loadedImage = PhotoStore.shared.getImage(id: newImage.id)
        
        XCTAssertNotNil(
            loadedImage,
            "The image should be loaded."
        )
    }
    
    func testLoadingImages() {
        
        // Arrange
        let newImage = Photo(title: "test image")
        try! PhotoStore.shared.save(photo: newImage)
        let id = newImage.id
        
        // Act
        let loadedImage = PhotoStore.shared.load(photoID: id)
        
        // Assert
        XCTAssertNotNil(loadedImage, "The image should be loaded")
        XCTAssertEqual(loadedImage?.id, newImage.id,
                       "The loaded image should have the same ID")
        
    }
    
}
