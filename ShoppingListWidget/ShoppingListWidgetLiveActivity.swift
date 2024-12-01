//
//  ShoppingListWidgetLiveActivity.swift
//  ShoppingListWidgetExtension
//  
//  Created by Yuchinante on 2024/12/01
//  
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ShoppingListWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ShoppingListWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ShoppingListWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ShoppingListWidgetAttributes {
    fileprivate static var preview: ShoppingListWidgetAttributes {
        ShoppingListWidgetAttributes(name: "World")
    }
}

extension ShoppingListWidgetAttributes.ContentState {
    fileprivate static var smiley: ShoppingListWidgetAttributes.ContentState {
        ShoppingListWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ShoppingListWidgetAttributes.ContentState {
         ShoppingListWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ShoppingListWidgetAttributes.preview) {
   ShoppingListWidgetLiveActivity()
} contentStates: {
    ShoppingListWidgetAttributes.ContentState.smiley
    ShoppingListWidgetAttributes.ContentState.starEyes
}
