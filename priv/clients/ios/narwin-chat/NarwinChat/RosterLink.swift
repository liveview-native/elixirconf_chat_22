//
//  RosterLink.swift
//  NarwinChat
//
//  Created by Shadowfacts on 8/24/22.
//

import SwiftUI
@_spi(NarwinChat) import PhoenixLiveViewNative

struct RosterLink: View {
    let url: URL
    let parentCoordinator: LiveViewCoordinator<MyRegistry>
    @State var isActive = false
    
    var body: some View {
        // TODO: once we're targetting iOS 16, this could just be NavigationLink(value: url) { ... }
        // rather than needing to create a whole new coordinator
        NavigationLink(isActive: $isActive) {
            RosterView(url: url)
        } label: {
            Label("Roster", systemImage: "person.3.fill")
        }
        .onChange(of: isActive) { newValue in
            // when un-presenting, reconnect in case blocks changed
            if newValue == false {
                Task {
                    await parentCoordinator.reconnect()
                }
            }
        }
    }
}

struct RosterView: View {
    @State var coordinator: LiveViewCoordinator<MyRegistry>
    
    init(url: URL) {
        var config = LiveViewConfiguration()
        config.connectParams = { _ in
            ["login_token": LocalData.loginToken!]
        }
        _coordinator = State(wrappedValue: LiveViewCoordinator(url, config: config))
    }
    
    var body: some View {
        LiveView(coordinator: coordinator)
    }
}
