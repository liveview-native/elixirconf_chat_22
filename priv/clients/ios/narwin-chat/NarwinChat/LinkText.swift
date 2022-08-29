//
//  LinkText.swift
//  NarwinChat
//
//  Created by Shadowfacts on 8/29/22.
//

import SwiftUI
import PhoenixLiveViewNative

struct LinkText: View {
    let string: NSAttributedString
    
    init(element: Element) {
        let text = element.ownText()
        let s = NSMutableAttributedString(string: text)
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            for match in detector.matches(in: text, range: NSRange(location: 0, length: text.utf16.count)) {
                let substr = (text as NSString).substring(with: match.range)
                if let url = URL(string: substr) {
                    s.addAttribute(.link, value: url, range: match.range)
                }
            }
        } catch {
            // ignored
        }
        self.string = s
    }
    
    var body: some View {
        Text(AttributedString(string))
    }
}
