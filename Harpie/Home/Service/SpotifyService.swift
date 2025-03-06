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
    
    private func generateRandomString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
    
    func authenticateSpotifyUser() async throws -> String {
        do {
            let state = generateRandomString(length: 16)
            let redirectURI = Config.redirectURI
            let scope = "playlist-modify-private playlist-modify-public"
            let authURL = URL(string: "https://accounts.spotify.com/authorize?response_type=code&client_id=\(Config.clientID)&redirect_uri=\(redirectURI)&scope=\(scope)&state=\(state)")!
            let callbackURLScheme = "harpie"
            
            let authorizationCode = try await authenticateWithSpotify(authURL: authURL, callbackURLScheme: callbackURLScheme)
            
            return authorizationCode
        } catch let error as SpotifyError {
            switch error {
            case .userCancelledAuthentication:
                throw error
            default:
                throw SpotifyError.failedAuthentication
            }
        } catch {
            print("Authentication or data fetching failed: \(error)")
            throw SpotifyError.failedAuthentication
        }
    }
    
    struct UserDetailResponse: Decodable {
        let user: UserResponse
        let token: Token
    }
    
    func getUserDetailsFromCode(code: String) async throws -> (Token, UserResponse) {
        let (response, _) = try await APIService.request(
            endpoint: "spotify/getUserFromAuthCode",
            queryParameters: ["code": code],
            responseType: UserDetailResponse.self
        )
        return (response.token, response.user)
    }
    
//    func getUserDetailsFromCode(code: String) async throws -> (Token, UserResponse) {
//        do {
//            
//            let response = try await APIService.request(
//                endpoint: "spotify/getUserFromAuthCode",
//                queryParameters: ["code": code],
//                responseType: UserDetailResponse.self
//            )
//            
//            guard let refreshToken = response.token.refreshToken else {
//                fatalError("No refresh token")
//            }
//            let result = auth.saveRefreshToken(refreshToken)
//            
//            // Return the access token
//            return (response.token, response.user)
//        } catch let error as NodeAPIError {
//            print("fucntion node error", error)
//            throw SpotifyError.apiError(error.errorMessage)
//        } catch {
//            print("function generic error", error)
//            throw OpenAIError.invalidResponse
//        }
//    }
    
    func authenticateWithSpotify(authURL: URL, callbackURLScheme: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            var components = URLComponents(url: authURL, resolvingAgainstBaseURL: false)
            components?.queryItems?.append(URLQueryItem(name: "show_dialog", value: "true"))
            
            guard let updatedAuthURL = components?.url else {
                continuation.resume(throwing: URLError(.badURL))
                return
            }
            let session = ASWebAuthenticationSession(url: updatedAuthURL, callbackURLScheme: callbackURLScheme) { callbackURL, error in
                if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                    continuation.resume(throwing: SpotifyError.userCancelledAuthentication)
                    return
                }
                if let callbackURL = callbackURL {
                    let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
                    if let code = queryItems?.first(where: { $0.name == "code" })?.value {
                        continuation.resume(returning: code)
                    } else {
                        continuation.resume(throwing: URLError(.badServerResponse))
                    }
                } else if let error = error {
                    print(error)
                    continuation.resume(throwing: error)
                }
            }
            session.presentationContextProvider = self // Set your context
            session.start()
        }
    }
//    
//    func getUserDetails(accessToken: String) async throws -> UserResponse {
//        let url = "https://api.spotify.com/v1/me"
//
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer " + accessToken,
//        ]
//        
//        do {
//            let response = try await AF.request(url, method: .get, encoding: URLEncoding.default, headers: headers)
//                .validate()
//                .serializingDecodable(UserResponse.self)
//                .value
//            
//            return response
//        } catch {
//            print("get USER DETAILS ERROR", error)
//            throw SpotifyError.failedUserDetails
//        }
//    }
    
//    func createPlaylist(accessToken: String, playlistName: String, userId: String) async throws -> CreatePlaylistResponse {
//        let url = "https://api.spotify.com/v1/users/\(userId)/playlists"
//        let body: [String: String] = [
//            "name": playlistName,
//            "description": "Created with Harpie",
//            "public": "false"
//        ]
//        
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(accessToken)",
//            "Content-Type": "application/json"
//        ]
//        
//        do {
//            let response = try await AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
//                .validate()
//                .serializingDecodable(CreatePlaylistResponse.self)
//                .value
//            
//            return response            
//        } catch {
//            print("create PLAYLIST ERROR", error)
//            throw SpotifyError.failedCreatePlaylist
//        }
//    }
    
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
    
//    func validateSpotifyTrack(track: String, artist: String, accessToken: String) async throws -> String {
//        let url = "https://api.spotify.com/v1/search"
//        
//        let parameters: [String: String] = [
//            "q": "track:\"\(track)\" artist:\"\(artist)\"",
//            "limit": "1",
//            "type": "track"
//        ]
//        
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer " + accessToken,
//        ]
//        
//        do {
//            let response = try await AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
//                .validate()
//                .serializingDecodable(SpotifyTrackResponse.self)
//                .value
//            
//            return !response.tracks.items.isEmpty ? response.tracks.items[0].id : ""
//        } catch {
//            print("validate spotify track \(track) failed: ", error)
//            throw SpotifyError.failedValidateTrack
//        }
//    }
    
    struct CreatePlaylistRequest: Codable {
        let refreshToken: String
        let playlistName: String
        let userId: String
        let songList: [Song]
    }
    
    func createPlaylistAuth(refreshToken: String, playlistName: String, userId: String, songList: [Song]) async throws -> CreatePlaylistResponse {
        let requestBody = CreatePlaylistRequest(refreshToken: refreshToken, playlistName: playlistName, userId: userId, songList: songList)
        let (response, _) =  try await APIService.request(
            endpoint: "spotify/createPlaylistAuth",
            method: "POST",
            body: requestBody,
            responseType: CreatePlaylistResponse.self
        )
        
        return response
    }
//    
//    func addSongToPlaylist(playlistId: String, songList: [Song], accessToken: String) async throws {
//        let url = "https://api.spotify.com/v1/playlists/\(playlistId)/tracks"
//        var songUris: [String] = []
//        
//        for song in songList {
//            songUris.append("spotify:track:\(song.spotifyId!)")
//        }
//        
//        // Prepare the parameters for the POST request
//        let body: [String: [String]] = [
//            "uris": songUris,
//        ]
//        
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer " + accessToken,
//            "Content-Type": "application/json"
//
//        ]
//        
//        do {
//            let _ = try await AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers)
//                .validate(statusCode: 200...201) // Include 201 explicitly
//                .serializingData() // Use an Alamofire serializer
//                .value
//
//        } catch {
//            // Handle errors
//            print("add to playlist error", error)
//            throw SpotifyError.failedAddToPlaylist
//        }
//    }
}

