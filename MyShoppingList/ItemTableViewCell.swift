//
//  ItemTableViewCell.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/08/10
//  
//

import UIKit

protocol ItemToggleDelegate: AnyObject {
    func didToggleCheck(for cell: ItemTableViewCell)
}

protocol ItemEditDelegate: AnyObject {
    func didTapEditButton(for cell: ItemTableViewCell)
}

// MARK: - ItemTableViewCell
class ItemTableViewCell: UITableViewCell {

    // MARK: - アウトレット
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var purchaseDateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton! // 買い物リスト用のEditButton

    // MARK: - プロパティ
    weak var toggleDelegate: ItemToggleDelegate?
    weak var editDelegate: ItemEditDelegate?

    private var isChecked: Bool = false

    private let suiteName = "group.com.example.MyShoppingList" // App Groups のグループ名

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("Md")
        return formatter
    }()

    // MARK: - 公開メソッド
    /// `isShoppingList` が true の場合のみ EditButton を表示
    func configure(with item: Item, isShoppingList: Bool) {
        setupFontStyles()
        setupDynamicTypeSupport()
        setupNameLabelAppearance()

        isChecked = item.isChecked
        updateCheckBoxAppearance()

        purchaseDateLabel.text = item.purchaseDate.map(Self.dateFormatter.string(from:)) ?? "No Date"
        categoryLabel.text = item.category
        nameLabel.text = item.name

        // 買い物リストの場合のみ editButton を設定
        if isShoppingList {
            editButton?.isHidden = false
            editButton?.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
            editButton?.tintColor = .systemBlue
        } else {
            editButton?.isHidden = true
        }
    }

    // MARK: - アクション
    @IBAction private func toggleCheck(_ sender: UIButton) {
        isChecked.toggle()
        updateCheckBoxAppearance()
        toggleDelegate?.didToggleCheck(for: self)
        saveCheckStateToUserDefaults()
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        editDelegate?.didTapEditButton(for: self)
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
