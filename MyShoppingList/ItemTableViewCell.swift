//
//  ItemTableViewCell.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/08/10
//  
//

import UIKit

// MARK: - デリゲートプロトコル
/// チェックボックスの状態変更を通知するデリゲート
protocol ItemToggleDelegate: AnyObject {
    func didToggleCheck(for cell: ItemTableViewCell)
}

/// 編集ボタンタップを通知するデリゲート
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
    private var isDeleteMode = false
    private let suiteName = "group.com.example.MyShoppingList" // App Groups のグループ名

    /// 日付フォーマッタ (静的プロパティ)
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("Md")
        return formatter
    }()

    // MARK: - セルの設定
    /// セルを初期化してデータを設定
    /// - Parameters:
    ///   - item: 表示するアイテム
    ///   - isShoppingList: 買い物リストの場合は `true`
    ///   - isDeleteMode: 削除モードの場合は `true`
    func configure(with item: Item, isShoppingList: Bool, isDeleteMode: Bool) {
        setupFontStyles()
        setupDynamicTypeSupport()
        setupNameLabelAppearance()
        updateCheckBoxAppearance()

        // アイテムの状態を設定
        isChecked = item.isChecked
        self.isDeleteMode = isDeleteMode
        checkBoxButton.isEnabled = !isDeleteMode

        // 編集ボタンの設定
        if let editButton = editButton {
            editButton.isEnabled = !isDeleteMode
            editButton.isHidden = isDeleteMode || !isShoppingList
        }

        // ラベルの内容を設定
        purchaseDateLabel.text = item.purchaseDate.map(Self.dateFormatter.string(from:)) ?? "No Date"
        categoryLabel.text = item.category
        nameLabel.text = item.name

        // 買い物リスト用の編集ボタン設定
        if isShoppingList {
            setupEditButton()
        } else {
            editButton?.isHidden = true
        }
    }

    // MARK: - アクション
    /// チェックボックスをトグル
    @IBAction private func toggleCheck(_ sender: UIButton) {
        guard !isDeleteMode else { return }
        isChecked.toggle()
        updateCheckBoxAppearance()
        toggleDelegate?.didToggleCheck(for: self)
        saveCheckStateToUserDefaults()
    }

    /// 編集ボタンがタップされた時の処理
    @IBAction func editButtonTapped(_ sender: UIButton) {
        guard !isDeleteMode else { return }
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

    /// 編集ボタンの外観を設定
    private func setupEditButton() {
        editButton?.isHidden = false
        editButton?.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        editButton?.tintColor = .systemBlue
    }

    /// チェックボックスの外観を更新
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

        // チェック状態を保存 (キーは名前を使用)
        let checkStateKey = "checkState-\(nameLabel.text ?? "unknown")"
        userDefaults.set(isChecked, forKey: checkStateKey)
    }
}
