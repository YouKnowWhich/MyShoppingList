//
//  PurchasedItemsViewController.swift
//  MyShoppingList
//
//  Created by Yuchinante on 2024/09/25
//
//

import UIKit
#if canImport(WidgetKit)
import WidgetKit
#endif

// MARK: - PurchasedItemsViewControllerDelegate
// 購入済みアイテムを未購入リストに戻すためのデリゲートプロトコル
protocol PurchasedItemsViewControllerDelegate: AnyObject {
    func addItemBackToShoppingList(item: Item)
}

// MARK: - PurchasedItemsViewController
class PurchasedItemsViewController: UITableViewController, ItemToggleDelegate {

    // MARK: - 定数
    private let purchasedItemsKey = "purchasedItems" // UserDefaultsキー
    private let suiteName = "group.com.example.MyShoppingList" // App Groupsのグループ名

    // MARK: - プロパティ
    private var purchasedItems: [Item] = []
    weak var delegate: PurchasedItemsViewControllerDelegate?
    private var selectedItems = Set<IndexPath>()
    private var isDeleteMode = false {
        didSet {
            toggleDeleteMode()
            toggleTabBarInteraction()
        }
    }

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // MARK: - ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadPurchasedItems()
        configureTableView()
        registerForNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 初期設定
    /// 初期設定を行う
    private func setupView() {
        segmentedControl.selectedSegmentIndex = 0  // 初期状態は日付でソート
        sortItems(segmentedControl)
    }

    /// テーブルビューの設定
    private func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }

    /// 通知の登録
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadPurchasedItems),
            name: .purchasedItemsUpdated,
            object: nil
        )
    }

    // MARK: - デリゲートメソッド
    // チェックボックスのトグルによって、購入済みアイテムを未購入リストに戻す
    func didToggleCheck(for cell: ItemTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        var item = purchasedItems[indexPath.row]
        item.isChecked.toggle()

        if !item.isChecked {
            purchasedItems.remove(at: indexPath.row)
            savePurchasedItems()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            delegate?.addItemBackToShoppingList(item: item)

            // WidgetKit を利用可能な場合に更新
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    // EditButtonは不要なため空実装
    func didTapEditButton(for cell: ItemTableViewCell) {
        // 何もしない
    }

    // MARK: - データ操作
    /// 購入済みアイテムをUserDefaultsから読み込む
    private func loadPurchasedItems() {
        guard let userDefaults = UserDefaults(suiteName: suiteName),
              let data = userDefaults.data(forKey: purchasedItemsKey),
              let savedItems = try? JSONDecoder().decode([Item].self, from: data) else {
            return
        }
        purchasedItems = savedItems
    }

    /// 購入済みアイテムをUserDefaultsに保存
    private func savePurchasedItems() {
        guard let data = try? JSONEncoder().encode(purchasedItems),
              let userDefaults = UserDefaults(suiteName: suiteName) else {
            print("Failed to save purchased items.")
            return
        }
        userDefaults.set(data, forKey: purchasedItemsKey)
    }

    /// データを更新してリロード
    private func refreshData() {
        loadPurchasedItems()
        tableView.reloadData()
    }

    @objc private func reloadPurchasedItems() {
        refreshData()
    }

    // MARK: - ソート処理
    /// セグメントに応じたソート処理を実行
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as? ItemTableViewCell else {
            fatalError("Failed to dequeue reusable cell.")
        }
        var item = purchasedItems[indexPath.row]
        item.category = String(item.category.prefix(1))
        cell.configure(with: item, isShoppingList: false, isDeleteMode: isDeleteMode) // isShoppingList を false に設定
        cell.toggleDelegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        purchasedItems.remove(at: indexPath.row)
        savePurchasedItems()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    // MARK: - 削除モード操作
    /// 削除ボタンタップ時の処理
    @IBAction func didTapPurchasedDeleteButton(_ sender: UIBarButtonItem) {
        isDeleteMode.toggle()
    }

    /// 削除モードの切り替え
    private func toggleDeleteMode() {
        if isDeleteMode {
            // 削除モード開始
            selectedItems.removeAll()
            tableView.allowsMultipleSelectionDuringEditing = true
            tableView.setEditing(true, animated: true)
            tableView.reloadData() // セルの非活性化を反映
            //「キャンセル」ボタンを設定
            let cancelButton = UIButton(type: .system)
            cancelButton.setTitle("キャンセル", for: .normal)
            cancelButton.setTitleColor(.red, for: .normal)
            cancelButton.addTarget(self, action: #selector(didTapPurchasedDeleteButton), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)

            toolbarItems = [
                UIBarButtonItem(title: "全選択", style: .plain, target: self, action: #selector(didTapSelectAllButton)),
                UIBarButtonItem.flexibleSpace(),
                UIBarButtonItem(title: "削除", style: .plain, target: self, action: #selector(didTapDeleteSelectedItemsButton))
            ]
            navigationController?.setToolbarHidden(false, animated: true)
        } else {
            // 通常モードに戻る
            tableView.setEditing(false, animated: true)
            tableView.reloadData() // セルの活性化を反映
            // ボタンをトラッシュアイコンに戻す
            let trashButton = UIBarButtonItem(
                barButtonSystemItem: .trash,
                target: self,
                action: #selector(didTapPurchasedDeleteButton)
            )
            trashButton.tintColor = .red // トラッシュアイコンの色を赤に設定
            navigationItem.rightBarButtonItem = trashButton

            navigationController?.setToolbarHidden(true, animated: true)
        }
    }

    /// タブバーの有効/無効を切り替え
    private func toggleTabBarInteraction() {
        tabBarController?.tabBar.items?.forEach { $0.isEnabled = !isDeleteMode }
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
            purchasedItems.remove(at: index)
        }
        selectedItems.removeAll()
        savePurchasedItems()
        tableView.reloadData()
        isDeleteMode = false
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
}
