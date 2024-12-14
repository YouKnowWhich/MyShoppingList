//
//  UserDefaultsManagerTests.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/12/14
//  
//
import XCTest
@testable import MyShoppingList

class UserDefaultsManagerTests: XCTestCase {
    var userDefaultsManager: UserDefaultsManager!
    let testKey = "testKey"

    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "TestDefaults")!
        userDefaultsManager = UserDefaultsManager(key: testKey, defaults: testDefaults)
    }

    override func tearDown() {
        userDefaultsManager.clearData()
        userDefaultsManager = nil
        super.tearDown()
    }

    func testSaveData() {
        let testData = "TestString"
        userDefaultsManager.saveData(testData)

        let savedData = userDefaultsManager.fetchData()
        XCTAssertEqual(savedData, testData, "Saved data should match fetched data")
    }

    func testClearData() {
        userDefaultsManager.saveData("Test")
        userDefaultsManager.clearData()

        XCTAssertNil(userDefaultsManager.fetchData(), "Cleared data should be nil")
    }
}
