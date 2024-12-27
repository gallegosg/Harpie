//
//  HarpieApp.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/8/24.
//

import SwiftUI
import SwiftData

@main
struct HarpieApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [UserInfo.self])
        }
    }
}
