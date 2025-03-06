//
//  PlaylistResponse.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/10/24.
//

import Foundation

struct PlaylistResponse: Codable {
    let message: String
    let sentiments: [String]
    let playlist: [Song]
}

struct Song: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    let title: String
    let artist: String
    var checked: Bool = true
    var spotifyId: String
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        return lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
            case title, artist, spotifyId
        }
}

extension PlaylistResponse {
    static let dummy = PlaylistResponse(message: "dummy data", sentiments: ["dmmy"], playlist: [Song(title: "Wake Me Up", artist: "Avicii", checked: true, spotifyId: "0nrRP2bk19rLc0orkWPQk2"), Song(title: "Good Morning", artist: "Max Frost", checked: true, spotifyId: "21YulUEEuIftI57cmEoRoW"), Song(title: "Best Day of My Life", artist: "American Authors", spotifyId: "5Hroj5K7vLpIG4FNCRIjbP")])
}
