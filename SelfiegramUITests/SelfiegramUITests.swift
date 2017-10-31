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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // BEGIN UI_test_example
    func testExample() {
        let app = XCUIApplication()
        let currentSelfieCount = app.tables.element(boundBy: 0).cells.count
        
        app.terminate()
        app.launch()
        
        let tables = app.tables.element(boundBy: 0)
        XCTAssertEqual(currentSelfieCount, tables.cells.count)
    }
    // END UI_test_example
    
    // BEGIN ui_test_existence
    func testExistence() {
        // BEGIN ui_test_existence_code
        let app = XCUIApplication()
        app.tables.element(boundBy: 0).cells.element(boundBy: 0).tap()
        
        let mapView = app.maps.firstMatch
        // END ui_test_existence_code
        
        // BEGIN ui_test_existence_assert
        XCTAssert(mapView.exists)
        XCTAssert(mapView.isHittable)
        // END ui_test_existence_assert
    }
    // END ui_test_existence
    
    // BEGIN ui_test_photo
        func testPhotos () {
        // BEGIN ui_test_photo_alert_handler
        addUIInterruptionMonitor(withDescription: "Camera Permission Dialog")
        { (alert) -> Bool in
            alert.buttons["OK"].tap()
            return true
        }
        // END ui_test_photo_alert_handler
        
        // BEGIN ui_test_photo_record
        let app = XCUIApplication()
        
        // BEGIN ui_test_photo_setup
        let currentSelfieCount = app.tables.element(boundBy: 0).cells.count
        // END ui_test_photo_setup
        
        app.navigationBars["Selfies"].buttons["Add"].tap()
            
        app.children(matching: .window).element(boundBy: 0)
           .children(matching: .other).element.tap()
            
        app.navigationBars["Edit"].buttons["Done"].tap()
        // END ui_test_photo_record
        
        // BEGIN ui_test_photo_test
        let tables = app.tables.element(boundBy: 0)
        XCTAssertEqual(currentSelfieCount + 1, tables.cells.count)
        // END ui_test_photo_test
    }
    // END ui_test_photo
}
