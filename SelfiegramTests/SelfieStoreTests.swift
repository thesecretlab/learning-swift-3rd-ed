//
//  SelfieStoreTests.swift
//  SelfiegramTests
//
//  Created by Tim Nugent on 16/8/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import XCTest
@testable import Selfiegram
import CoreLocation
import UIKit

class SelfieStoreTests: XCTestCase {
    
    /// A helper function to create images with text being used as the image content
    /// - returns: an image containing a representation of the text
    /// - parameter text: the string you want rendered into the image
    func createImage(text: String) -> UIImage
    {
        // Start a drawing canvas
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        
        // Close the canvas after we return from this function
        defer
        {
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
    
    func testCreatingSelfie()
    {
        // Arrange
        let selfieTitle = "Creation Test Selfie"
        let newSelfie = Selfie(title: selfieTitle)
        
        // Act
        try? SelfieStore.shared.save(selfie: newSelfie)
        
        // Assert
        let allSelfies = try! SelfieStore.shared.listSelfies()
        
        guard let theSelfie =
            allSelfies.first(where: {$0.id == newSelfie.id}) else
        {
            XCTFail("List of selfies should contain the one we just created.")
            return
        }
        
        XCTAssertEqual(selfieTitle, newSelfie.title)
    }
    
    func testSavingImage() throws
    {
        // Arrange
        let newSelfie = Selfie(title: "Selfie with image test")
        
        // Act
        newSelfie.image = createImage(text: "💯")
        try SelfieStore.shared.save(selfie: newSelfie)
        
        // Assert
        let loadedImage = SelfieStore.shared.getImage(id: newSelfie.id)
        
        XCTAssertNotNil(loadedImage,"The image should be loaded.")
    }
    
    func testLoadingSelfie() throws
    {
        // Arrange
        let selfieTitle = "Test loading selfie"
        let newSelfie = Selfie(title: selfieTitle)
        try SelfieStore.shared.save(selfie: newSelfie)
        let id = newSelfie.id
        
        // Act
        let loadedSelfie = SelfieStore.shared.load(id: id)
        
        // Assert
        XCTAssertNotNil(loadedSelfie, "The selfie should be loaded")
        XCTAssertEqual(loadedSelfie?.id, newSelfie.id,
                       "The loaded selfie should have the same ID")
        XCTAssertEqual(loadedSelfie?.created, newSelfie.created,
                       "The loaded selfie should have the same creation date")
        XCTAssertEqual(loadedSelfie?.title, selfieTitle,
                       "The loaded selfie should have the same title")
    }
    
    func testDeletingSelfie() throws
    {
        // Arrange
        let newSelfie = Selfie(title: "Test deleting a selfie")
        try SelfieStore.shared.save(selfie: newSelfie)
        let id = newSelfie.id
        
        // Act
        let allSelfies = try SelfieStore.shared.listSelfies()
        try SelfieStore.shared.delete(id: id)
        let selfieList = try SelfieStore.shared.listSelfies()
        let loadedSelfie = SelfieStore.shared.load(id: id)
        
        // Assert
        XCTAssertEqual(allSelfies.count - 1, selfieList.count,
                       "There should be one less selfie after deletion")
        XCTAssertNil(loadedSelfie, "deleted selfie should be nil")
        
    }
    
    func testLocationSelfie()
    {
        // a location for Hobart
        let location = CLLocation(latitude: -42.8819, longitude: 147.3238)
        
        // a new selfie with an image
        let newSelfie = Selfie(title: "Location Selfie")
        let newImage = createImage(text: "🐑")
        newSelfie.image = newImage
        
        // storing a location into the selfie
        newSelfie.position = Selfie.Coordinate(location: location)
        
        // saving the selfie with a location
        do
        {
            try SelfieStore.shared.save(selfie: newSelfie)
        }
        catch
        {
            XCTFail("failed to save the location selfie")
        }
        
        // loading the selfie back from the store
        let loadedSelfie = SelfieStore.shared.load(id: newSelfie.id)
        
        XCTAssertNotNil(loadedSelfie?.position)
        XCTAssertEqual(newSelfie.position, loadedSelfie?.position)
    }
}
