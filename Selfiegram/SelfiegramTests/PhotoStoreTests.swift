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
    
    // A class for handling location updates
    class LocationManagerDelegate : NSObject, CLLocationManagerDelegate {
        
        typealias LocationHandler = (CLLocation) -> Void
        
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
    
    func testCreatingImagesWithLocation() {
        
        let manager = CLLocationManager()
        let delegate = LocationManagerDelegate()
        
        manager.delegate = delegate
        
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
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
        
        let newPhoto = Photo(title: "Photo with location")
        
        let expectation = XCTestExpectation(description: "Waiting for location to appear")
        
        delegate.locationHandler = { (location : CLLocation) in
            
            newPhoto.position = Photo.Coordinate(location: location)
            expectation.fulfill()
        }
        
        manager.startUpdatingLocation()
        
        self.wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(newPhoto.position)
        
        try! PhotoStore.shared.save(image: newPhoto)
    }
    
    func testCreatingImages() {
        
        // Arrange
        let newImage = Photo(title: "test image")
        
        // Act
        try! PhotoStore.shared.save(image: newImage)
        
        // Assert
        let allImages = try! PhotoStore.shared.listPhotos()
        
        guard let theImage = allImages.first(where: {$0.id == newImage.id }) else {
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
        try! PhotoStore.shared.save(image: newImage)
        let id = newImage.id
        
        // Act
        let loadedImage = PhotoStore.shared.load(imageID: id)
        
        // Assert
        XCTAssertNotNil(loadedImage, "The image should be loaded")
        XCTAssertEqual(loadedImage?.id, newImage.id,
                       "The loaded image should have the same ID")
        
    }
    
}
