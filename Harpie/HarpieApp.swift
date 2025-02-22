//
//  HarpieApp.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/8/24.
//

import SwiftUI
import SwiftData
import FirebaseCore

//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//    return true
//  }
//}

@main
struct HarpieApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        FirebaseService.shared.configureFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [UserInfo.self])
        }
    }
}
