//
//  LocalTime.swift
//  NarwinChat
//
//  Created by Shadowfacts on 8/24/22.
//

import SwiftUI
import PhoenixLiveViewNative


struct LocalTime: View {
    
    let date: Date
    
    init(element: Element) {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate, .withFullTime]
        self.date = f.date(from: try! element.attr("datetime"))!
    }
    
    var body: some View {
        Text(date, style: .time)
    }
}
