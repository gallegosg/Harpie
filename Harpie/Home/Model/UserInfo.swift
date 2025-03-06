//
//  UserInfo.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/13/24.
//

import SwiftData

@Model
class UserInfo {
    @Attribute(.unique) var id: String
    var displayName: String
    var href: String
    var profileImage: String?
    var type: String
    var uri: String

    init(id: String, displayName: String, href: String, profileImage: String? = nil, type: String, uri: String) {
        self.id = id
        self.displayName = displayName
        self.href = href
        self.profileImage = profileImage
        self.type = type
        self.uri = uri
    }
}
