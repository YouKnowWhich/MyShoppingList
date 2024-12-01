//
//  SharedModels.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/12/01
//  
//

import Foundation

public struct Item: Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var isChecked: Bool
    public var category: String
    public var purchaseDate: Date?

    public init(id: UUID, name: String, isChecked: Bool, category: String, purchaseDate: Date?) {
        self.id = id
        self.name = name
        self.isChecked = isChecked
        self.category = category
        self.purchaseDate = purchaseDate
    }

    public mutating func toggleIsChecked() {
        isChecked.toggle()
    }
}
