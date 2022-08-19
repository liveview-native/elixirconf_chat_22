//
//  ContentView.swift
//  NarwinChat
//
//  Created by May Matyi on 7/22/22.
//

import SwiftUI
import PhoenixLiveViewNative

struct ContentView: View {
    @State var coordinator = LiveViewCoordinator(URL(string: "http://localhost:8080/chat")!)

    var body: some View {
        LiveView(coordinator: coordinator)
    }
}
