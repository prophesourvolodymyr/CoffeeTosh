//
//  CoffeeToshUITests.swift
//  CoffeeToshUITests
//
//  Created by Volodymur Vasualkiw on 3/3/26.
//

import XCTest

final class CoffeeToshUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testRemoteControlTabShowsHostSurface() throws {
        let app = XCUIApplication()
        app.launch()

        let remoteTab = app.buttons["Remote Control"]
        XCTAssertTrue(remoteTab.waitForExistence(timeout: 5))
        remoteTab.click()

        XCTAssertTrue(app.staticTexts["THIS MAC"].waitForExistence(timeout: 5))
        let addDevice = app.buttons["Add Device"]
        XCTAssertTrue(addDevice.waitForExistence(timeout: 5))
        addDevice.firstMatch.click()

        XCTAssertTrue(app.staticTexts["Waiting for your device"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["CONFIRMATION PHRASE"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].firstMatch.click()
    }

    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
