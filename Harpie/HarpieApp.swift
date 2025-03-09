//
//  HarpieApp.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/8/24.
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleMobileAds

@main
struct HarpieApp: App {
    init() {
        FirebaseService.shared.configureFirebase()
//        let appID = Bundle.main.object(forInfoDictionaryKey: "GADApplicationIdentifier") as? String
//        print(appID)
        MobileAds.shared.start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [UserInfo.self])
        }
    }
}
