//
//  TableViewController.swift
//
//
//  Created by Yuchinante on 2024/08/05
//
//

import UIKit

class TableViewController: UITableViewController {
    private let keyItems = "items"  // UserDefaultsに保存するためのキー
    private let keyPurchasedItems = "purchasedItems"  // 購入済アイテム用のキー

    // アイテムを表すデータモデル構造体を定義し、Codableに準拠
    struct Item: Codable {
        var name: String  // アイテムの名前を保持するプロパティ
        var isChecked: Bool  // アイテムがチェック済みかどうかを示すプロパティ
        var category: String  // カテゴリを示すプロパティ
        var purchaseDate: Date?  // 購入日を示すプロパティ

        mutating func toggleIsChecked() {  // チェック状態を反転させるメソッド
            isChecked.toggle()  // isCheckedの値を反転させる
        }
    }

    // 編集するセルのインデックスパスを保持するプロパティ
    private var editIndexPath: IndexPath?

    // 未購入アイテムと購入済みアイテムを管理
    private var items: [Item] = [] {
        didSet {  // itemsが更新されたときに呼ばれるプロパティオブザーバ
            saveItems()  // 未購入アイテムの保存
        }
    }
    private var purchasedItems: [Item] = [] {
        didSet {
            savePurchasedItems()  // 購入済みのアイテムの保存
        }
    }

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // 画面がロードされたときに呼ばれるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()  // 画面がロードされたときに呼ばれるメソッド
        loadItems()  // UserDefaultsからアイテムを読み込む
        loadPurchasedItems()  // UserDefaultsから購入済みアイテムのロード
    }

    @IBAction func sortItems(_ sender: UISegmentedControl) { // ソートアクションが呼び出されたときに実行されるメソッド
        switch sender.selectedSegmentIndex {  // セグメントコントロールの選択されたインデックスに基づいて処理を分岐
        case 0:
            // 日付でソート
            items.sort {  // items 配列をソート
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
            items.sort { $0.category < $1.category }  // category プロパティを基準に昇順でソート
        case 2:
            // 名前でアイウエオ順にソート
            items.sort { $0.name.localizedCompare($1.name) == .orderedAscending }  // name プロパティをローカライズされた昇順でソート
        default:
            break  // 他のケースでは何もしない
        }
        tableView.reloadData()  // ソート後にテーブルビューを再読み込みして表示を更新
    }


    // セクション内の行数を返すメソッド
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count  // itemsの数を行数として返す
    }

    // 各セルの内容を設定するメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! ItemTableViewCell  // 再利用可能なセルを取得し、カスタムセルにキャスト
        let item = items[indexPath.row]  // 現在の行のアイテムを取得
        // カテゴリ名の1文字目を取得して表示する
        let categoryInitial = String(item.category.prefix(1))

        // item を設定し、category を 1文字目のみ渡す
        var modifiedItem = item
        modifiedItem.category = categoryInitial

        cell.configure(item: modifiedItem)  // セルをアイテムで設定
        return cell  // 設定済みのセルを返す
    }

    // セルが選択されたときの処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedItem = items[indexPath.row]
        selectedItem.isChecked = true  // チェック状態に変更
        purchasedItems.append(selectedItem)  // 購入済みに追加
        items.remove(at: indexPath.row)  // メインリストから削除
        tableView.deleteRows(at: [indexPath], with: .automatic)  // メインリストのセルを削除

        // 購入済みアイテムをUserDefaultsに保存
        savePurchasedItems()

        // NotificationCenterを使ってリストの更新を通知
        NotificationCenter.default.post(name: NSNotification.Name("PurchasedItemsUpdated"), object: nil)

        // 購入済みアイテムリストに更新を反映するために、購入済みリスト画面を再読み込み
        if let purchasedVC = navigationController?.viewControllers.first(where: { $0 is PurchasedItemsViewController }) as? PurchasedItemsViewController {
            purchasedVC.reloadPurchasedItems()  // 購入済みリストの画面を更新
        }
    }

    // アクセサリボタンがタップされたときの処理
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editIndexPath = indexPath  // 編集するセルのインデックスパスを保存
        performSegue(withIdentifier: "EditSegue", sender: indexPath)  // EditSegueで編集画面に遷移
    }

    // セルの削除が要求されたときの処理
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {  // 編集スタイルが削除の場合
            items.remove(at: indexPath.row)  // 対象アイテムを配列から削除
            tableView.deleteRows(at: [indexPath], with: .automatic)  // 対応する行をテーブルから削除
        }
    }

    // セグエが実行される直前の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let add = (segue.destination as? UINavigationController)?.topViewController as? AddItemViewController {  // 遷移先がAddItemViewControllerの場合
            switch segue.identifier ?? "" {  // セグエの識別子によって処理を分岐
            case "AddSegue":  // アイテム追加モード
                add.mode = .add  // AddItemViewControllerのモードを追加に設定
            case "EditSegue":  // アイテム編集モード
                if let indexPath = sender as? IndexPath {  // 編集対象のアイテムを設定
                    let item = items[indexPath.row]  // 選択されたアイテムを取得
                    add.mode = .edit(item)  // AddItemViewControllerのモードを編集に設定
                }
            default:  // それ以外のセグエは何もしない
                break
            }
        }
    }

    // 追加画面でキャンセルしたときの処理
    @IBAction func exitFromAddByCancel(segue: UIStoryboardSegue) {
    }

    // 追加画面で保存したときの処理
    @IBAction func exitFromAddBySave(segue: UIStoryboardSegue) {
        if let add = segue.source as? AddItemViewController {  // 遷移元がAddItemViewControllerの場合
            guard let item = add.editedItem else { return }  // 編集されたアイテムを取得
            items.append(item)  // 新しいアイテムを配列に追加
            let indexPath = IndexPath(row: items.count - 1, section: 0)  // 新しい行のインデックスパスを作成
            tableView.insertRows(at: [indexPath], with: .automatic)  // 新しい行をテーブルに追加
        }
    }

    // 編集画面でキャンセルしたときの処理
    @IBAction func exitFromEditByCancel(segue: UIStoryboardSegue) {
    }

    // 編集画面で保存したときの処理
    @IBAction func exitFromEditBySave(segue: UIStoryboardSegue) {
        if let add = segue.source as? AddItemViewController {  // 遷移元がAddItemViewControllerの場合
            if let indexPath = editIndexPath {  // 編集対象のインデックスパスが設定されている場合
                guard let editedItem = add.editedItem else { return }  // 編集されたアイテムを取得
                items[indexPath.row] = editedItem  // 配列内の対応するアイテムを更新
                tableView.reloadRows(at: [indexPath], with: .automatic)  // 対応する行を再読み込み
            }
        }
    }
    
    // アイテムをUserDefaultsに保存するメソッド
    private func saveItems() {
        let defaults = UserDefaults.standard  // UserDefaultsの標準インスタンスを取得
        if let data = try? JSONEncoder().encode(items) {  // アイテム配列をエンコード
            defaults.set(data, forKey: keyItems)  // エンコードされたデータをUserDefaultsに保存
        }
    }

    private func savePurchasedItems() {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(purchasedItems) {
            defaults.set(data, forKey: keyPurchasedItems)
        }
    }

    // UserDefaultsからアイテムを読み込むメソッド
    private func loadItems() {
        let defaults = UserDefaults.standard  // UserDefaultsの標準インスタンスを取得
        if let data = defaults.data(forKey: keyItems),  // 保存されたデータを取得
           let savedItems = try? JSONDecoder().decode([Item].self, from: data) {  // デコードしてアイテム配列に変換
            items = savedItems  // デコードされたアイテムを配列にセット
        }
    }

    private func loadPurchasedItems() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: keyPurchasedItems),
           let savedItems = try? JSONDecoder().decode([Item].self, from: data) {
            purchasedItems = savedItems
        }
    }
}
