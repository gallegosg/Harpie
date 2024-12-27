//
//  UserInfo.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/13/24.
//

import SwiftData

struct UserResponse: Codable {
    var country: String
    var displayName: String
    var email: String
    var explicitContent: ExplicitContent
    var externalUrls: ExternalUrls
    var followers: Followers
    var href: String
    var id: String
    var images: [ProfileImage]
    var product: String
    var type: String
    var uri: String

    enum CodingKeys: String, CodingKey {
        case country
        case displayName = "display_name"
        case email
        case explicitContent = "explicit_content"
        case externalUrls = "external_urls"
        case followers, href, id, images, product, type, uri
    }
}

// MARK: - ExplicitContent
struct ExplicitContent: Codable {
    var filterEnabled: Bool
    var filterLocked: Bool

    enum CodingKeys: String, CodingKey {
        case filterEnabled = "filter_enabled"
        case filterLocked = "filter_locked"
    }
}

// MARK: - ExternalUrls
struct ExternalUrls: Codable {
    var spotify: String
    
    init(spotify: String) {
        self.spotify = spotify
    }
    
    enum CodingKeys: String, CodingKey {
        case spotify
    }
}

// MARK: - Followers
struct Followers: Codable {
    var href: String?
    var total: Int
}

// MARK: - Image
struct ProfileImage: Codable {
    var url: String
    var height: Int
    var width: Int
    
}

