//
//  AddItemViewController.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/08/10
//  
//

import UIKit

class AddItemViewController: UIViewController {
    // モードを管理する列挙型
    enum Mode {
        case add  // 新しいアイテムを追加するモード
        case edit(TableViewController.Item)  // 既存のアイテムを編集するモード

        // セーブボタンが押されたときのセグエ識別子を返すプロパティ
        var saveButtonSegueIdentifier: String {
            switch self {
            case .add:
                return "exitFromAddBySaveSegue"  // 追加モードのセグエ識別子
            case .edit(let oldItem):
                return "exitFromEditBySaveSegue"  // 編集モードのセグエ識別子
            }
        }

        // キャンセルボタンが押されたときのセグエ識別子を返すプロパティ
        var cancelButtonSegueIdentifier: String {
            switch self {
            case .add:
                return "exitFromAddByCancelSegue"  // 追加モードのキャンセルセグエ識別子
            case .edit(let oldItem):
                return "exitFromEditByCancelSegue"  // 編集モードのキャンセルセグエ識別子
            }
        }
    }

    var mode = Mode.add  // デフォルトで追加モードを設定


    @IBOutlet weak var datePicker: UIDatePicker!  // 購入日を選択するデートピッカー
    @IBOutlet weak var categoryPickerView: UIPickerView!  // カテゴリを選択するピッカービュー
    @IBOutlet weak var nameTextField: UITextField!  // アイテム名を入力するテキストフィールド

    private(set) var editedItem: TableViewController.Item?  // 編集後のアイテムを格納するプロパティ

    private let categories = ["📕本・コミック・雑誌", "💿DVD・ミュージック・ゲーム", "📺家電・カメラ・AV機器",
                              "💻パソコン・オフィス用品","🍽ホーム＆キッチン・ペット・DIY", "🥐食品・飲料",
                              "🧴ドラッグストア・ビューティー","🍼ベビー・おもちゃ・ホビー", "👕服・シューズ・バッグ・腕時計",
                              "🏕スポーツ＆アウトドア", "🚗車＆バイク・産業・研究開発"]  // カテゴリデータ

    override func viewDidLoad() {
        super.viewDidLoad()

        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self

        // 現在の日付の時間を00:00に設定
        let calendar = Calendar.current
        let now = Date()
        let midnightToday = calendar.startOfDay(for: now)  // 今日の00:00

        switch mode {  // モードに応じた初期設定
        case .add:
            datePicker.date = midnightToday  // 追加モードでは日付を現在の日付で、時間を00:00にセット
        case .edit(let item):
            nameTextField.text = item.name  // 編集モードでは既存のアイテム名をテキストフィールドにセット
            if let categoryIndex = categories.firstIndex(of: item.category) {
                categoryPickerView.selectRow(categoryIndex, inComponent: 0, animated: false)
            }
            if let date = item.purchaseDate {
                datePicker.date = date  // 編集モードでは既存の購入日をセット
            } else {
                datePicker.date = midnightToday  // 購入日が設定されていない場合は今日の00:00
            }
        }
    }

    @IBAction func pressSaveButton(_ sender: Any) {
        let isChecked: Bool  // アイテムのチェック状態を管理する変数
        let selectedCategory = categories[categoryPickerView.selectedRow(inComponent: 0)]  // 選択されたカテゴリ
        let selectedDate = datePicker.date  // 選択された購入日

        switch mode {
        case .add:
            isChecked = false  // 追加モードでは新規アイテムは未チェック状態
        case .edit(let oldItem):
            isChecked = oldItem.isChecked  // 編集モードでは既存アイテムのチェック状態を維持
        }

        editedItem = TableViewController.Item(
            name: nameTextField.text ?? "",
            isChecked: isChecked,
            category: selectedCategory,
            purchaseDate: selectedDate
        )  // 入力された名前、カテゴリ、購入日、チェック状態で新しいアイテムを作成

        performSegue(withIdentifier: mode.saveButtonSegueIdentifier, sender: sender)
    }  // セーブボタン押下時のセグエを実行

    @IBAction func pressCancelButton(_ sender: Any) {  // キャンセルボタン押下時のセグエを実行
        performSegue(withIdentifier: mode.cancelButtonSegueIdentifier, sender: sender)
    }
}

// ピッカービューのデータソースとデリゲートを設定するための拡張
extension AddItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1  // カテゴリは一つのコンポーネントで選択
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count  // カテゴリの数を返す
    }

    // 各行に表示するカテゴリ名を返すメソッドをカスタマイズ
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = categories[row]
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)  // フォントサイズを15に設定
        return label
    }

    // 行の高さを設定するメソッド（オプション、必要に応じて調整）
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35  // 行の高さを指定
    }
}
