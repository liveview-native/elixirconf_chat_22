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
    typealias AttributeName = EmptyRegistry.None
    
    static func lookup(_ name: TagName, element: Element, context: LiveContext<MyRegistry>) -> some View {
        switch name {
        case .messagesList:
            MessagesList(element: element, context: context)
        case .localTime:
            LocalTime(element: element)
        }
    }
}
