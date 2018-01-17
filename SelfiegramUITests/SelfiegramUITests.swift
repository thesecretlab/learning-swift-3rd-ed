//
//  SelfiegramUITests.swift
//  SelfiegramUITests
//
//  Created by Tim Nugent on 14/8/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import XCTest

//@testable import Selfiegram

class SelfiegramUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        // BEGIN snapshot_setup
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        // END snapshot_setup
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let app = XCUIApplication()
        let currentSelfieCount = app.tables.element(boundBy: 0).cells.count
        
        app.terminate()
        app.launch()
        
        let tables = app.tables.element(boundBy: 0)
        XCTAssertEqual(currentSelfieCount, tables.cells.count)
    }
    
    func testExistence() {
        let app = XCUIApplication()
        app.tables.element(boundBy: 0).cells.element(boundBy: 0).tap()
        
        let mapView = app.maps.firstMatch
        
        XCTAssert(mapView.exists)
        XCTAssert(mapView.isHittable)
    }
    
        func testPhotos () {
        addUIInterruptionMonitor(withDescription: "Camera Permission Dialog")
        { (alert) -> Bool in
            alert.buttons["OK"].tap()
            return true
        }
        
        let app = XCUIApplication()
        
        let currentSelfieCount = app.tables.element(boundBy: 0).cells.count
        
        app.navigationBars["Selfies"].buttons["Add"].tap()
            
        app.children(matching: .window).element(boundBy: 0)
           .children(matching: .other).element.tap()
            
        app.navigationBars["Edit"].buttons["Done"].tap()
        
        let tables = app.tables.element(boundBy: 0)
        XCTAssertEqual(currentSelfieCount + 1, tables.cells.count)
    }
    
    // BEGIN snapshot_handler_methods
    func testScreenshots() {
        
        // BEGIN snapshot_handler_methods_code
        let app = XCUIApplication()
        // BEGIN snapshot_handler_methods_code_snapshot
        snapshot("MainApp")
        // END snapshot_handler_methods_code_snapshot
        
        app.navigationBars["Photos"].buttons["Settings"].tap()
        // BEGIN snapshot_handler_methods_code_snapshot
        snapshot("Settings")
        // END snapshot_handler_methods_code_snapshot
        
        app.navigationBars.buttons["Photos"].tap()
        // END snapshot_handler_methods_code
    }
    // END snapshot_handler_methods
}
