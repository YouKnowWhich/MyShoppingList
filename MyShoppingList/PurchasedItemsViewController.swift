//
//  PurchasedItemsViewController.swift
//  MyShoppingList
//
//  Created by Yuchinante on 2024/09/25
//
//

import UIKit

// MARK: - PurchasedItemsViewControllerDelegate

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
        setupView()
        loadPurchasedItems()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44 // 適切な推定値を設定

        // 購入済みアイテムの更新を監視し、更新時にリロードする
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPurchasedItems), name: NSNotification.Name("PurchasedItemsUpdated"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPurchasedItems()    // 最新の購入済みアイテムを再読み込み
        tableView.reloadData()  // テーブルビューをリロード
    }

    // クラス解放時にObserverを解除
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 初期設定

    private func setupView() {
        // 初期状態は日付でソート
        segmentedControl.selectedSegmentIndex = 0
        sortItems(segmentedControl)
    }

    // MARK: - デリゲートメソッド

    // チェックボックスのトグルによって、購入済みアイテムを未購入リストに戻す
    func didToggleCheck(for cell: ItemTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        var selectedItem = purchasedItems[indexPath.row]
        selectedItem.isChecked.toggle()

        if !selectedItem.isChecked {
            // アイテムを購入済みリストから削除
            purchasedItems.remove(at: indexPath.row)

            // データ保存を行い、UI更新
            savePurchasedItems()
            tableView.deleteRows(at: [indexPath], with: .automatic)

            // UI全体をリロードして確実に反映
            tableView.reloadData()

            // 未購入リストにアイテムを戻す
            delegate?.addItemBackToShoppingList(item: selectedItem)
        }
    }

    // MARK: - データ操作 (UserDefaults)

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
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(self.purchasedItems) {
            defaults.set(data, forKey: self.purchasedItemsKey)
        } else {
            print("Failed to save purchased items.")
        }
    }

    // 購入済みアイテムリストをリロード
    @objc private func reloadPurchasedItems() {
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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // purchasedItems配列からアイテムを削除
            purchasedItems.remove(at: indexPath.row)

            // UserDefaultsのデータを上書き保存
            savePurchasedItems()  // 削除後にUserDefaultsに即時反映

            // テーブルビューから行を削除
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: - 全削除ボタンのアクション
    @IBAction func deleteAllPurchasedItems(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "確認",
            message: "すべての購入済みアイテムを削除しますか？",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: "削除", style: .destructive) { [weak self] _ in
            guard let self = self else { return }

            // 購入済みリストを空にする
            self.purchasedItems.removeAll()
            UserDefaults.standard.removeObject(forKey: self.purchasedItemsKey) // UserDefaultsから削除

            // テーブルビューをリロード
            self.tableView.reloadData()
        })

        present(alert, animated: true)
    }
}
