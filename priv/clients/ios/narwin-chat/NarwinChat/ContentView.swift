//
//  ContentView.swift
//  NarwinChat
//
//  Created by May Matyi on 7/22/22.
//

import SwiftUI
@_spi(NarwinChat) import PhoenixLiveViewNative

private var baseURL: URL {
    #if DEBUG
    if let s = ProcessInfo.processInfo.environment["NARWINCHAT_BASE_URL"] {
        return URL(string: s)!
    } else {
        return URL(string: "http://localhost:8080/")!
    }
    #else
    return URL(string: "https://chatapp.dockyard.com/")!
    #endif
}

@MainActor
struct ContentView: View {
    @State var coordinator: LiveViewCoordinator<MyRegistry> = {
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
        let coordinator = LiveViewCoordinator<MyRegistry>(baseURL, config: config)
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
            .onAppear {
                // don't use transparent nav-bars when scrolled to the edge
                // this makes large titles look worse, but when scrolling slowly the bar never
                // becomes fully opaque, and that looks even worse
                UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBar().standardAppearance
            }
    }
}
