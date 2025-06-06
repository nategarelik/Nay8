//
//  Nay8UITests.swift
//  Nay8UITests
//
//  Created by Nathaniel Garelik on 06/05/25.
//  Copyright © 2025 Nathaniel Garelik. All rights reserved.
//

import XCTest

class Nay8UITests: XCTestCase {
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        print(Bundle.main.bundleIdentifier!)
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launch()
        
        let Nay8Window = XCUIApplication().windows["Nay8"]
        let disabledText = Nay8Window.staticTexts["Nay8 is currently disabled"]
        let disabledImage = Nay8Window.images["unavailable"]
        
        let enabledImage = Nay8Window.children(matching: .image).matching(identifier: "available").element(boundBy: 0)
        let enabledText = Nay8Window.staticTexts["Nay8 is currently enabled"]
        
        let disableButton = Nay8Window.buttons["Disable Nay8"]
        let enableButton = Nay8Window.buttons["Enable Nay8"]
        
        Nay8Window.click()
        XCTAssertFalse(disabledText.exists)
        XCTAssertFalse(disabledImage.exists)
        XCTAssertTrue(enabledText.exists)
        XCTAssertTrue(enabledImage.exists)
        XCTAssertFalse(enableButton.exists)
        
        disableButton.click()
        
        XCTAssertTrue(disabledText.exists)
        XCTAssertTrue(disabledImage.exists)
        XCTAssertFalse(enabledText.exists)
        XCTAssertTrue(enableButton.exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
