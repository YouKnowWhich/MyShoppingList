//
//  CustomTabBarController.swift
//  MyShoppingList
//  
//  Created by Yuchinante on 2024/12/19
//  
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        configureTabBarAppearance()
    }

    /// ダークモードに対応したタブバーの外観を設定
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()

        // ダークモード対応
        if traitCollection.userInterfaceStyle == .dark {
            appearance.backgroundColor = UIColor.black
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont.systemFont(ofSize: 12)
            ]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 14)
            ]
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        } else {
            appearance.backgroundColor = UIColor.white
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.darkGray,
                .font: UIFont.systemFont(ofSize: 12)
            ]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.black,
                .font: UIFont.boldSystemFont(ofSize: 14)
            ]
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.darkGray
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.black
        }

        // 外観を適用
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    /// タブ選択時にアニメーションを追加
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item),
              let tabBarButton = tabBar.subviews[safe: index + 1] else { return }

        // バウンドアニメーション
        UIView.animate(withDuration: 0.2,
                       animations: {
                           tabBarButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                       }) { _ in
            UIView.animate(withDuration: 0.2) {
                tabBarButton.transform = .identity
            }
        }
    }

    /// ダークモードやライトモードの切り替えをリアルタイムで検知
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // ダークモードとライトモードが切り替わった場合のみ外観を再設定
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            configureTabBarAppearance()
        }
    }
}

// Array安全アクセスのエクステンション（タブバーサブビュー取得用）
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
