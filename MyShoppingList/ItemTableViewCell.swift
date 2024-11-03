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

    // 日付フォーマッタ（キャッシュして再利用）
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    // アイテムのデータを用いてセルを設定
    func configure(item: TableViewController.Item) {
        isChecked = item.isChecked
        updateCheckBoxAppearance(isChecked: isChecked)

        // 購入日を設定。データがなければ "No Date" を表示
        if let purchaseDate = item.purchaseDate {
            purchaseDateLabel.text = Self.dateFormatter.string(from: purchaseDate)
        } else {
            purchaseDateLabel.text = "No Date"
        }

        // カテゴリと名前の表示
        categoryLabel.text = item.category
        nameLabel.text = item.name
    }
    // チェックボックスの状態をUIに反映
    private func updateCheckBoxAppearance(isChecked: Bool) {
        let checkBoxImage = isChecked ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
        UIView.transition(with: checkBoxButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.checkBoxButton.setImage(checkBoxImage, for: .normal)
        }, completion: nil)
    }

    // チェックボックスがタップされたときに呼ばれるアクション
    @IBAction func toggleCheck(_ sender: UIButton) {
        isChecked.toggle()
        updateCheckBoxAppearance(isChecked: isChecked)

        // デリゲートメソッドの呼び出し
        delegate?.didToggleCheck(for: self)
    }
}
