//
//  OpenAIService.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/9/24.
//

import Foundation
import OpenAI

struct OpenAIService {
    let openAI = OpenAI(apiToken: Config.apiKey)
    
    func getPlaylist(for value: String) async throws -> (PlaylistResponse, String) {
        do {
            let query = ChatQuery(messages: [
                .init(role: .system, content: Config.prompt)!,
                .init(role: .user, content: value)!
            ], model: .gpt4_o_mini, maxTokens: 300 )
            
            let result = try await openAI.chats(query: query)
            
            if let first = result.choices.first {
                if let responseString = first.message.content?.string, let cleanedData = responseString.data(using: .utf8) {
                        let playlistResponse = try JSONDecoder().decode(PlaylistResponse.self, from: cleanedData)
                        return (playlistResponse, responseString)
                    } else {
                        throw OpenAIError.invalidResponse
                    }
            } else {
                throw OpenAIError.noResults
            }
        } catch {
            print(error)
            throw OpenAIError.serverError
        }
    }
    
    func getMore(for value: String, times: Int, history: [ChatQuery.ChatCompletionMessageParam]) async throws -> (PlaylistResponse, String) {

        let messages = [
            .init(role: .system, content: Config.prompt)!,
            .init(role: .user, content: value)!
        ] + history
        
        do {
            let query = ChatQuery(messages: messages, model: .gpt4_o_mini, maxTokens: 300 )
            
            let result = try await openAI.chats(query: query)
            
            if let first = result.choices.first {
                if let responseString = first.message.content?.string, let cleanedData = responseString.data(using: .utf8) {
                        let playlistResponse = try JSONDecoder().decode(PlaylistResponse.self, from: cleanedData)
                    return (playlistResponse, responseString)
                    } else {
                        throw OpenAIError.invalidResponse
                    }
            } else {
                throw OpenAIError.noResults
            }
        } catch {
            print(error)
            throw OpenAIError.serverError
        }
    }
}
