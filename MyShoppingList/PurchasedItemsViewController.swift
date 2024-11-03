//
//  PurchasedItemsViewController.swift
//  MyShoppingList
//
//  Created by Yuchinante on 2024/09/25
//
//

import UIKit

// 購入済みアイテムを未購入リストに戻すためのデリゲートプロトコル
protocol PurchasedItemsViewControllerDelegate: AnyObject {
    func addItemBackToShoppingList(item: TableViewController.Item)
}

class PurchasedItemsViewController: UITableViewController, ItemTableViewCellDelegate {

    // MARK: - プロパティ

    private var purchasedItems: [TableViewController.Item] = []
    weak var delegate: PurchasedItemsViewControllerDelegate?

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private let purchasedItemsKey = "purchasedItems"  // UserDefaultsキー

    // MARK: - ライフサイクルメソッド

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPurchasedItems()

        // 購入済みアイテムの更新を監視し、更新時にリロードする
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPurchasedItems), name: NSNotification.Name("PurchasedItemsUpdated"), object: nil)

        // 初期状態は日付でソート
        segmentedControl.selectedSegmentIndex = 0
        sortItems(segmentedControl)
    }

    // クラス解放時にObserverを解除
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - デリゲートメソッド

    // チェックボックスのトグルによって、購入済みアイテムを未購入リストに戻す
    func didToggleCheck(for cell: ItemTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        var selectedItem = purchasedItems[indexPath.row]
        selectedItem.isChecked.toggle()

        if !selectedItem.isChecked {
            // アイテムを購入済みリストから削除し、保存
            purchasedItems.remove(at: indexPath.row)
            savePurchasedItems()
            tableView.deleteRows(at: [indexPath], with: .automatic)

            // 未購入リストにアイテムを戻す
            delegate?.addItemBackToShoppingList(item: selectedItem)
        }
    }

    // MARK: - UserDefaults操作

    private func loadPurchasedItems() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let defaults = UserDefaults.standard
            if let data = defaults.data(forKey: self.purchasedItemsKey),
               let savedItems = try? JSONDecoder().decode([TableViewController.Item].self, from: data) {
                DispatchQueue.main.async {
                    self.purchasedItems = savedItems
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func savePurchasedItems() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let defaults = UserDefaults.standard
            if let data = try? JSONEncoder().encode(self.purchasedItems) {
                defaults.set(data, forKey: self.purchasedItemsKey)
            } else {
                print("Failed to save purchased items.")
            }
        }
    }

    // 購入済みアイテムリストをリロード
    @objc func reloadPurchasedItems() {
        loadPurchasedItems()
    }

    // MARK: - ソート処理

    @IBAction func sortItems(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:  // 日付でソート
            purchasedItems.sort { ($0.purchaseDate ?? Date.distantPast) < ($1.purchaseDate ?? Date.distantPast) }
        case 1:  // カテゴリでソート
            purchasedItems.sort { $0.category < $1.category }
        case 2:  // 名前でソート
            purchasedItems.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        default:
            break
        }
        tableView.reloadData()
    }

    // MARK: - テーブルビュー データソース

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchasedItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! ItemTableViewCell
        var item = purchasedItems[indexPath.row]

        item.category = String(item.category.prefix(1))
        cell.configure(with: item)
        cell.delegate = self

        return cell
    }

    // スワイプでアイテムを削除する処理
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            purchasedItems.remove(at: indexPath.row)
            savePurchasedItems()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
