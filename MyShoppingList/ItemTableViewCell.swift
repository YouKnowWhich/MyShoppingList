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
    @IBOutlet weak var nameLabel: UILabel!  // アイテム名を表示するためのラベル

    // セルの内容をアイテムデータで設定するメソッド/
    func configure(item: TableViewController.Item) {
        if item.isChecked {  // アイテムがチェックされている場合、チェックマーク画像を設定
            checkImageView.image = UIImage(named: "check")  // "check"という名前の画像を表示
        } else {
            checkImageView.image = nil  // チェックされていない場合、画像を表示しない
        }
        nameLabel.text = item.name  // アイテム名をラベルに設定
    }
}
