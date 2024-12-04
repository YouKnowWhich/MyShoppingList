//
//  ShoppingListWidget.swift
//  ShoppingListWidgetExtension
//  
//  Created by Yuchinante on 2024/12/01
//  
//

import WidgetKit
import SwiftUI

struct ShoppingListWidgetEntry: TimelineEntry {
    let date: Date
    let items: [Item]  // 買い物リストデータ
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ShoppingListWidgetEntry {
        ShoppingListWidgetEntry(date: Date(), items: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (ShoppingListWidgetEntry) -> Void) {
        let entry = ShoppingListWidgetEntry(date: Date(), items: loadShoppingItems())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShoppingListWidgetEntry>) -> Void) {
        let entries = [ShoppingListWidgetEntry(date: Date(), items: loadShoppingItems())]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }

    /// UserDefaults からアイテムを読み込み、当日と当日以前にフィルタリング
    private func loadShoppingItems() -> [Item] {
        let userDefaults = UserDefaults(suiteName: "group.com.example.MyShoppingList")
        guard let data = userDefaults?.data(forKey: "items"),
              let allItems = try? JSONDecoder().decode([Item].self, from: data) else {
            return []
        }

        let today = Calendar.current.startOfDay(for: Date())
        return allItems.filter { $0.purchaseDate ?? today <= today }
    }

    private func loadPurchasedItems() -> [Item] {
        guard let userDefaults = UserDefaults(suiteName: "group.com.example.MyShoppingList"),
              let data = userDefaults.data(forKey: "purchasedItems"),
              let savedItems = try? JSONDecoder().decode([Item].self, from: data) else {
            return []
        }
        return savedItems
    }
}

struct ShoppingListWidgetEntryView: View {
    var entry: ShoppingListWidgetEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Shopping List")
                .font(.headline)
                .padding(.bottom, 8)

            if entry.items.isEmpty {
                Text("No items for today").font(.subheadline)
            } else {
                ForEach(entry.items.prefix(5), id: \.id) { item in
                    HStack {
                        Text(item.name)
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
