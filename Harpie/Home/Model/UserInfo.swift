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
    var country: String
    var displayName: String
    var email: String
    var href: String
    var profileImage: String?
    var product: String
    var type: String
    var uri: String

    init(id: String, country: String, displayName: String, email: String, href: String, profileImage: String? = nil, product: String, type: String, uri: String) {
        self.id = id
        self.country = country
        self.displayName = displayName
        self.email = email
        self.href = href
        self.profileImage = profileImage
        self.product = product
        self.type = type
        self.uri = uri
    }
}
