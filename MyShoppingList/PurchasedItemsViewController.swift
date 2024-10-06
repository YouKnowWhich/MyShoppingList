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
        loadPurchasedItems()  // UserDefaultsから購入済みアイテムを読み込む

        // 購入済みアイテムが更新されたときの通知を設定
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPurchasedItems), name: NSNotification.Name("PurchasedItemsUpdated"), object: nil)

        // 初期状態でセグメントを日付でソートするように設定
        segmentedControl.selectedSegmentIndex = 0
        sortItems(segmentedControl)
    }

    // UserDefaultsから購入済みアイテムをロード
    private func loadPurchasedItems() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "purchasedItems"),
           let savedItems = try? JSONDecoder().decode([TableViewController.Item].self, from: data) {
            purchasedItems = savedItems
        }
    }

    // 購入済みアイテムリストをリロード
    @objc func reloadPurchasedItems() {
        loadPurchasedItems()
        tableView.reloadData()
    }

    // セグメントコントロールに応じたソート処理
    @IBAction func sortItems(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // 日付でソート
            purchasedItems.sort {  // items 配列をソート
                if let date1 = $0.purchaseDate, let date2 = $1.purchaseDate {
                    return date1 < date2
                } else {
                    return $0.purchaseDate != nil
                }
            }
        case 1:
            // カテゴリでソート
            purchasedItems.sort { $0.category < $1.category }
        case 2:
            // 名前でソート
            purchasedItems.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        default:
            break
        }
        tableView.reloadData()
    }

    // テーブルの行数を返す
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchasedItems.count
    }

    // 各セルに購入済みアイテムを設定
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! ItemTableViewCell
        var item = purchasedItems[indexPath.row]

        // カテゴリ名の1文字目だけを表示
        item.category = String(item.category.prefix(1))

        cell.configure(item: item)
        return cell
    }

    // スワイプでアイテムを削除する処理を追加
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 購入済みアイテムリストからアイテムを削除
            purchasedItems.remove(at: indexPath.row)

            // UserDefaultsに変更後のデータを保存
            savePurchasedItems()

            // テーブルから行を削除
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // 購入済みアイテムを保存
    private func savePurchasedItems() {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(purchasedItems) {
            defaults.set(data, forKey: "purchasedItems")
        }
    }

    // クラス解放時にObserverを解除
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("PurchasedItemsUpdated"), object: nil)
    }
}
