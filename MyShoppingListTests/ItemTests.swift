//
//  ItemTests.swift
//  MyShoppingList
//
//  Created by Yuchinante on 2024/12/14
//
//
@testable import MyShoppingList
import XCTest

final class ItemTests: XCTestCase {

    func testItemInitialization() {
        let id = UUID()
        let name = "Milk"
        let isChecked = false
        let category = "Dairy"
        let purchaseDate = Date()

        let item = Item(id: id, name: name, isChecked: isChecked, category: category, purchaseDate: purchaseDate)

        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.name, name)
        XCTAssertEqual(item.isChecked, isChecked)
        XCTAssertEqual(item.category, category)
        XCTAssertEqual(item.purchaseDate, purchaseDate)
    }

    func testItemEncodingAndDecoding() throws {
        let id = UUID()
        let testDate = Date()
        let item = Item(id: id, name: "Eggs", isChecked: true, category: "Poultry", purchaseDate: testDate)

        // JSON エンコードを実行
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(item)

        // JSON デコードを実行
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedItem = try decoder.decode(Item.self, from: data)

        // 日付を文字列に変換して比較
        let formatter = ISO8601DateFormatter()
        let originalDateString = formatter.string(from: item.purchaseDate!)
        let decodedDateString = formatter.string(from: decodedItem.purchaseDate!)
        XCTAssertEqual(originalDateString, decodedDateString, "Purchase date strings should match")
    }

    func testItemWithEmptyName() {
        let item = Item(id: UUID(), name: "", isChecked: false, category: "Misc", purchaseDate: nil)
        XCTAssertEqual(item.name, "", "Item name should be empty")
    }

    func testItemToggleCheckedState() {
        var item = Item(id: UUID(), name: "Bread", isChecked: false, category: "Bakery", purchaseDate: nil)
        item.isChecked.toggle()
        XCTAssertTrue(item.isChecked, "Item should be marked as checked")
    }

    func testItemCategoryAssignment() {
        let item = Item(id: UUID(), name: "Banana", isChecked: false, category: "Fruits", purchaseDate: nil)
        XCTAssertEqual(item.category, "Fruits", "Category should be correctly assigned")
    }
}
