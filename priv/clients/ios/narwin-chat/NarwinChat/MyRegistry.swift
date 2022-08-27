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
        case swipeEvent = "swipe-event"
        case fixMultilineText = "fix-multiline-text"
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
                        RosterLink(url: rosterURL, parentCoordinator: context.coordinator)
                    }
                }
        case .swipeEvent:
            context.buildElement(element)
                .swipeActions {
                    Button(role: .destructive) {
                        if let s = element.attrIfPresent("swipe-event-param"), let e = element.attrIfPresent("swipe-event") {
                            Task {
                                try await context.coordinator.pushEvent(type: "click", event: e, value: ["id": s])
                            }
                        }
                    } label: {
                        if let s = element.attrIfPresent("swipe-event-label") {
                            Text(s)
                        }
                    }
                }
        case .fixMultilineText:
            // fix for multiline text being truncated on iOS 15, even though the view is laid out with enough space for it
            // on iOS 16, this isn't needed
            context.buildElement(element)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    static func loadingView(for url: URL, state: LiveViewCoordinator<MyRegistry>.State) -> some View {
        ConnectingView()
    }
}
