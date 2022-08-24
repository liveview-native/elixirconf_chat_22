//
//  LocalData.swift
//  NarwinChat
//
//  Created by Shadowfacts on 8/24/22.
//

import Foundation

struct LocalData {
    private init() {}
    
    static var loginToken: String? {
        get {
            UserDefaults.standard.string(forKey: "loginToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "loginToken")
        }
    }
}
