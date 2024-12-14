//
//  UserDefaultsManager.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/12/14
//  
//
import Foundation

class UserDefaultsManager {
    private let key: String
    private let defaults: UserDefaults

    init(key: String = "defaultKey", defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    func saveData(_ value: String) {
        defaults.set(value, forKey: key)
    }

    func fetchData() -> String? {
        return defaults.string(forKey: key)
    }

    func clearData() {
        defaults.removeObject(forKey: key)
    }
}
