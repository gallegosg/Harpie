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
    private let playlistManager = PlaylistLimitManager()

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
    @Published var warningText: String? = ""
    @Published var showLimitReached: Bool = false
    
    @Published var isLoading: Bool = false {
        didSet{
            updateRemainingCount()
        }
    }
    
    @Published var moreLoading: Bool = false
    @Published var spotifyLoading: Bool = false
    
    @Published var playlist: [Song] = [] //PlaylistResponse.dummy.playlist
    @Published var message: String = "" //PlaylistResponse.dummy.message
    @Published var moreCount: Int = 0
    private var playlistStringArray: [ChatQuery.ChatCompletionMessageParam] = []
    @Published var isShowingError: Bool = false
    @Published var shouldScatter: Bool = false
    
    @Published var spotifyExtUrl: String = "" {
        didSet {
            if !spotifyExtUrl.isEmpty {
                isPlaylistReady = true
            }
        }
    }
    
    @Published var remainingCount: Int = 0
    
    @Published var isPlaylistReady: Bool = false
    
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
        updateRemainingCount()
        updateIsUserLoggedIn()        
    }
    
    func testFunctions() async {
        do {
            let _ = try await service.getPlaylistFromFunction(for: "country")
        } catch {
            print(error)
        }
    }
    func fetchAIList() async throws -> (PlaylistResponse, String) {
        error = nil
        do {
            let (response, playlistString) = try await service.getPlaylistFromFunction(for: searchText)
            
            return (response, playlistString)
        } catch {
            throw error
        }
    }
    
    func validSearchText() -> Bool {
        // if invalid search text, show warning
        let trimmedString = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedString.isEmpty {
            warningText = "Please enter something to search"
            return false
        }
        warningText = ""
        return true
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
            let (response, playlistString) = try await service.getMoreFromFunction(for: searchText, history: playlistStringArray)
            
            let duplicateFree = handleDuplicates(for: playlist + response.playlist)
            playlist = duplicateFree
            
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
        spotifyExtUrl = ""
        warningText = ""
    }
    
    func testLogs() async {
        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Test decoding  from fake error"))
        let error = APIError.decodingError(decodingError)

        await ErrorLogger.logAPIError(
            error,
            userId: "n/a",
            context: ["endpoint": "test/logs", "responseString": "status ok", "error": decodingError.localizedDescription]
        )
    }
    
    func handleGenerateButton() async {
        if !playlistManager.canCreatePlaylist() {
            showLimitReached = true
            return
        }
        
        enableLoading()
        error = nil
        defer {
            shouldScatter = true
            isLoading = false
        }
        
        do {
            
            if !validSearchText() {
                return
            }
            
            // 1. hit openai
            let (response, playlistString) = try await fetchAIList()
            playlist = response.playlist
            
            message = response.message.isEmpty ? searchText.capitalized : response.message

            playlistStringArray.append(ChatQuery.ChatCompletionMessageParam(role: .user, content: playlistString)!)
            playlistManager.recordPlaylistCreation()

        } catch let error as APIError {
            print("generate new error", error)
            self.error = error.localizedDescription
        } catch let error as SpotifyError {
            self.error = error.errorMessage
        } catch let error as OpenAIError{
            self.error = error.errorMessage
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func handleAddToSpotifyButton() async {
        do {
            spotifyLoading = true
            defer { spotifyLoading = false }
            
            let songList: [Song] = playlist.filter { $0.checked }
            guard let userService = userService else { fatalError("UserService not injected") }
            if isUserLoggedIn, let refreshToken = auth.retrieveRefreshToken(), let user = userService.fetchUserInfo() {
                //get refresh token
                let playlistResponse = try await spotifyService.createPlaylistAuth(refreshToken: refreshToken, playlistName: searchText.capitalized, userId: user.id, songList: songList)
                
                spotifyExtUrl = playlistResponse.externalUrls.spotify
            } else {
                //get code from web login
                let code = try await spotifyService.authenticateSpotifyUser()
                
                //get token from spotify with code
                let (token, user) = try await spotifyService.getUserDetailsFromCode(code: code)
                
                //convert to user type
                let userInfo = userService.convertUserResponseToUserInfo(user)
                userService.saveUserInfo(userInfo)
                
                guard let refreshToken = token.refreshToken else {
                    fatalError("refresh token not found")
                }
                let _ = auth.saveRefreshToken(refreshToken)
                
                //create playlist with refresh token
                let playlistResponse = try await spotifyService.createPlaylistAuth(refreshToken: refreshToken, playlistName: searchText.capitalized, userId: user.id, songList: songList)

                spotifyExtUrl = playlistResponse.externalUrls.spotify
            }
            updateIsUserLoggedIn()
        } catch APIError.spotify(.invalidGrant) {
            self.error = APIError.spotify(.invalidGrant).localizedDescription
            handleLogoutButton()
        } catch let error as APIError {
            print("new api error")
            self.error = error.localizedDescription
        } catch let error as SpotifyError {
            switch error {
            case .userCancelledAuthentication:
                return
            default:
                self.error = error.errorMessage
            }
        }  catch {
            print("generic error")
            print(error)
        }
    }
    
    func handleLogoutButton() {
        guard let userService = userService else { fatalError("UserService not injected") }

        userService.deleteUserInfo()
        let _ = auth.deleteRefreshToken()
        updateIsUserLoggedIn()
    }
    
    func handleSendToSpotify() {
        guard let url = URL(string: spotifyExtUrl) else {
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
    
    func disableLoading() {
        isLoading = false
    }
    
    func updateIsUserLoggedIn() {
        guard let userService = userService else { fatalError("UserService not injected") }
        if auth.checkIfLoggedIn(), userService.isUserLoggedIn() {
            isUserLoggedIn = true
        } else {
            isUserLoggedIn = false
        }
    }
    
    func updateRemainingCount() {
        remainingCount = playlistManager.getRemainingCount()
    }
    
}
