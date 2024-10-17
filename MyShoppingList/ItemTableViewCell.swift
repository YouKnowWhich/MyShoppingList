//
//  ItemTableViewCell.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/08/10
//  
//

import UIKit

// セル内のチェックボックスがトグルされたことを通知するためのデリゲートプロトコル
protocol ItemTableViewCellDelegate: AnyObject {
    func didToggleCheck(for cell: ItemTableViewCell)
}

// カスタムテーブルビューセルクラス
class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var purchaseDateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    weak var delegate: ItemTableViewCellDelegate?  // デリゲートを弱参照で保持
    private var isChecked: Bool = false  // アイテムのチェック状態を保持

    // アイテムのデータを用いてセルを設定
    func configure(item: TableViewController.Item) {
        isChecked = item.isChecked
        updateCheckBox()

        // 購入日があれば表示、なければ "No Date" を表示
        if let purchaseDate = item.purchaseDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d"
            purchaseDateLabel.text = dateFormatter.string(from: purchaseDate)
        } else {
            purchaseDateLabel.text = "No Date"
        }

        // カテゴリと名前の表示
        categoryLabel.text = item.category
        nameLabel.text = item.name
    }
    // チェックボックスの状態をUIに反映
    private func updateCheckBox() {
        guard let checkBoxButton = checkBoxButton else {
            print("checkBoxButtonがnilです")
            return
        }
        let checkBoxImage = isChecked ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
        checkBoxButton.setImage(checkBoxImage, for: .normal)
    }

    // チェックボックスがタップされたときに呼ばれるアクション
    @IBAction func toggleCheck(_ sender: UIButton) {
        isChecked.toggle()
        updateCheckBox()
        delegate?.didToggleCheck(for: self)  // デリゲートを通じてチェック状態を通知
    }
}
