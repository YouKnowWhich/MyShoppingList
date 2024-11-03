//
//  PurchasedItemsViewController.swift
//  MyShoppingList
//
//  Created by Yuchinante on 2024/09/25
//
//

import UIKit

// PurchasedItemsViewControllerDelegate プロトコル
protocol PurchasedItemsViewControllerDelegate: AnyObject {
    func addItemBackToShoppingList(item: TableViewController.Item)
}

class PurchasedItemsViewController: UITableViewController, ItemTableViewCellDelegate {

    private var purchasedItems: [TableViewController.Item] = []
    weak var delegate: PurchasedItemsViewControllerDelegate?

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    private let purchasedItemsKey = "purchasedItems"

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPurchasedItems()

        // 購入済みアイテムの更新を監視
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPurchasedItems), name: NSNotification.Name("PurchasedItemsUpdated"), object: nil)

        // 初期状態は日付でソート
        segmentedControl.selectedSegmentIndex = 0
        sortItems(segmentedControl)
    }

    // MARK: - デリゲートメソッド

    // チェックボックスが切り替えられたときに呼ばれる
    func didToggleCheck(for cell: ItemTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        var selectedItem = purchasedItems[indexPath.row]
        selectedItem.isChecked.toggle()

        // チェックを外した場合
        if !selectedItem.isChecked {
            purchasedItems.remove(at: indexPath.row)      // アイテムを購入済みリストから削除
            savePurchasedItems()                          // 保存

            // テーブルから行を削除
            tableView.deleteRows(at: [indexPath], with: .automatic)

            // デリゲートを介して未購入リストに追加
            if let delegate = delegate {
                delegate.addItemBackToShoppingList(item: selectedItem)
            } else {
                print("Error: PurchasedItemsViewControllerDelegate is not set. Ensure that the delegate is assigned in TableViewController.")
            }
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

    // 購入済みアイテムリストをリロード
    @objc func reloadPurchasedItems() {
        loadPurchasedItems()
    }

    // 購入済みアイテムを保存
    private func savePurchasedItems() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let defaults = UserDefaults.standard
            do {
                let data = try JSONEncoder().encode(self.purchasedItems)
                defaults.set(data, forKey: self.purchasedItemsKey)
            } catch {
                print("Failed to save purchased items: \(error.localizedDescription)")
            }
        }
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
        cell.configure(item: item)
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

    // クラス解放時にObserverを解除
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
