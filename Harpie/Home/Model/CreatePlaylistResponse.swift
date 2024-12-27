//
//  CreatePlaylistResponse.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/14/24.
//

import Foundation

struct CreatePlaylistResponse: Codable {
    let id: String
    let externalUrls: ExternalUrls
    
    struct ExternalUrls: Codable {
        let spotify: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case externalUrls = "external_urls"
    }
}
