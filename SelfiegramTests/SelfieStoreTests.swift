//
//  SelfieStoreTests.swift
//  SelfiegramTests
//
//  Created by Tim Nugent on 16/8/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import XCTest
// BEGIN testable_import
@testable import Selfiegram
// END testable_import
// BEGIN test_import
import UIKit
// END test_import

class SelfieStoreTests: XCTestCase {
    
    // BEGIN test_helper
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
    // END test_helper
    // BEGIN test_creation
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
    // END test_creation
    // BEGIN test_image_save
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
    // END test_image_save
}
