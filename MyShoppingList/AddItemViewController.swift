//
//  AddItemViewController.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/08/10
//  
//

import UIKit

// MARK: - AddItemViewControllerDelegate
/// アイテム追加画面のデリゲートプロトコル
protocol AddItemViewControllerDelegate: AnyObject {
    func didSaveItem()
}

// MARK: - AddItemViewController
class AddItemViewController: UIViewController {

    // MARK: - モード設定 (追加/編集)
    enum Mode {
        case add
        case edit(Item)

        var saveButtonSegueIdentifier: String {
            switch self {
            case .add: return "exitFromAddBySaveSegue"
            case .edit: return "exitFromEditBySaveSegue"
            }
        }

        var cancelButtonSegueIdentifier: String {
            switch self {
            case .add: return "exitFromAddByCancelSegue"
            case .edit: return "exitFromEditByCancelSegue"
            }
        }
    }

    // MARK: - 定数
    private let suiteName = "group.com.example.MyShoppingList" // App Groups のグループ名
    private let maxItemNameLength = 30  // アイテム名の最大文字数
    private let categories: [String] = [
        "📕本・コミック・雑誌", "💿DVD・ミュージック・ゲーム", "📺家電・カメラ・AV機器",
        "💻パソコン・オフィス用品", "🍽ホーム＆キッチン・ペット・DIY", "🥐食品・飲料",
        "🧴ドラッグストア・ビューティー", "🍼ベビー・おもちゃ・ホビー", "👕服・シューズ・バッグ・腕時計",
        "🏕スポーツ＆アウトドア", "🚗車＆バイク・産業・研究開発"
    ]

    // MARK: - プロパティ
    weak var delegate: AddItemViewControllerDelegate?
    var mode = Mode.add
    private(set) var editedItem: Item?

    // MARK: - アウトレット
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    // MARK: - ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - 初期設定
    /// 画面のUIをセットアップ
    private func setupUI() {
        configurePickerView()
        configureTextField()
        initializeValues()
        updateSaveButtonState()
    }

    /// ピッカービューの設定
    private func configurePickerView() {
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
    }

    /// テキストフィールドの設定
    private func configureTextField() {
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    /// 初期値の設定
    private func initializeValues() {
        let midnightToday = Calendar.current.startOfDay(for: Date())

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

    // MARK: - ボタンアクション
    // 保存ボタン押下時の処理
    @IBAction private func pressSaveButton(_ sender: UIBarButtonItem) {
        guard let itemName = nameTextField.text, !itemName.isEmpty else {
            showAlert(message: "アイテム名を入力してください。")
            return
        }

        if isDuplicateItem(name: itemName) {
            showAlert(message: "同じ名前、カテゴリ、日付のアイテムが既に存在します。")
            return
        }

        createItem(name: itemName)
        performSegue(withIdentifier: mode.saveButtonSegueIdentifier, sender: sender)
        delegate?.didSaveItem()
    }

    // キャンセルボタン押下時の処理
    @IBAction private func pressCancelButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: mode.cancelButtonSegueIdentifier, sender: sender)
    }

    // MARK: - アイテム操作
    /// アイテムを作成する
    private func createItem(name: String) {
        let selectedCategory = categories[categoryPickerView.selectedRow(inComponent: 0)]
        let selectedDate = datePicker.date

        let itemID: UUID
        let isChecked: Bool

        switch mode {
        case .add:
            isChecked = false
            itemID = UUID()
        case .edit(let oldItem):
            isChecked = oldItem.isChecked
            itemID = oldItem.id
        }

        editedItem = Item(
            id: itemID,
            name: name,
            isChecked: isChecked,
            category: selectedCategory,
            purchaseDate: selectedDate
        )
    }

    /// アイテムの重複を確認
    private func isDuplicateItem(name: String) -> Bool {
        guard let existingItems = retrieveExistingItems() else { return false }

        let selectedCategory = categories[categoryPickerView.selectedRow(inComponent: 0)]
        return existingItems.contains {
            $0.name == name && $0.category == selectedCategory && $0.purchaseDate == datePicker.date
        }
    }

    // MARK: - ユーティリティ
    /// エラーメッセージを表示
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "入力エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    /// 既存のアイテムを取得
    private func retrieveExistingItems() -> [Item]? {
        guard let userDefaults = UserDefaults(suiteName: suiteName),
              let data = userDefaults.data(forKey: "items") else { return nil }
        return try? JSONDecoder().decode([Item].self, from: data)
    }

    /// テキストフィールド変更時に保存ボタンの状態を更新
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateSaveButtonState()
    }

    /// 保存ボタンの状態を更新
    private func updateSaveButtonState() {
        saveButton.isEnabled = !(nameTextField.text?.isEmpty ?? true)
    }
}

// MARK: - UIPickerViewDataSource / UIPickerViewDelegate
extension AddItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = categories[row]
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
}

// MARK: - UITextFieldDelegate
extension AddItemViewController: UITextFieldDelegate {
    /// テキストフィールドの文字数制限
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxItemNameLength
    }
}
