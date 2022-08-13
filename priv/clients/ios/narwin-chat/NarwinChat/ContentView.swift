//
//  ContentView.swift
//  NarwinChat
//
//  Created by May Matyi on 7/22/22.
//

import SwiftUI
import PhoenixLiveViewNative

struct ContentView: View {
    // TODO: Define remote URL as configuration value
    private let coordinator = LiveViewCoordinator(URL(string: "http://127.0.0.1:8080/chat?_platform=ios")!)

    var body: some View {
        LiveView(coordinator: coordinator)
    }
}
