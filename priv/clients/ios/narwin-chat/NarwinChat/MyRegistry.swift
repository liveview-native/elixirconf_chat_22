//
//  MyRegistry.swift
//  NarwinChat
//
//  Created by Shadowfacts on 8/24/22.
//

import SwiftUI
import PhoenixLiveViewNative

struct MyRegistry: CustomRegistry {
    enum TagName: String {
        case messagesList = "messages-list"
        case localTime = "local-time"
    }
    enum AttributeName: String, Equatable {
        case rosterLink = "roster-link"
    }
    
    static func lookup(_ name: TagName, element: Element, context: LiveContext<MyRegistry>) -> some View {
        switch name {
        case .messagesList:
            MessagesList(element: element, context: context)
        case .localTime:
            LocalTime(element: element)
        }
    }
    
    static func applyCustomAttribute(_ name: AttributeName, value: String, element: Element, context: LiveContext<MyRegistry>) -> some View {
        switch name {
        case .rosterLink:
            context.buildElement(element)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        let rosterURL = URL(string: value, relativeTo: context.url)!
                        RosterLink(url: rosterURL)
                    }
                }
        }
    }
}
