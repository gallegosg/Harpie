//
//  SongView.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/10/24.
//

import SwiftUI

struct SongView: View {
    @StateObject var homeVM: HomeViewModel

    @Binding var song: Song
    @State var showMenu: Bool = false
    @State var hasFetchedPreview = false
    @State var songPreviewUrl: String? = nil
    @State var isLoading: Bool = false

    var body: some View {
        HStack {
            Button(action: {
                if let songId = homeVM.currentlyPlayingSongId, songId == song.id {
                    homeVM.stopPreview()
                } else if song.songPreviewUrl != nil {
                    showMenu = true
                } else if song.songPreviewUrl == nil {
                    Task {
                        isLoading = true
                        let previewUrl = try await homeVM.fetchPreview(for: song)
                        isLoading = false
                        song.songPreviewUrl = previewUrl
                        showMenu = true
                    }
                } else {
                    showMenu = true
                }
            }) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if homeVM.currentlyPlayingSongId == song.id {
                    Image(systemName: "stop.fill")
                        .font(.title3)
                } else {
                    Image(systemName: "play.fill")
                        .font(.title3)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .confirmationDialog("Choose an action", isPresented: $showMenu) {
                Button("Play in Spotify") {
                    if let url = URL(string: song.spotifyExternalUrl) {
                        UIApplication.shared.open(url)
                    }
                }
                if let previewUrl = song.songPreviewUrl {
                    Button("Preview") {
                        Task {
                            await homeVM.playPreview(from: previewUrl, for: song)
                        }
                    }
                }
                
            }

            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.headline)
                Text(song.artist)
                    .font(.subheadline)
            }

            Spacer()

            Button(action: {
                song.checked.toggle()
            }) {
                Image(systemName: song.checked ? "checkmark.square.fill" : "square")
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
        .padding(5)
        .foregroundStyle(.white)
        .background(Color.gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 5))
//        .alert("Oops", isPresented: $vm.isShowingError) {} message: {
//            Text(vm.errorMessage ?? "Something went wrong")
//        }
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext

    SongView(homeVM: HomeViewModel(service: OpenAIService(), spotifyService: SpotifyService(), auth: Auth(), userService: UserService(context: modelContext)), song: .constant(Song(title: "Wake Me Up", artist: "Avicii", album: "album", checked: true, spotifyId: "0nrRP2bk19rLc0orkWPQk2", spotifyExternalUrl: "spotify.com")))
}
