//
//  AddItemViewController.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/08/10
//  
//

import UIKit

class AddItemViewController: UIViewController {
    // アイテムの追加・編集モード
    enum Mode {
        case add  // 新規追加
        case edit(TableViewController.Item)  // 編集

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

    var mode = Mode.add  // デフォルトで追加モード

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private(set) var editedItem: TableViewController.Item?
    private let maxItemNameLength = 30  // アイテム名の最大長

    // カテゴリ一覧データ
    private let categories = ["📕本・コミック・雑誌", "💿DVD・ミュージック・ゲーム", "📺家電・カメラ・AV機器",
                              "💻パソコン・オフィス用品","🍽ホーム＆キッチン・ペット・DIY", "🥐食品・飲料",
                              "🧴ドラッグストア・ビューティー","🍼ベビー・おもちゃ・ホビー", "👕服・シューズ・バッグ・腕時計",
                              "🏕スポーツ＆アウトドア", "🚗車＆バイク・産業・研究開発"]

    override func viewDidLoad() {
        super.viewDidLoad()
        print("AddItemViewController mode is: \(mode)")  // デバッグ出力
        setupPickerViews()
        setupInitialValues()
        nameTextField.delegate = self  // UITextFieldDelegateの設定
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        updateSaveButtonState()
    }

    // ピッカービューの設定
    private func setupPickerViews() {
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
    }

    private func setupInitialValues() {
        let calendar = Calendar.current
        let midnightToday = calendar.startOfDay(for: Date())

        switch mode {
        case .add:
            datePicker.date = midnightToday
            categoryPickerView.selectRow(0, inComponent: 0, animated: false)
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
        guard let itemName = nameTextField.text, !itemName.isEmpty else {
            showAlert(message: "アイテム名を入力してください。")
            return
        }

        // 重複アイテムチェック
        if let existingItems = retrieveExistingItems(), existingItems.contains(where: { $0.name == itemName && $0.category == categories[categoryPickerView.selectedRow(inComponent: 0)] && $0.purchaseDate == datePicker.date }) {
            showAlert(message: "同じ名前、カテゴリ、日付のアイテムが既に存在します。")
            return
        }

        let selectedCategory = categories[categoryPickerView.selectedRow(inComponent: 0)]
        let selectedDate = datePicker.date

        let isChecked: Bool
        let itemID: UUID
        switch mode {
        case .add:
            isChecked = false  // 新規アイテムは未チェック
            itemID = UUID()
        case .edit(let oldItem):
            isChecked = oldItem.isChecked  // 編集時は元のチェック状態を保持
            itemID = oldItem.id
        }

        // 入力されたデータでアイテムを作成
        editedItem = TableViewController.Item(
            id: itemID,
            name: itemName,
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

    // 入力チェックに引っかかった場合のアラート表示
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "入力エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    // アイテムリストの取得（仮の関数）
    private func retrieveExistingItems() -> [TableViewController.Item]? {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "items"),
           let items = try? JSONDecoder().decode([TableViewController.Item].self, from: data) {
            return items
        }
        return nil
    }
    // 保存ボタンの有効/無効状態の更新
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateSaveButtonState()
    }

    private func updateSaveButtonState() {
        saveButton.isEnabled = !(nameTextField.text?.isEmpty ?? true)
    }
}

// ピッカービューのデータソースとデリゲート
extension AddItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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

// UITextFieldDelegateの拡張 - 文字数制限の追加
extension AddItemViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxItemNameLength
    }
}
