//
//  OpenAIService.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/9/24.
//

import Foundation
import OpenAI
import Alamofire


struct OpenAIService {
//    let openAI = OpenAI(apiToken: Config.apiKey)
    
    func getPlaylistFromFunction(for value: String) async throws -> (PlaylistResponse, String) {
        let urlString = "\(Config.apiUrl)brain/getPlaylist?value=\(value)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        do {
            let token = try await FirebaseService.shared.validateAppCheckToken()

            guard !token.isEmpty else {
                print("App Check token is empty")
                throw OpenAIError.invalidResponse // TODO: Firebase error
            }

            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            // Perform the request
            return try await sendRequest(request: request)
        } catch let error as OpenAIError {
            print(error)
            throw error
        } catch {
            print(error)
            throw OpenAIError.invalidResponse
        }
    }
    
    func sendRequest(request: URLRequest) async throws -> (PlaylistResponse, String) {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // Validate response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            if (200...299).contains(httpResponse.statusCode) {
                // Success, convert response to string
                guard let jsonString = String(data: data, encoding: .utf8) else {
                    throw URLError(.cannotParseResponse)
                }

                let playlistResponse = try JSONDecoder().decode(PlaylistResponse.self, from: data)
                return (playlistResponse, jsonString)
            } else {
                // Extract API error message if available
                if let apiError = try? JSONDecoder().decode(NodeAPIError.self, from: data) {
                    throw OpenAIError.apiError(apiError.error)
                } else {
                    throw OpenAIError.apiError("Unknown error")
                }
            }
        } catch {
            throw error
        }
    }
    
    struct RequestBody: Codable {
        let value: String
        let history: [ChatQuery.ChatCompletionMessageParam]
    }
    
    func getMoreFromFunction(for value: String, history: [ChatQuery.ChatCompletionMessageParam]) async throws -> (PlaylistResponse, String) {
        // Stringify history
        let jsonEncoder = JSONEncoder()
        
        let urlString = Config.apiUrl + "brain/getMore"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        do {
            let token = try await FirebaseService.shared.validateAppCheckToken()
            
            guard !token.isEmpty else {
                print("App Check token is empty")
                throw OpenAIError.invalidResponse //TODO: firebase error
            }
            
            // Create the request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let requestBody = RequestBody(value: value, history: history)
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            return try await sendRequest(request: request)
        } catch {
            print(error)
            throw error
        }
    }
    
//    func getPlaylist(for value: String) async throws -> (PlaylistResponse, String) {
//        do {
//            let query = ChatQuery(messages: [
//                .init(role: .system, content: Config.prompt)!,
//                .init(role: .user, content: value)!
//            ], model: .gpt4_o_mini, maxTokens: 300 )
//            
//            let result = try await openAI.chats(query: query)
//            
//            if let first = result.choices.first {
//                if let responseString = first.message.content?.string, let cleanedData = responseString.data(using: .utf8) {
//                    let playlistResponse = try JSONDecoder().decode(PlaylistResponse.self, from: cleanedData)
//                    return (playlistResponse, responseString)
//                } else {
//                    throw OpenAIError.invalidResponse
//                }
//            } else {
//                throw OpenAIError.noResults
//            }
//        } catch {
//            throw OpenAIError.serverError
//        }
//    }
//    
//    func getMore(for value: String, times: Int, history: [ChatQuery.ChatCompletionMessageParam]) async throws -> (PlaylistResponse, String) {
//
//        let messages = [
//            .init(role: .system, content: Config.prompt)!,
//            .init(role: .user, content: value)!
//        ] + history
//        
//        do {
//            let query = ChatQuery(messages: messages, model: .gpt4_o_mini, maxTokens: 300 )
//            
//            let result = try await openAI.chats(query: query)
//            
//            if let first = result.choices.first {
//                if let responseString = first.message.content?.string, let cleanedData = responseString.data(using: .utf8) {
//                        let playlistResponse = try JSONDecoder().decode(PlaylistResponse.self, from: cleanedData)
//                    return (playlistResponse, responseString)
//                    } else {
//                        throw OpenAIError.invalidResponse
//                    }
//            } else {
//                throw OpenAIError.noResults
//            }
//        } catch {
//            print(error)
//            throw OpenAIError.serverError
//        }
//    }
}
