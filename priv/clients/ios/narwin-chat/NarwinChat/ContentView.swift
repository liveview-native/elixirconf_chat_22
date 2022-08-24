//
//  ContentView.swift
//  NarwinChat
//
//  Created by May Matyi on 7/22/22.
//

import SwiftUI
@_spi(NarwinChat) import PhoenixLiveViewNative

private var baseURL: URL {
    URL(string: "http://localhost:8080/")!
}

@MainActor
struct ContentView: View {
    @State var coordinator: LiveViewCoordinator<EmptyRegistry> = {
        var config = LiveViewConfiguration()
        config.navigationMode = .enabled
        config.eventHandlersEnabled = true
        config.liveRedirectsEnabled = true
        config.connectParams = { _ in
            if let token = LocalData.loginToken {
                return ["login_token": token]
            } else {
                return [:]
            }
        }
        let coordinator = LiveViewCoordinator(baseURL, config: config)
        coordinator.handleEvent("login_token") { payload in
            LocalData.loginToken = (payload["token"] as! String)
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
            components.path = "/lobby"
            Task {
                await coordinator.replaceTopNavigationEntry(with: components.url!)
            }
        }
        return coordinator
    }()

    var body: some View {
        LiveView(coordinator: coordinator)
    }
}
