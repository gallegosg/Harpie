//
//  ErrorLogger.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 3/5/25.
//

import Foundation

struct ErrorRequestBody: Codable {
    let userId: String
    let source: String
    let code: String
    let message: String
    let context: [String: String]
    let file: String
    let line: Int
}

struct ErrorLogger {
    static func logError(
        userId: String,
        source: String,
        code: String,
        message: String,
        context: [String: String] = [:],
        file: String = #file,
        line: Int = #line
    ) async {
        do {
            print("hit second function")
            let requestBody = ErrorRequestBody(userId: userId, source: source, code: code, message: message, context: context, file: file, line: line)
            print("made body", requestBody)
            let _ = try await APIService.request(
                endpoint: "log/error",
                method: "POST",
                body: requestBody,
                responseType: [String: String].self
            )
            
            print("Error logged to Firestore: \(message)")
        } catch {
            print("Failed to log error to Firestore: \(error.localizedDescription)")
        }
    }
    
    // Convenience for APIError
    static func logAPIError(
        _ apiError: APIError,
        userId: String,
        context: [String: String] = [:],
        file: String = #file,
        line: Int = #line
    ) async {
        print("hit first fucntion")
        let (source, code) = extractSourceAndCode(from: apiError)
        print("exxtract code and source", source, code)
        await logError(
            userId: userId,
            source: source,
            code: code,
            message: apiError.localizedDescription,
            context: context,
            file: file,
            line: line
        )
    }
    
    private static func extractSourceAndCode(from apiError: APIError) -> (source: String, code: String) {
        switch apiError {
        case .networkError:
            return ("client", "network_error")
        case .invalidResponse:
            return ("client", "invalid_response")
        case .decodingError:
            return ("client", "decoding_error")
        case .node(let message):
            return ("node", message) // Uses message as code for simplicity
        case .spotify:
            return ("spotify", "spotify_error")
        case .openAI:
            return ("openai", "openai_error")
        }
    }
}
