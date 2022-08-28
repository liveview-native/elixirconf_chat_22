//
//  SubmitOnEnterModifier.swift
//  NarwinChat
//
//  Created by Shadowfacts on 8/28/22.
//

import SwiftUI
@_spi(NarwinChat) import PhoenixLiveViewNative

struct SubmitOnEnterModifier: ViewModifier {
    let id: String
    @EnvironmentObject private var liveViewModel: LiveViewModel<MyRegistry>
    
    func body(content: Content) -> some View {
        content
            .keyboardShortcut(.return, modifiers: .command)
            .environment(\.textFieldPrimaryAction, {
                Task {
                    // can't use context.formModel because that's only available to _children_ of the form, whereas this attr is directly on the <phx-form>
                    let formModel = liveViewModel.getForm(elementID: id)
                    try? await formModel.sendSubmitEvent()
                    formModel.clear()
                }
            })
    }
}
