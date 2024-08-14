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

    @IBOutlet weak var nameTextField: UITextField!  // アイテム名を入力するテキストフィールド

    private(set) var editedItem: TableViewController.Item?  // 編集後のアイテムを格納するプロパティ

    override func viewDidLoad() {
        super.viewDidLoad()

        switch mode {  // モードに応じた初期設定
        case .add:
            break  // 追加モードでは特に初期設定は不要
        case .edit(let item):
            nameTextField.text = item.name  // 編集モードでは既存のアイテム名をテキストフィールドにセット
        }
    }

    @IBAction func pressSaveButton(_ sender: Any) {
        let isChecked: Bool  // アイテムのチェック状態を管理する変数

        switch mode {
        case .add:
            isChecked = false  // 追加モードでは新規アイテムは未チェック状態
        case .edit(let oldItem):
            isChecked = oldItem.isChecked  // 編集モードでは既存アイテムのチェック状態を維持
        }

        editedItem = .init(name: nameTextField.text ?? "", isChecked: isChecked)  // 入力された名前とチェック状態で新しいアイテムを作成

        performSegue(withIdentifier: mode.saveButtonSegueIdentifier, sender: sender)
    }  // セーブボタン押下時のセグエを実行

    @IBAction func pressCancelButton(_ sender: Any) {  // キャンセルボタン押下時のセグエを実行
        performSegue(withIdentifier: mode.cancelButtonSegueIdentifier, sender: sender)
    }
}
