//
//  PurchasedItemsViewController.swift
//  MyShoppingList
//
//  Created by Yuchinante on 2024/09/25
//
//

import UIKit

class PurchasedItemsViewController: UITableViewController {
    private var purchasedItems: [TableViewController.Item] = []  // 購入済みアイテムの配列

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // UserDefaultsからデータを読み込む
        loadPurchasedItems()
        // 初期選択のセグメントを設定（最初のセグメント）
        segmentedControl.selectedSegmentIndex = 0
        // データをソート（初期表示用に日付でソート）
        sortItems(segmentedControl)
    }

    // 購入済みアイテムのロード
    private func loadPurchasedItems() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "purchasedItems"),
           let savedItems = try? JSONDecoder().decode([TableViewController.Item].self, from: data) {
            purchasedItems = savedItems
        }
    }

    @IBAction func sortItems(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {  // セグメントコントロールの選択されたインデックスに基づいて処理を分岐
        case 0:
            // 日付でソート
            purchasedItems.sort {  // items 配列をソート
                if let date1 = $0.purchaseDate, let date2 = $1.purchaseDate {  // 両方のアイテムに購入日が設定されている場合
                    return date1 < date2  // 購入日が早い順にソート
                } else if $0.purchaseDate == nil {  // 最初のアイテムの購入日が設定されていない場合
                    return false  // 購入日がないアイテムは後ろに配置
                } else {
                    return true  // 購入日がないアイテムは前に配置
                }
            }
        case 1:
            // カテゴリでソート
            purchasedItems.sort { $0.category < $1.category }  // category プロパティを基準に昇順でソート
        case 2:
            // 名前でアイウエオ順にソート
            purchasedItems.sort { $0.name.localizedCompare($1.name) == .orderedAscending }  // name プロパティをローカライズされた昇順でソート
        default:
            break  // 他のケースでは何もしない
        }
        tableView.reloadData()  // ソート後にテーブルビューを再読み込みして表示を更新
    }

    // テーブルの行数を返す
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchasedItems.count
    }

    // セルに購入済みアイテムを設定
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! ItemTableViewCell
        let item = purchasedItems[indexPath.row]
        // カテゴリ名の1文字目を取得して表示する
        var modifiedItem = item
        modifiedItem.category = String(item.category.prefix(1))
        // セルにデータを設定
        cell.configure(item: modifiedItem)
        return cell
    }

    // 他の画面から購入済みアイテムリストをリロードするためのメソッド
    func reloadPurchasedItems() {
        loadPurchasedItems()
        tableView.reloadData()
    }
}
