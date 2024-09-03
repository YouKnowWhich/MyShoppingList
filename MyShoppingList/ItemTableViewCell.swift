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
    @IBOutlet weak var checkImageView: UIImageView!  // チェックマークを表示するための画像ビュー
    @IBOutlet weak var purchaseDateLabel: UILabel!  // 購入日を表示するためのラベル
    @IBOutlet weak var categoryLabel: UILabel!  // カテゴリー名を表示するためのラベル
    @IBOutlet weak var nameLabel: UILabel!  // アイテム名を表示するためのラベル

    // セルの内容をアイテムデータで設定するメソッド/
    func configure(item: TableViewController.Item) {
        if item.isChecked {  // アイテムがチェックされている場合、チェックマーク画像を設定
            checkImageView.image = UIImage(named: "check")  // "check"という名前の画像を表示
        } else {
            checkImageView.image = nil  // チェックされていない場合、画像を表示しない
        }
        if let purchaseDate = item.purchaseDate {  // 購入日が設定されている場合
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d"  // 月/日形式に設定
            purchaseDateLabel.text = dateFormatter.string(from: purchaseDate)  // 日付を文字列に変換してラベルに設定
        } else {
            purchaseDateLabel.text = "No Date"  // 購入日が未設定の場合の表示
        }
        categoryLabel.text = item.category  // カテゴリー名をラベルに設定
        nameLabel.text = item.name  // アイテム名をラベルに設定

    }
}
