//
//  ItemTableViewCell.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/08/10
//  
//

import UIKit

// チェックボックスのトグルを通知するデリゲートプロトコル
protocol ItemTableViewCellDelegate: AnyObject {
    func didToggleCheck(for cell: ItemTableViewCell)
}

// アイテム情報を表示するカスタムセル
class ItemTableViewCell: UITableViewCell {

    // MARK: - アウトレット
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var purchaseDateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    // MARK: - プロパティ
    weak var delegate: ItemTableViewCellDelegate?  // デリゲート（弱参照）
    private var isChecked: Bool = false            // チェック状態

    // 日付フォーマッタ
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current // ユーザーのロケールを使用
        formatter.setLocalizedDateFormatFromTemplate("Md") // 月と日のみを表示
        return formatter
    }()

    // MARK: - セル設定

    // アイテムデータでセルを設定
    func configure(with item: TableViewController.Item) {
        nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        purchaseDateLabel.font = UIFont.preferredFont(forTextStyle: .footnote)

        nameLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.adjustsFontForContentSizeCategory = true
        purchaseDateLabel.adjustsFontForContentSizeCategory = true

        // 複数行対応
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping

        isChecked = item.isChecked
        updateCheckBoxAppearance()

        // 購入日ラベルの設定
        purchaseDateLabel.text = item.purchaseDate != nil ? Self.dateFormatter.string(from: item.purchaseDate!) : "No Date"

        // カテゴリと名前の設定
        categoryLabel.text = item.category
        nameLabel.text = item.name
    }

    // MARK: - UI更新

    // チェックボックスの見た目を更新
    private func updateCheckBoxAppearance() {
        let checkBoxImage = isChecked ? UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
        UIView.transition(with: checkBoxButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.checkBoxButton.setImage(checkBoxImage, for: .normal)
        }
    }

    // MARK: - アクション

    // チェックボックスがタップされたときに呼ばれるアクション
    @IBAction func toggleCheck(_ sender: UIButton) {
        isChecked.toggle()
        updateCheckBoxAppearance()
        delegate?.didToggleCheck(for: self)  // デリゲート呼び出し
    }
}
