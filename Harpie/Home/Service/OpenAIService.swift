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
    func getPlaylistFromFunction(for value: String) async throws -> (PlaylistResponse, String) {
        let (response, responseString) = try await APIService.request(
            endpoint: "brain/getPlaylist",
            method: "GET",
            queryParameters: ["value": value],
            responseType: PlaylistResponse.self,
            includeResponseString: true
        )
        
        if let json = responseString {
            return (response, json)
        } else {
            throw APIError.openAI(.invalidResponse)
        }
    }
    
    struct RequestBody: Codable {
        let value: String
        let history: [ChatQuery.ChatCompletionMessageParam]
    }
    
    func getMoreFromFunction(for value: String, history: [ChatQuery.ChatCompletionMessageParam]) async throws -> (PlaylistResponse, String) {
        let requestBody = RequestBody(value: value, history: history)
        let (response, responseString) = try await APIService.request(
            endpoint: "brain/getMore",
            method: "POST",
            body: requestBody,
            responseType: PlaylistResponse.self,
            includeResponseString: true
        )
        
        if let json = responseString {
            return (response, json)
        } else {
            throw APIError.openAI(.invalidResponse)
        }
    }
}
