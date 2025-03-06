//
//  PlaylistLimitManager.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 2/27/25.
//

import Foundation

class PlaylistLimitManager {
    private let userDefaults = UserDefaults.standard
    private let key = K.dailyLimitKey
    private let dateKey = K.dailyLimitLastDateKey
    private let maxPlaylistsPerDay = K.dailyLimit  // Set your desired limit

    func canCreatePlaylist() -> Bool {
        let today = formattedDate()
        
        // Check if the last saved date is today
        if let lastDate = userDefaults.string(forKey: dateKey), lastDate == today {
            let count = userDefaults.integer(forKey: key)
            return count < maxPlaylistsPerDay
        } else {
            // Reset count if it's a new day
            resetDailyCount()
            return true
        }
    }

    func recordPlaylistCreation() {
        let today = formattedDate()
        var count = userDefaults.integer(forKey: key)
        
        // If it's a new day, reset the count
        if userDefaults.string(forKey: dateKey) != today {
            resetDailyCount()
        }
        
        count += 1
        userDefaults.set(count, forKey: key)
        userDefaults.set(today, forKey: dateKey)
    }

    private func resetDailyCount() {
        userDefaults.set(0, forKey: key)
        userDefaults.set(formattedDate(), forKey: dateKey)
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
