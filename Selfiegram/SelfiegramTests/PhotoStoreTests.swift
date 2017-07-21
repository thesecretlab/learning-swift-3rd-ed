//
//  PhotoStoreTests.swift
//  SelfiegramTests
//
//  Created by Jon Manning on 20/7/17.
//  Copyright © 2017 Secret Lab. All rights reserved.
//

import XCTest
@testable import Selfiegram

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
    
    func testCreatingImages() {
        
        // Arrange
        let newImage = Photo(title: "test image")
        
        // Act
        try! PhotoStore.shared.save(image: newImage)
        
        // Assert
        let allImages = try! PhotoStore.shared.listImages()
        
        guard let theImage = allImages.first(where: {$0.id == newImage.id }) else {
            XCTFail("The list of images should contain the one we just created.")
            return
        }
        
        XCTAssertEqual(theImage.title, newImage.title)
    }
    
    func testSavingImages() {
        // Arrange
        var newImage = Photo(title: "test image")
        
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
