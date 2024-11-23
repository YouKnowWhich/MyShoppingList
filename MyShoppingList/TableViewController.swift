//
//  TableViewController.swift
//
//
//  Created by Yuchinante on 2024/08/05
//
//

import UIKit

class TableViewController: UITableViewController, ItemTableViewCellDelegate, PurchasedItemsViewControllerDelegate {

    // MARK: - プロパティ定義

    // UserDefaultsのキー
    private let keyItems = "items"  // 未購入アイテム
    private let keyPurchasedItems = "purchasedItems"  // 購入済みアイテム

    // アイテムのデータモデル
    struct Item: Codable {
        var id: UUID
        var name: String
        var isChecked: Bool
        var category: String
        var purchaseDate: Date?

        mutating func toggleIsChecked() {
            isChecked.toggle()
        }
    }

    // 未購入アイテムリスト（変更があれば保存）
    private var items: [Item] = [] {
        didSet { saveItems() }
    }

    // 購入済みアイテムリスト（変更があれば保存し、更新通知を送信）
    private var purchasedItems: [Item] = [] {
        didSet {
            savePurchasedItems()
            NotificationCenter.default.post(name: NSNotification.Name("PurchasedItemsUpdated"), object: nil)
        }
    }

    // 編集対象のセルのインデックスパス
    private var editIndexPath: IndexPath?

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // MARK: - ライフサイクルメソッド

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPurchasedItemsDelegate()
        loadItems()
        loadPurchasedItems()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44 // 適切な推定値を設定
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItems()            // 最新の未購入アイテムを再読み込み
        loadPurchasedItems()    // 最新の購入済みアイテムを再読み込み
        tableView.reloadData()  // テーブルビューをリロード
    }

    // タブバーの購入済みアイテムビューのデリゲート設定
    private func setupPurchasedItemsDelegate() {
        guard let viewControllers = tabBarController?.viewControllers else { return }
        for viewController in viewControllers {
            if let navController = viewController as? UINavigationController,
               let purchasedItemsVC = navController.topViewController as? PurchasedItemsViewController {
                purchasedItemsVC.delegate = self
            }
        }
    }

    // MARK: - UserDefaults 保存/読み込み処理

    private func saveItems() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: keyItems)
    }

    private func savePurchasedItems() {
        guard let data = try? JSONEncoder().encode(purchasedItems) else { return }
        UserDefaults.standard.set(data, forKey: keyPurchasedItems)
    }

    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: keyItems),
           let savedItems = try? JSONDecoder().decode([Item].self, from: data) {
            items = savedItems
        }
    }

    private func loadPurchasedItems() {
        if let data = UserDefaults.standard.data(forKey: keyPurchasedItems),
           let savedItems = try? JSONDecoder().decode([Item].self, from: data) {
            purchasedItems = savedItems
        }
    }

    private func saveData() {
        saveItems()
        savePurchasedItems()
    }

    // MARK: - アイテム操作

    // アイテムを未購入リストに戻す
    func addItemBackToShoppingList(item: Item) {
        var newItem = item
        newItem.isChecked = false
        if !items.contains(where: { $0.id == newItem.id }) {
            items.append(newItem)
            saveItems()
            tableView.reloadData()  // テーブルビューをリロードしてアイテムを反映
        }
    }

    private func moveToPurchasedItems(item: Item, at indexPath: IndexPath) {
        if !purchasedItems.contains(where: { $0.id == item.id }) {
            purchasedItems.append(item)
        }
        items.remove(at: indexPath.row)
        saveData()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    private func moveToShoppingList(item: Item) {
        if !items.contains(where: { $0.id == item.id }) {
            items.append(item)
        }
        if let index = purchasedItems.firstIndex(where: { $0.id == item.id }) {
            purchasedItems.remove(at: index)
        }
        saveData()
        tableView.reloadData()
    }

    // MARK: - デリゲートメソッド

    // チェックボックスが切り替えられたときの処理
    func didToggleCheck(for cell: ItemTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        var selectedItem = items[indexPath.row]
        selectedItem.toggleIsChecked()
        items[indexPath.row] = selectedItem

        if selectedItem.isChecked {
            moveToPurchasedItems(item: selectedItem, at: indexPath)
        } else {
            moveToShoppingList(item: selectedItem)
        }

        // UserDefaultsに変更を保存
        saveData()
    }

    // MARK: - テーブルビュー操作

    // セグメントコントロールによるソート処理
    @IBAction func sortItems(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: items.sort { ($0.purchaseDate ?? Date.distantPast) < ($1.purchaseDate ?? Date.distantPast) }
        case 1: items.sort { $0.category < $1.category }
        case 2: items.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        default: break
        }
        tableView.reloadData()
    }

    // MARK: - テーブルビューのデータソース

    // 行数を返す
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    // セルの内容を設定
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! ItemTableViewCell
        var item = items[indexPath.row]

        item.category = String(item.category.prefix(1))
        cell.configure(with: item)
        cell.delegate = self
        return cell
    }

    // MARK: - テーブルビューのアクション
    // アクセサリボタンタップ時の処理（編集画面への遷移）
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editIndexPath = indexPath
        performSegue(withIdentifier: "EditSegue", sender: indexPath)
    }

    // セルの削除処理
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // items配列からアイテムを削除
            items.remove(at: indexPath.row)

            // UserDefaultsのデータを上書き保存
            saveItems()  // 削除後にUserDefaultsに即時反映

            // テーブルビューから行を削除
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: - セグエと画面遷移

    // セグエの準備処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addVC = (segue.destination as? UINavigationController)?.topViewController as? AddItemViewController {
            switch segue.identifier ?? "" {
            case "AddSegue":
                addVC.mode = .add
            case "EditSegue":
                if let indexPath = sender as? IndexPath {
                    addVC.mode = .edit(items[indexPath.row])
                }
            default:
                break
            }
        }
    }

    @IBAction func exitFromAddByCancel(segue: UIStoryboardSegue) {
    }

    @IBAction func exitFromAddBySave(segue: UIStoryboardSegue) {
        if let addVC = segue.source as? AddItemViewController, let item = addVC.editedItem {
            items.append(item)
            tableView.insertRows(at: [IndexPath(row: items.count - 1, section: 0)], with: .automatic)
        }
    }

    @IBAction func exitFromEditByCancel(segue: UIStoryboardSegue) {
    }

    @IBAction func exitFromEditBySave(segue: UIStoryboardSegue) {
        if let addVC = segue.source as? AddItemViewController, let editedItem = addVC.editedItem, let indexPath = editIndexPath {
            items[indexPath.row] = editedItem
            tableView.reloadRows(at: [indexPath], with: .automatic)
            editIndexPath = nil
        }
    }

    // MARK: - 全削除ボタンのアクション
    @IBAction func deleteAllItems(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "確認",
            message: "すべてのアイテムを削除しますか？",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: "削除", style: .destructive) { [weak self] _ in
            guard let self = self else { return }

            // アイテムリストを空にする
            self.items.removeAll()
            UserDefaults.standard.removeObject(forKey: self.keyItems) // UserDefaultsから削除

            // テーブルビューをリロード
            self.tableView.reloadData()
        })

        present(alert, animated: true)
    }
}

