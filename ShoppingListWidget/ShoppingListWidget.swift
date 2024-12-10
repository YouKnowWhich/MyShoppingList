//
//  ShoppingListWidget.swift
//  ShoppingListWidgetExtension
//  
//  Created by Yuchinante on 2024/12/01
//  
//

import WidgetKit
import SwiftUI

// MARK: - ショッピングリストのタイムラインエントリ
struct ShoppingListWidgetEntry: TimelineEntry {
    let date: Date  // エントリの日付
    let items: [Item]  // 表示するアイテムのリスト
}

// MARK: - タイムラインプロバイダー
struct Provider: TimelineProvider {
    // プレビュー用のエントリを提供
    func placeholder(in context: Context) -> ShoppingListWidgetEntry {
        ShoppingListWidgetEntry(date: Date(), items: [])
    }

    // ウィジェットがスナップショットを要求した際の処理
    func getSnapshot(in context: Context, completion: @escaping (ShoppingListWidgetEntry) -> Void) {
        let entry = ShoppingListWidgetEntry(date: Date(), items: loadShoppingItems())
        completion(entry)
    }

    // タイムラインを提供
    func getTimeline(in context: Context, completion: @escaping (Timeline<ShoppingListWidgetEntry>) -> Void) {
        let entries = [ShoppingListWidgetEntry(date: Date(), items: loadShoppingItems())]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }

    // MARK: - アイテムデータの読み込み
    /// 未購入アイテムを読み込み、当日以前の日付のアイテムをフィルタリングして返す
    private func loadShoppingItems() -> [Item] {
        let userDefaults = UserDefaults(suiteName: "group.com.example.MyShoppingList")
        guard let data = userDefaults?.data(forKey: "items"),
              let allItems = try? JSONDecoder().decode([Item].self, from: data) else {
            return []
        }

        let today = Calendar.current.startOfDay(for: Date())
        return allItems.filter { $0.purchaseDate ?? today <= today }
    }

    /// 購入済みアイテムを読み込み
    private func loadPurchasedItems() -> [Item] {
        guard let userDefaults = UserDefaults(suiteName: "group.com.example.MyShoppingList"),
              let data = userDefaults.data(forKey: "purchasedItems"),
              let savedItems = try? JSONDecoder().decode([Item].self, from: data) else {
            return []
        }
        return savedItems
    }
}

// MARK: - ウィジェットのビュー
struct ShoppingListWidgetEntryView: View {
    var entry: ShoppingListWidgetEntry

    var body: some View {
        VStack(alignment: .leading) {
            // ウィジェットのタイトル
            Text("🛒 Today")
                .font(.headline)
                .padding(.bottom, 8)

            // アイテムがない場合の表示
            if entry.items.isEmpty {
                Text("No items for today").font(.subheadline)
            } else {
                // 最大5件のアイテムを表示
                ForEach(entry.items.prefix(5), id: \.id) { item in
                    HStack {
                        Text(item.name) // アイテム名
                        Spacer()
                        Text(item.category.prefix(1))  // カテゴリの頭文字
                            .foregroundColor(.secondary)
                    }
                    .font(.body)
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) { Color.clear } // 背景を設定
    }
}

// MARK: - ウィジェットの定義
struct ShoppingListWidget: Widget {
    let kind: String = "ShoppingListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ShoppingListWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Shopping List")
        .description("View your shopping list for today.")
    }
}
