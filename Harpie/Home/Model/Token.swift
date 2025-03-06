//
//  Token.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/13/24.
//

import Foundation

struct Token: Codable {
    let scope: String
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case scope
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}
