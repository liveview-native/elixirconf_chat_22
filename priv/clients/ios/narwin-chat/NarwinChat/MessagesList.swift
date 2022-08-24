//
//  MessagesList.swift
//  NarwinChat
//
//  Created by Shadowfacts on 8/24/22.
//

import SwiftUI
import PhoenixLiveViewNative

struct MessagesList: View {
    let element: Element
    let context: LiveContext<MyRegistry>
    @State private var bottomMaxY: CGFloat = 0
    @State private var isScrolledToBottom = false
    
    init(element: Element, context: LiveContext<MyRegistry>) {
        self.element = element
        self.context = context
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geometry in
                // 0.001 is small enough that the color is invisible, but non-clear enough that the view is consistently updated (which it isn't with Color.clear)
                Color.pink.opacity(0.001)
                    .preference(key: PrefKey.self, value: geometry.frame(in: .global).maxY)
                    .onPreferenceChange(PrefKey.self) { newValue in
                        bottomMaxY = newValue
                    }
            }
            
            ScrollView {
                ScrollViewReader { scrollView in
                    ZStack(alignment: .bottomTrailing) {
                        Rectangle()
                            .frame(height: 10)
                            .foregroundColor(.clear)
                            .id("bottom")
                            .background {
                                GeometryReader { innerGeometry in
                                    Color.pink.opacity(0.001)
                                        .onChange(of: innerGeometry.frame(in: .global).maxY - bottomMaxY < 10) { newValue in
                                            isScrolledToBottom = newValue
                                        }
                                }
                            }
                        
                        context.buildChildren(of: element)
                    }
                    .onChange(of: element) { newValue in
                        if isScrolledToBottom {
                            scrollView.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onAppear {
                        scrollView.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
        }
    }
}

private struct PrefKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
