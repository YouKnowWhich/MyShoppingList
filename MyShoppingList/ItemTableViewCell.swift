//
//  ItemTableViewCell.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/08/10
//  
//

import UIKit

// カスタムテーブルビューセルクラス
class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var purchaseDateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    // アイテムデータを用いてセルの内容を設定
    func configure(item: TableViewController.Item) {
        // チェックマークの表示切り替え
        checkImageView.image = item.isChecked ? UIImage(named: "check") : nil

        // 購入日の表示設定
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
}
