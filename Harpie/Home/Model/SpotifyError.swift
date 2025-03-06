//
//  SpotifyError.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/27/24.
//

import Foundation

enum SpotifyError: Error {
    case failedAppToken
    case failedAuthentication
    case failedAccessToken
    case failedRefreshToken
    case failedUserDetails
    case failedCreatePlaylist
    case failedAddToPlaylist
    case failedValidateTrack
    case userCancelledAuthentication
    case apiError(String)
    
    var errorMessage: String {
        switch self {
        case .failedAppToken: return "Failed to obtain app token."
        case .failedAuthentication: return "Could not sign in to Spotify. Please try again."
        case .failedAccessToken: return "Failed to obtain access token."
        case .failedRefreshToken: return "Failed to refresh access token."
        case .failedUserDetails: return "Failed to obtain user details."
        case .failedCreatePlaylist: return "Failed to create playlist."
        case .failedAddToPlaylist: return "Failed to add track to playlist."
        case .failedValidateTrack: return "Failed to validate track."
        case .userCancelledAuthentication: return "User cancelled authentication."
        case .apiError(let message):
            return message
        }
    }
}
