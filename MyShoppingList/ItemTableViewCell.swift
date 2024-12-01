//
//  ItemTableViewCell.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/08/10
//  
//

import UIKit

// MARK: - ItemTableViewCellDelegate
protocol ItemTableViewCellDelegate: AnyObject {
    func didToggleCheck(for cell: ItemTableViewCell)
}

// MARK: - ItemTableViewCell
class ItemTableViewCell: UITableViewCell {

    // MARK: - アウトレット
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var purchaseDateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    // MARK: - プロパティ
    weak var delegate: ItemTableViewCellDelegate?
    private var isChecked: Bool = false

    private let suiteName = "group.com.example.MyShoppingList" // App Groups のグループ名

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("Md")
        return formatter
    }()

    // MARK: - 公開メソッド
    func configure(with item: Item) {
        setupFontStyles()
        setupDynamicTypeSupport()
        setupNameLabelAppearance()

        isChecked = item.isChecked
        updateCheckBoxAppearance()

        purchaseDateLabel.text = item.purchaseDate.map(Self.dateFormatter.string(from:)) ?? "No Date"
        categoryLabel.text = item.category
        nameLabel.text = item.name
    }

    // MARK: - アクション
    @IBAction private func toggleCheck(_ sender: UIButton) {
        isChecked.toggle()
        updateCheckBoxAppearance()
        delegate?.didToggleCheck(for: self)
        saveCheckStateToUserDefaults()
    }

    // MARK: - プライベートメソッド
    /// フォントスタイルを設定
    private func setupFontStyles() {
        nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        categoryLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        purchaseDateLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    }

    /// ダイナミックタイプの対応を設定
    private func setupDynamicTypeSupport() {
        nameLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.adjustsFontForContentSizeCategory = true
        purchaseDateLabel.adjustsFontForContentSizeCategory = true
    }

    /// 名前ラベルの外観を設定
    private func setupNameLabelAppearance() {
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping
    }

    /// チェックボックスの見た目を更新
    private func updateCheckBoxAppearance() {
        let checkBoxImage = isChecked
            ? UIImage(systemName: "checkmark.square")
            : UIImage(systemName: "square")

        UIView.transition(with: checkBoxButton, duration: 0.2, options: .transitionCrossDissolve) {
            self.checkBoxButton.setImage(checkBoxImage, for: .normal)
        }
    }

    /// チェック状態を UserDefaults に保存
    private func saveCheckStateToUserDefaults() {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else { return }

        // ここでは例として、単純な値（キーとチェック状態）を保存
        let checkStateKey = "checkState-\(nameLabel.text ?? "unknown")"
        userDefaults.set(isChecked, forKey: checkStateKey)
    }
}
