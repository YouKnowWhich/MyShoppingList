//
//  AddItemViewController.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/08/10
//  
//

import UIKit

class AddItemViewController: UIViewController {
    // アイテムの追加・編集モードを管理する列挙型
    enum Mode {
        case add  // 新規追加モード
        case edit(TableViewController.Item)  // 編集モード

        // セーブボタンのセグエ識別子
        var saveButtonSegueIdentifier: String {
            switch self {
            case .add:
                return "exitFromAddBySaveSegue"
            case .edit:
                return "exitFromEditBySaveSegue"
            }
        }

        // キャンセルボタンのセグエ識別子
        var cancelButtonSegueIdentifier: String {
            switch self {
            case .add:
                return "exitFromAddByCancelSegue"
            case .edit:
                return "exitFromEditByCancelSegue"
            }
        }
    }

    var mode = Mode.add  // デフォルトで追加モードを設定


    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var nameTextField: UITextField!

    private(set) var editedItem: TableViewController.Item?

    // カテゴリ一覧データ
    private let categories = ["📕本・コミック・雑誌", "💿DVD・ミュージック・ゲーム", "📺家電・カメラ・AV機器",
                              "💻パソコン・オフィス用品","🍽ホーム＆キッチン・ペット・DIY", "🥐食品・飲料",
                              "🧴ドラッグストア・ビューティー","🍼ベビー・おもちゃ・ホビー", "👕服・シューズ・バッグ・腕時計",
                              "🏕スポーツ＆アウトドア", "🚗車＆バイク・産業・研究開発"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // ピッカービューの設定
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self

        // 今日の00:00の時間を取得
        let calendar = Calendar.current
        let now = Date()
        let midnightToday = calendar.startOfDay(for: now)  // 今日の00:00

        // モードに応じた初期設定
        switch mode {
        case .add:
            datePicker.date = midnightToday  // 追加モードでは今日の日付を設定
        case .edit(let item):
            nameTextField.text = item.name
            if let categoryIndex = categories.firstIndex(of: item.category) {
                categoryPickerView.selectRow(categoryIndex, inComponent: 0, animated: false)
            }
            datePicker.date = item.purchaseDate ?? midnightToday
        }
    }

    // セーブボタン押下時の処理
    @IBAction func pressSaveButton(_ sender: Any) {
        let selectedCategory = categories[categoryPickerView.selectedRow(inComponent: 0)]
        let selectedDate = datePicker.date

        let isChecked: Bool
        switch mode {
        case .add:
            isChecked = false  // 新規アイテムは未チェック
        case .edit(let oldItem):
            isChecked = oldItem.isChecked  // 編集時は元のチェック状態を保持
        }

        // 入力されたデータでアイテムを作成
        editedItem = TableViewController.Item(
            name: nameTextField.text ?? "",
            isChecked: isChecked,
            category: selectedCategory,
            purchaseDate: selectedDate
        )

        // セグエを実行
        performSegue(withIdentifier: mode.saveButtonSegueIdentifier, sender: sender)
    }

    // キャンセルボタン押下時の処理
    @IBAction func pressCancelButton(_ sender: Any) {  // キャンセルボタン押下時のセグエを実行
        performSegue(withIdentifier: mode.cancelButtonSegueIdentifier, sender: sender)
    }
}

// ピッカービューのデータソースとデリゲート
extension AddItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1  // コンポーネントは1つ
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    // ピッカービューの行にカテゴリ名を表示
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = categories[row]
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }

    // 行の高さを設定
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
}
