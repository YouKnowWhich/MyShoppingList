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
    @Environment(\.widgetFamily) var family // ウィジェットサイズを取得

    var entry: ShoppingListWidgetEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                systemSmallView(entry: entry)
            case .systemMedium:
                systemMediumView(entry: entry)
            case .systemLarge:
                systemLargeView(entry: entry)
            default:
                unsupportedView()
            }
        }
        .containerBackground(Color.clear, for: .widget)
    }

    // MARK: - 小サイズウィジェット
    private func systemSmallView(entry: ShoppingListWidgetEntry) -> some View {
        VStack {
            Text("🛒 未購入アイテム")
                .font(.headline)
            Text("\(entry.items.count) items")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    // MARK: - 中サイズウィジェット
    private func systemMediumView(entry: ShoppingListWidgetEntry) -> some View {
        VStack(alignment: .leading) {
            Text("🛒 今日のリスト")
                .font(.headline)
                .padding(.bottom, 8)
            if entry.items.isEmpty {
                Text("アイテムなし").font(.subheadline)
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
    }

    // MARK: - 大サイズウィジェット
    private func systemLargeView(entry: ShoppingListWidgetEntry) -> some View {
        VStack(alignment: .leading) {
            Text("🛒 今日の買い物リスト")
                .font(.headline)
                .padding(.bottom, 8)
            if entry.items.isEmpty {
                Text("アイテムなし").font(.subheadline)
            } else {
                ForEach(entry.items.prefix(10), id: \.id) { item in
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
    }

    // MARK: - 非対応サイズビュー
    private func unsupportedView() -> some View {
        Text("未対応のウィジェットサイズ")
            .font(.caption)
            .padding()
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
