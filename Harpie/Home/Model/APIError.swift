//
//  NodeAPIError.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 2/15/25.
//

import Foundation

import Foundation

enum APIError: Error {
    // Generic cases
    case networkError(Error) // Underlying URLSession errors
    case invalidResponse
    case decodingError(Error)
    
    // Source-specific cases with associated values
    case node(String) // Generic Node API error
    case spotify(SpotifyErrorCode)
    case openAI(OpenAIErrorCode) // Keep for potential future use
    
    // Computed property for user-friendly message
    var localizedDescription: String {
        switch self {
        case .networkError(let error):
            return "Network issue: \(error.localizedDescription)"
        case .invalidResponse:
            return "Something went wrong. Try again later."
        case .decodingError:
            return "Failed to process the response. Try again later."
        case .node(let message):
            return message
        case .spotify(let code):
            return code.message
        case .openAI(let code):
            return code.message
        }
    }
}

//MARK: - Spotify specific codes
enum SpotifyErrorCode {
    case invalidGrant
    case invalidClient
    case invalidToken
    case userError
    case rateLimitExceeded
    case failedCreatePlaylist
    case custom(String)
    
    var message: String {
        switch self {
        case .invalidGrant: return "We couln't refresh your session. Please try again to sign in."
        case .invalidClient: return "Spotify configuration error. Contact support."
        case .invalidToken: return "Spotify authorization token expired. Please reconnect."
        case .userError: return "User error occurred. Please try again."
        case .rateLimitExceeded: return "Too many requests to Spotify. Try again soon."
        case .failedCreatePlaylist : return "Failed to create playlist. Please try again."
        case .custom(let msg): return msg
        }
    }
}

//MARK: - OpenAI-specific error codes (if still relevant)
enum OpenAIErrorCode {
    case invalidResponse
    case invalidJson
    case rateLimit
    case noResults
    case custom(String)
    
    var message: String {
        switch self {
        case .invalidResponse: return "Invalid response from the server. Please try again"
        case .invalidJson: return "Invalid response from the server. Please try again"
        case .rateLimit: return "Server request limit reached. Try again later."
        case .noResults: return "Sorry, we coulnt't find music for that. Try something else."
        case .custom(let msg): return msg
        }
    }
}
