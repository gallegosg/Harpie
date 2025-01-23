//
//  HomeViewModel.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/9/24.
//

import Foundation
import OpenAI
import SwiftData
import UIKit

@MainActor
class HomeViewModel: ObservableObject {
    private let service: OpenAIService
    private let spotifyService: SpotifyService
    var userService: UserService?
    
    private let auth: Auth
    @Published var isInitialized: Bool = false
    @Published var searchText: String = ""

    @Published var error: String? {
        didSet {
            if error != nil {
                isShowingError = true
            }
        }
    }
    @Published var isLoading: Bool = false
    
    @Published var moreLoading: Bool = false
    @Published var playlist: [Song] = [] //PlaylistResponse.dummy.playlist
    @Published var message: String = "" //PlaylistResponse.dummy.message
    @Published var moreCount: Int = 0
    private var playlistStringArray: [ChatQuery.ChatCompletionMessageParam] = []
    @Published var isShowingError: Bool = false
    
    @Published var accessToken: String = ""
    
    @Published var isUserLoggedIn: Bool = false
    
    init(service: OpenAIService, spotifyService: SpotifyService, auth: Auth, userService: UserService?){
        self.service = service
        self.spotifyService = spotifyService
        self.auth = auth
        self.userService = userService
        
    }
    
    func initialize() {
        isInitialized = true

        updateIsUserLoggedIn()
    }
    
    func fetchAIList() async throws -> (PlaylistResponse, String) {
        error = nil
        do {
//            throw SpotifyError.failedAccessToken
            let (response, playlistString) = try await service.getPlaylist(for: searchText)
            return (response, playlistString)
        } catch {
            throw error
        }
    }
    
    func handleMore() {
        moreCount += 1
        playlistStringArray.append(ChatQuery.ChatCompletionMessageParam(role: .user, content: "more")!)
        Task {
            await fetchMore()
        }
    }
    
    func fetchMore() async {
        error = nil
        moreLoading = true
        defer { moreLoading = false }
        do {
            let (response, playlistString) = try await service.getMore(for: searchText, times: moreCount, history: playlistStringArray)
            
            //TODO: get playlistString and append to playlistStringArray
            playlist = playlist + response.playlist
            playlistStringArray.append(ChatQuery.ChatCompletionMessageParam(role: .user, content: playlistString)!)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func handleDuplicates(for list: [Song]) -> [Song] {
        var set = Set<(String)>()
        var newList: [Song] = []
        for song in list {
            let key = "\(song.title) - \(song.artist)"
            if !set.contains(key) {
                newList.append(song)
                set.insert(key)
            }
        }
        return newList
    }
    
    func reset() {
        searchText = ""
        error = nil
        playlist = []
        message = ""
        moreCount = 0
    }
    
    func handleGenerateButton() async {
        enableLoading()
        error = nil
        defer { isLoading = false }

        do {
            // 1. hit openai
            print("hit openai")
            let (response, playlistString) = try await fetchAIList()
            print("openai finished")
            // 2. check duplicates
            let newPlaylist = handleDuplicates(for: response.playlist)
            
            // 3. validate w/ spotify
            // 3.a get token
            await getSpotifyAppToken()
            var validatedPlaylist: [Song] = []
            
            for x in newPlaylist {
                let songId = try await spotifyService.validateSpotifyTrack(track: x.title, artist: x.artist, accessToken: accessToken)
                if !songId.isEmpty {
                    var tempSong = x
                    tempSong.spotifyId = songId
                    validatedPlaylist.append(tempSong)
                }
            }
            // 4. display
            playlist = validatedPlaylist
            message = response.message

            playlistStringArray.append(ChatQuery.ChatCompletionMessageParam(role: .user, content: playlistString)!)
        } catch let error as SpotifyError {
            self.error = error.errorMessage
            print(error)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func handleAddToSpotifyButton() async {
        do {
            guard let userService = userService else { fatalError("UserService not injected") }
            if isUserLoggedIn {
                //get refresh token
                if let refreshToken = auth.retrieveRefreshToken(), let user = userService.fetchUserInfo() {
                    //get accesstoken
                    let accessToken = try await spotifyService.getAccessTokenFromRefreshToken(refreshToken)
                    // create playlist
                    let playlistResponse = try await spotifyService.createPlaylist(accessToken: accessToken, playlistName: searchText.capitalized, userId: user.id)
                    //add songs to playlist
                    try await spotifyService.addSongToPlaylist(playlistId: playlistResponse.id, songList: playlist, accessToken: accessToken)
                    
                    handleSendToSpotify(playlistURL: playlistResponse.externalUrls.spotify)
                }
            } else {
                let (accessToken, user) = try await spotifyService.authenticateAndFetchSpotifyUser()
                //save user
                let userInfo = userService.convertUserResponseToUserInfo(user)
                userService.saveUserInfo(userInfo)
                // create playlist
                let playlistResponse = try await spotifyService.createPlaylist(accessToken: accessToken, playlistName: searchText.capitalized, userId: user.id)
                
                //add songs to playlist
                let songList: [Song] = playlist.filter { $0.checked }
                try await spotifyService.addSongToPlaylist(playlistId: playlistResponse.id, songList: songList, accessToken: accessToken)
                
                handleSendToSpotify(playlistURL: playlistResponse.externalUrls.spotify)
            }
            updateIsUserLoggedIn()
        } catch let error as SpotifyError {
            self.error = error.errorMessage
        }  catch {
            print(error)
        }
    }

    func getSpotifyAppToken() async {
        do {
            let token = try await spotifyService.fetchSpotifyAppToken()
            accessToken = token
        } catch {
            print(error)
        }
    }
    
    func handleLogoutButton() {
        guard let userService = userService else { fatalError("UserService not injected") }

        userService.deleteUserInfo()
        let _ = auth.deleteRefreshToken()
        updateIsUserLoggedIn()
    }
    
    func handleSendToSpotify(playlistURL: String) {
        guard let url = URL(string: playlistURL) else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    func enableLoading() {
        isLoading = true
    }
    
    func updateIsUserLoggedIn() {
        guard let userService = userService else { fatalError("UserService not injected") }
        let dailyCount = userService.getDailyLimitCount()
        print("DAILY COUNT: \(dailyCount)")
        if auth.checkIfLoggedIn(), userService.isUserLoggedIn() {
            isUserLoggedIn = true
        } else {
            isUserLoggedIn = false
        }
    }
}
