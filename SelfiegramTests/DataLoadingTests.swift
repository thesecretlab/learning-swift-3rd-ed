//
//  DataLoadingTests.swift
//  SelfiegramTests
//
//  Created by Tim Nugent on 12/10/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import XCTest
@testable import Selfiegram

class DataLoadingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Remove all cached data
        let cacheURL = OverlayManager.cacheDirectoryURL
        
        guard let contents = try?
            FileManager.default.contentsOfDirectory(
                at: cacheURL,
                includingPropertiesForKeys: nil,
                options: []) else {
            XCTFail("Failed to list contents of directory \(cacheURL)")
            return
        }
        
        var complete = true
        for file in contents {
            do {
                try FileManager.default.removeItem(at: file)
            } catch let error {
                NSLog("Test setup: failed to remove item \(file); reason: \(error)")
                complete = false
            }
        }
        if !complete {
            XCTFail("Failed to delete contents of cache")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNoOverlaysAvailable() {
        
        // Arrange
        // Nothing to arrange here: our start condition is that there's no cached data
        
        // Act
        let availableOverlays = OverlayManager.shared.availableOverlays()
        
        // Assert
        XCTAssertEqual(availableOverlays.count, 0)
        
    }
    
    // The overlay manager can download updated information about the available overlays
    func testGettingOverlayInfo() {
        
        // Arrange
        let expectation = self.expectation(description: "Downloading finished")
        
        // Act
        var loadedInfo : OverlayManager.OverlayList?
        var loadedError : Error?
        OverlayManager.shared.refreshOverlays { (info, error) in
            
            loadedInfo = info
            loadedError = error
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
        // Assert
        XCTAssertNotNil(loadedInfo)
        XCTAssertNil(loadedError)
    }
    
    // The overlay manager can download overlay assets, making them available for use
    func testDownloadingOverlays() {
        
        // Arrange
        let loadingComplete = self.expectation(description: "Download complete")
        var availableOverlays : [Overlay] = []
        
        // Act
        OverlayManager.shared.loadOverlayAssets(refresh: true) {
            
            availableOverlays = OverlayManager.shared.availableOverlays()
            
            loadingComplete.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
        
        // Assert
        XCTAssertNotEqual(availableOverlays.count, 0)
    }
    
    // When the overlay manager is created, it has access to all previously cached overlays.
    func testDownloadedOverlaysAreCached() {
        
        // Arrange
        
        let downloadingOverlayManager = OverlayManager()
        let downloadExpectation = self.expectation(description: "Data downloaded")
        
        // Start downloading
        downloadingOverlayManager.loadOverlayAssets(refresh: true) {
            downloadExpectation.fulfill()
        }
        
        // Wait for downloads to finish
        waitForExpectations(timeout: 10.0, handler: nil)
        
        // Act
        
        // Simulate the overlay manager starting up by initialising a new one;
        // it will access the same files that were downloaded earlier
        let cacheTestOverlayManager = OverlayManager()
        
        // Assert
        
        // This overlay manager should see the cached data
        XCTAssertNotEqual(cacheTestOverlayManager.availableOverlays().count, 0)
        XCTAssertEqual(cacheTestOverlayManager.availableOverlays().count,
                       downloadingOverlayManager.availableOverlays().count)
    }
}
