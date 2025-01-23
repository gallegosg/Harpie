//
//  OpenAIError.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/28/24.
//

import Foundation

enum OpenAIError: Error {
    case invalidResponse
    case noResults
    case serverError
    
    var errorMessage: String {
        switch self {
        case .invalidResponse:
            return "Invalid response."
        case .noResults:
            return "No results were returned."
        case .serverError:
            return "An error occurred on the server."
        }
    }
}
