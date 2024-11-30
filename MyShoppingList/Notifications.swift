//
//  Notifications.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/11/30
//  
//

import Foundation

/// アプリ内通知キーを管理する拡張
extension Notification.Name {
    /// 購入済みアイテムの更新通知
    static let purchasedItemsUpdated = Notification.Name("PurchasedItemsUpdated")
}
