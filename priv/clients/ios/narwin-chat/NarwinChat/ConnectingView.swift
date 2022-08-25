//
//  ConnectingView.swift
//  NarwinChat
//
//  Created by Shadowfacts on 8/25/22.
//

import SwiftUI

struct ConnectingView: View {
    @State private var timer = Timer.publish(every: 0.25, on: .main, in: .default).autoconnect()
    @State private var ellipses = 0
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text("Connecting...")
                .foregroundColor(.clear)
            Text("Connecting\(String(repeating: ".", count: ellipses))")
        }
        .onReceive(timer) { _ in
            ellipses = (ellipses + 1) % 4
        }
    }
}
