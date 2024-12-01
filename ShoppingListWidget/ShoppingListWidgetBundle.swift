//
//  ShoppingListWidgetBundle.swift
//  ShoppingListWidgetExtension
//  
//  Created by Yuchinante on 2024/12/01
//  
//

import WidgetKit
import SwiftUI

@main
struct ShoppingListWidgetBundle: WidgetBundle {
    var body: some Widget {
        ShoppingListWidget()
        ShoppingListWidgetControl()
        ShoppingListWidgetLiveActivity()
    }
}
