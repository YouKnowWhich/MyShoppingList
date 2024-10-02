//
//  TableViewController.swift
//
//
//  Created by Yuchinante on 2024/08/05
//
//

import UIKit

class TableViewController: UITableViewController {
    private let keyItems = "items"  // UserDefaultsのキー (未購入アイテム用)
    private let keyPurchasedItems = "purchasedItems"  // UserDefaultsのキー (購入済みアイテム用)

    // アイテムのデータモデル
    struct Item: Codable {
        var name: String
        var isChecked: Bool
        var category: String
        var purchaseDate: Date?

        // チェック状態を反転させる
        mutating func toggleIsChecked() {
            isChecked.toggle()
        }
    }

    private var editIndexPath: IndexPath?  // 編集対象のセルのインデックスパス

    // 未購入アイテムリスト
    private var items: [Item] = [] {
        didSet {
            saveItems()  // 未購入アイテムを保存
        }
    }

    // 購入済みアイテムリスト
    private var purchasedItems: [Item] = [] {
        didSet {
            savePurchasedItems()  // 購入済みアイテムを保存
        }
    }

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()  // 未購入アイテムを読み込み
        loadPurchasedItems()  // 購入済みアイテムを読み込み
    }

    // 未購入アイテムをUserDefaultsに保存
    private func saveItems() {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: keyItems)
        }
    }

    // 購入済みアイテムをUserDefaultsに保存
    private func savePurchasedItems() {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(purchasedItems) {
            defaults.set(data, forKey: keyPurchasedItems)
        }
    }

    // UserDefaultsから未購入アイテムを読み込む
    private func loadItems() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: keyItems),
           let savedItems = try? JSONDecoder().decode([Item].self, from: data) {
            items = savedItems
        }
    }

    // UserDefaultsから購入済みアイテムを読み込む
    private func loadPurchasedItems() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: keyPurchasedItems),
           let savedItems = try? JSONDecoder().decode([Item].self, from: data) {
            purchasedItems = savedItems
        }
    }

    // セグメントコントロールによるソート
    @IBAction func sortItems(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // 日付でソート
            items.sort {
                if let date1 = $0.purchaseDate, let date2 = $1.purchaseDate {
                    return date1 < date2
                } else {
                    return $0.purchaseDate != nil
                }
            }
        case 1:
            // カテゴリでソート
            items.sort { $0.category < $1.category }
        case 2:
            // 名前でソート
            items.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        default:
            break
        }
        tableView.reloadData()
    }


    // テーブルの行数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    // テーブルセルの内容を設定
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! ItemTableViewCell
        var item = items[indexPath.row]

        // カテゴリ名の先頭1文字だけを表示
        item.category = String(item.category.prefix(1))

        cell.configure(item: item)
        return cell
    }

    // アイテムをチェック済みにして購入リストへ移動
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedItem = items[indexPath.row]
        selectedItem.isChecked = true
        purchasedItems.append(selectedItem)
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)

        // 購入済みアイテムを保存
        savePurchasedItems()

        // 購入済みリスト画面に更新を通知
        NotificationCenter.default.post(name: NSNotification.Name("PurchasedItemsUpdated"), object: nil)

        // 購入済みリスト画面を再読み込み
        if let purchasedVC = navigationController?.viewControllers.first(where: { $0 is PurchasedItemsViewController }) as? PurchasedItemsViewController {
            purchasedVC.reloadPurchasedItems()
        }
    }

    // セルのアクセサリボタンがタップされたときの処理
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editIndexPath = indexPath
        performSegue(withIdentifier: "EditSegue", sender: indexPath)
    }

    // セルの削除処理
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // セグエによる画面遷移の準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let add = (segue.destination as? UINavigationController)?.topViewController as? AddItemViewController {
            switch segue.identifier ?? "" {
            case "AddSegue":
                add.mode = .add
            case "EditSegue":
                if let indexPath = sender as? IndexPath {
                    let item = items[indexPath.row]
                    add.mode = .edit(items[indexPath.row])
                }
            default:
                break
            }
        }
    }

    // 追加画面でキャンセル時の処理
    @IBAction func exitFromAddByCancel(segue: UIStoryboardSegue) {
    }

    // 追加画面で保存時の処理
    @IBAction func exitFromAddBySave(segue: UIStoryboardSegue) {
        if let add = segue.source as? AddItemViewController,
            let item = add.editedItem {
            items.append(item)
            let indexPath = IndexPath(row: items.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    // 編集画面でキャンセル時の処理
    @IBAction func exitFromEditByCancel(segue: UIStoryboardSegue) {
    }

    // 編集画面で保存したときの処理
    @IBAction func exitFromEditBySave(segue: UIStoryboardSegue) {
        if let add = segue.source as? AddItemViewController,
            let editedItem = add.editedItem,
            let indexPath = editIndexPath {
            items[indexPath.row] = editedItem
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
