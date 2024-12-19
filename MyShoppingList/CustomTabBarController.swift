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

        // タブバーの外観を初期設定
        configureTabBarAppearance()
    }

    /// 外観モードの変更を検知してタブバーの外観を更新
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // 外観モードが変更された場合
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            configureTabBarAppearance()
        }
    }

    /// タブバーの外観を設定
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()

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

        // タブバーの再描画を強制
        tabBar.setNeedsLayout()
        tabBar.layoutIfNeeded()
    }
}
