//
//  SpotifyService.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/13/24.
//

import Foundation
import Alamofire
import UIKit
import AuthenticationServices

@MainActor
class SpotifyService: NSObject, ASWebAuthenticationPresentationContextProviding {
    let auth = Auth()
    
    func fetchSpotifyAppToken() async throws -> String{
        // Define the URL for Spotify's token API
            let url = "https://accounts.spotify.com/api/token"
            
            // Prepare the parameters for the POST request
            let parameters: [String: String] = [
                "grant_type": "client_credentials",
                "client_id": Config.clientID,
                "client_secret": Config.clientSecret
            ]
            
            // Make the POST request using Alamofire with async/await
            let headers: HTTPHeaders = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            do {
                let response = try await AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
                    .validate()
                    .serializingDecodable(Token.self)
                    .value
                
                // Return the access token
                return response.accessToken
            } catch {
                // Handle errors
                print("get acess token error", error)
                throw error
            }
    }
    
    
    private func generateRandomString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
    
    func authenticateAndFetchSpotifyUser() async throws -> (String, UserResponse) {
        do {
            let state = generateRandomString(length: 16)
            let redirectURI = Config.redirectURI
            let scope = "user-read-private user-read-email playlist-modify-private playlist-modify-public"
            let authURL = URL(string: "https://accounts.spotify.com/authorize?response_type=code&client_id=\(Config.clientID)&redirect_uri=\(redirectURI)&scope=\(scope)&state=\(state)")!
            let callbackURLScheme = "harpie"
            
            let authorizationCode = try await authenticateWithSpotify(authURL: authURL, callbackURLScheme: callbackURLScheme)
            let accessToken = try await getAccessToken(code: authorizationCode)
            let userDetails = try await getUserDetails(accessToken: accessToken)
            
            return (accessToken, userDetails)
        } catch {
            print("Authentication or data fetching failed: \(error)")
            throw error
        }
    }
    
    func authenticateWithSpotify(authURL: URL, callbackURLScheme: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            var components = URLComponents(url: authURL, resolvingAgainstBaseURL: false)
            components?.queryItems?.append(URLQueryItem(name: "show_dialog", value: "true"))
            
            guard let updatedAuthURL = components?.url else {
                continuation.resume(throwing: URLError(.badURL))
                return
            }
            let session = ASWebAuthenticationSession(url: updatedAuthURL, callbackURLScheme: callbackURLScheme) { callbackURL, error in
                if let callbackURL = callbackURL {
                    let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
                    if let code = queryItems?.first(where: { $0.name == "code" })?.value {
                        continuation.resume(returning: code)
                    } else {
                        continuation.resume(throwing: URLError(.badServerResponse))
                    }
                } else if let error = error {
                    continuation.resume(throwing: error)
                }
            }
            session.presentationContextProvider = self // Set your context
            session.start()
        }
    }
    
    // get accesstoken from login
    func getAccessToken(code: String) async throws -> String {
        let url = "https://accounts.spotify.com/api/token"
        
        // Prepare the parameters for the POST request
        let parameters: [String: String] = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": Config.redirectURI,
        ]
        
        // Make the POST request using Alamofire with async/await
        let headers: HTTPHeaders = [
            "Authorization": "Basic " + stringToBase64(string: "\(Config.clientID):\(Config.clientSecret)"),
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        do {
            let response = try await AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
                .validate()
                .serializingDecodable(Token.self)
                .value
            
            guard let refreshToken = response.refreshToken else {
                fatalError("No refresh token")
            }
            let result = auth.saveRefreshToken(refreshToken)
            print("refreshtoken saveed: \(result)")
            // Return the access token
            return response.accessToken
        } catch {
            // Handle errors
            print("get acess token error", error)
            throw error
        }
    }
    
    func getUserDetails(accessToken: String) async throws -> UserResponse {
        let url = "https://api.spotify.com/v1/me"

        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken,
        ]
        
        do {
            let response = try await AF.request(url, method: .get, encoding: URLEncoding.default, headers: headers)
                .validate()
                .serializingDecodable(UserResponse.self)
                .value
            
            return response
        } catch {
            print("get USER DETAILS ERROR", error)
            throw error
        }
    }
    
    func createPlaylist(accessToken: String, playlistName: String, userId: String) async throws -> CreatePlaylistResponse {
        let url = "https://api.spotify.com/v1/users/\(userId)/playlists"
        let body: [String: String] = [
            "name": playlistName,
            "description": "Created with Harpie",
            "public": "false"
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
        
        do {
            let response = try await AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .serializingDecodable(CreatePlaylistResponse.self)
                .value
            
            return response            
        } catch {
            print("create PLAYLIST ERROR", error)
            throw error
        }
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Access the active window scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return UIWindow()
        }
        return keyWindow
    }
    
    func stringToBase64(string: String) -> String {
        if let data = string.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return ""
    }
    
    func validateSpotifyTrack(track: String, artist: String, accessToken: String) async throws -> String {
        let url = "https://api.spotify.com/v1/search"
        
        let parameters: [String: String] = [
            "q": "track:\"\(track)\" artist:\"\(artist)\"",
            "limit": "1",
            "type": "track"
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken,
        ]
        
        do {
            let response = try await AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
                .validate()
                .serializingDecodable(SpotifyTrackResponse.self)
                .value
            
            return !response.tracks.items.isEmpty ? response.tracks.items[0].id : ""
        } catch {
            print("validate spotify track \(track) failed: ", error)
            throw error
        }
    }
    
    func getAccessTokenFromRefreshToken(_ refreshToken: String) async throws -> String {
        let url = "https://accounts.spotify.com/api/token"
        // Prepare the parameters for the POST request
        let body: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": Config.clientID
        ]
        
        // Make the POST request using Alamofire with async/await
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic " + stringToBase64(string: "\(Config.clientID):\(Config.clientSecret)")
        ]
        do {
            let response = try await AF.request(url, method: .post, parameters: body, encoding: URLEncoding.default, headers: headers)
                .validate()
                .serializingDecodable(Token.self)
                .value

            // Return the access token
            return response.accessToken
        } catch {
            // Handle errors
            print("get access token from refresh token error", error)
            throw error
        }
    }
    
    func addSongToPlaylist(playlistId: String, songList: [Song], accessToken: String) async throws {
        let url = "https://api.spotify.com/v1/playlists/\(playlistId)/tracks"
        var songUris: [String] = []
        
        for song in songList {
            songUris.append("spotify:track:\(song.spotifyId!)")
        }
        
        // Prepare the parameters for the POST request
        let body: [String: [String]] = [
            "uris": songUris,
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken,
            "Content-Type": "application/json"

        ]
        
        do {
            let _ = try await AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200...201) // Include 201 explicitly
                .serializingData() // Use an Alamofire serializer
                .value

        } catch {
            // Handle errors
            print("add to playlist error", error)
            throw error
        }
    }
}

