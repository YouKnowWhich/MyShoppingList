//
//  TableViewController.swift
//
//
//  Created by Yuchinante on 2024/08/05
//
//

import UIKit
#if canImport(WidgetKit)
import WidgetKit
#endif

// MARK: - TableViewController: メイン画面のコントローラ
class TableViewController: UITableViewController, ItemTableViewCellDelegate, PurchasedItemsViewControllerDelegate {

    // MARK: - 定数
    private enum UserDefaultsKeys {
        static let items = "items"                   // 未購入アイテムのキー
        static let purchasedItems = "purchasedItems" // 購入済みアイテムのキー
    }

    private let suiteName = "group.com.example.MyShoppingList" // App Groups のグループ名

    // MARK: - プロパティ
    private var items: [Item] = [] { didSet { saveItems() } }
    private var purchasedItems: [Item] = [] {
        didSet {
            savePurchasedItems()
            NotificationCenter.default.post(name: .purchasedItemsUpdated, object: nil)
        }
    }
    private var editIndexPath: IndexPath?
    private var isDeleteMode = false { didSet { toggleDeleteMode() } }
    private var selectedItems = Set<IndexPath>()

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // MARK: - ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPurchasedItemsDelegate()
        loadData()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
        configureRightBarButtons() // プラスボタンを初期化
    }

    // MARK: - 初期設定
    private func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }

    private func setupPurchasedItemsDelegate() {
        tabBarController?.viewControllers?
            .compactMap { ($0 as? UINavigationController)?.topViewController as? PurchasedItemsViewController }
            .forEach { $0.delegate = self }
    }

    // プラスボタンとトラッシュボタンを初期化するメソッド
    private func configureRightBarButtons() {
        let trashButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(didTapDeleteButton)
        )
        trashButton.tintColor = .red

        let addButton = UIButton(type: .custom)
        addButton.setImage(UIImage(systemName: "plus.rectangle.fill"), for: .normal) // SF Symbolsを利用
        addButton.tintColor = .systemBlue
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)

        let addBarButtonItem = UIBarButtonItem(customView: addButton)

        // 初期状態ではトラッシュボタンとプラスボタンを表示
        navigationItem.rightBarButtonItems = [trashButton, addBarButtonItem]
    }

    // MARK: - データの保存と読み込み
    private func loadData() {
        items = loadFromUserDefaults(UserDefaultsKeys.items) ?? []
        purchasedItems = loadFromUserDefaults(UserDefaultsKeys.purchasedItems) ?? []
    }

    private func refreshData() {
        loadData()
        tableView.reloadData()
    }


    private func saveItems() {
        saveToUserDefaults(UserDefaultsKeys.items, data: items)

        // WidgetKitが利用可能な場合のみタイムラインをリロード
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func savePurchasedItems() {
        saveToUserDefaults(UserDefaultsKeys.purchasedItems, data: purchasedItems)

        // WidgetKitが利用可能な場合のみタイムラインをリロード
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func saveToUserDefaults<T: Encodable>(_ key: String, data: T) {
        guard let encodedData = try? JSONEncoder().encode(data),
              let userDefaults = UserDefaults(suiteName: suiteName) else { return }
        userDefaults.set(encodedData, forKey: key)
    }

    private func loadFromUserDefaults<T: Decodable>(_ key: String) -> T? {
        guard let userDefaults = UserDefaults(suiteName: suiteName),
              let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    // MARK: - アイテム操作
    func addItemBackToShoppingList(item: Item) {
        guard !items.contains(where: { $0.id == item.id }) else { return }
        var newItem = item
        newItem.isChecked = false
        items.append(newItem)
        tableView.reloadData()
    }

    private func moveToPurchasedItems(item: Item, at indexPath: IndexPath) {
        guard !purchasedItems.contains(where: { $0.id == item.id }) else { return }
        purchasedItems.append(item)
        items.remove(at: indexPath.row)
        updateDataAfterChange()
        tableView.deleteRows(at: [indexPath], with: .automatic)

        // ウィジェットを更新
        WidgetCenter.shared.reloadAllTimelines()
    }


    private func moveToShoppingList(item: Item) {
        guard !items.contains(where: { $0.id == item.id }) else { return }
        items.append(item)
        purchasedItems.removeAll { $0.id == item.id }
        updateDataAfterChange()

        // ウィジェットを更新
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func updateDataAfterChange() {
        saveItems()
        savePurchasedItems()

        // WidgetKit が利用可能な場合のみウィジェットを更新
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }


    // MARK: - ソート処理
    @IBAction func sortItems(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: items.sort { ($0.purchaseDate ?? Date.distantPast) < ($1.purchaseDate ?? Date.distantPast) }
        case 1: items.sort { $0.category < $1.category }
        case 2: items.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        default: break
        }
        tableView.reloadData()
    }

    // MARK: - テーブルビュー データソース
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as? ItemTableViewCell else {
            fatalError("セルが見つかりません")
        }
        var item = items[indexPath.row]
        item.category = String(item.category.prefix(1))
        cell.configure(with: item)
        cell.delegate = self
        return cell
    }

    // MARK: - テーブルビュー アクション
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editIndexPath = indexPath
        performSegue(withIdentifier: "EditSegue", sender: indexPath)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    // MARK: - セグエと画面遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addVC = (segue.destination as? UINavigationController)?.topViewController as? AddItemViewController else { return }

        if segue.identifier == "EditSegue", let indexPath = sender as? IndexPath {
            addVC.mode = .edit(items[indexPath.row])
        } else if segue.identifier == "AddSegue" {
            addVC.mode = .add
        }

        // デリゲートを設定
        addVC.delegate = self
    }

    @IBAction func exitFromAddByCancel(segue: UIStoryboardSegue) {
    }

    @IBAction func exitFromAddBySave(segue: UIStoryboardSegue) {
        guard let addVC = segue.source as? AddItemViewController, let item = addVC.editedItem else { return }
        items.append(item)
        tableView.insertRows(at: [IndexPath(row: items.count - 1, section: 0)], with: .automatic)

        // ウィジェットを更新
        WidgetCenter.shared.reloadAllTimelines()
    }

    @IBAction func exitFromEditByCancel(segue: UIStoryboardSegue) {
    }

    @IBAction func exitFromEditBySave(segue: UIStoryboardSegue) {
        guard let addVC = segue.source as? AddItemViewController,
              let editedItem = addVC.editedItem,
              let indexPath = editIndexPath else { return }
        items[indexPath.row] = editedItem
        tableView.reloadRows(at: [indexPath], with: .automatic)
        editIndexPath = nil
    }

    // MARK: - 削除モード操作
    @IBAction func didTapDeleteButton(_ sender: UIBarButtonItem) {
        isDeleteMode.toggle()
    }

    private func toggleDeleteMode() {
        if isDeleteMode {
            // 削除モード開始
            selectedItems.removeAll()
            tableView.allowsMultipleSelectionDuringEditing = true
            tableView.setEditing(true, animated: true)

            // 「キャンセル」ボタンを設定
            let cancelButton = UIBarButtonItem(
                title: "キャンセル",
                style: .plain,
                target: self,
                action: #selector(didTapDeleteButton)
            )
            cancelButton.tintColor = .red // ボタン色を赤に設定

            // 削除モード中は追加ボタンを非表示にする
            navigationItem.rightBarButtonItems = [cancelButton]

            // ツールバーの設定
            toolbarItems = [
                UIBarButtonItem(title: "全選択", style: .plain, target: self, action: #selector(didTapSelectAllButton)),
                UIBarButtonItem.flexibleSpace(),
                UIBarButtonItem(title: "削除", style: .plain, target: self, action: #selector(didTapDeleteSelectedItemsButton))
            ]
            navigationController?.setToolbarHidden(false, animated: true)
        } else {
            // 通常モードに戻る
            tableView.setEditing(false, animated: true)

            // 通常モードの右上ボタン (トラッシュボタンと追加ボタン) を復元
            let trashButton = UIBarButtonItem(
                barButtonSystemItem: .trash,
                target: self,
                action: #selector(didTapDeleteButton)
            )
            trashButton.tintColor = .red // ボタン色を赤に設定

            let addButton = UIButton(type: .custom)
            addButton.setImage(UIImage(systemName: "plus.rectangle.fill"), for: .normal) // SF Symbolsを利用
            addButton.tintColor = .systemBlue
            addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)

            let addBarButtonItem = UIBarButtonItem(customView: addButton)

            navigationItem.rightBarButtonItems = [trashButton, addBarButtonItem]

            navigationController?.setToolbarHidden(true, animated: true)
        }
    }

    @objc private func didTapAddButton() {
        performSegue(withIdentifier: "AddSegue", sender: self)
    }

    // MARK: - 全選択ボタンアクション
    @objc private func didTapSelectAllButton() {
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                selectedItems.insert(indexPath)
            }
        }
    }

    // MARK: - 選択したアイテムを削除
    @objc private func didTapDeleteSelectedItemsButton() {
        guard !selectedItems.isEmpty else { return }

        let alert = UIAlertController(
            title: "確認",
            message: "\(selectedItems.count)件のアイテムを削除しますか？",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: "削除", style: .destructive) { [weak self] _ in
            self?.deleteSelectedItems()
        })
        present(alert, animated: true)
    }

    private func deleteSelectedItems() {
        let indices = selectedItems.map { $0.row }.sorted(by: >)
        for index in indices {
            items.remove(at: index)
        }
        selectedItems.removeAll()
        tableView.reloadData()
        isDeleteMode = false

        // ウィジェットを更新
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - テーブルビューのデリゲートメソッド
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isDeleteMode {
            selectedItems.insert(indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isDeleteMode {
            selectedItems.remove(indexPath)
        }
    }

    // MARK: - デリゲートメソッド
    func didToggleCheck(for cell: ItemTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var selectedItem = items[indexPath.row]
        selectedItem.toggleIsChecked()
        items[indexPath.row] = selectedItem
        selectedItem.isChecked ? moveToPurchasedItems(item: selectedItem, at: indexPath) : moveToShoppingList(item: selectedItem)
    }
}

extension TableViewController: AddItemViewControllerDelegate {
    func didSaveItem() {
        updateDataAfterChange()
    }
}
