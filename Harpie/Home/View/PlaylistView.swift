//
//  PlaylistView.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/15/24.
//

import SwiftUI

struct PlaylistView: View {
    @StateObject var vm: HomeViewModel
    @State private var appearedItems: Set<UUID> = []
    @State private var previousPlaylistCount = 0 // Add this to your view
    
    var body: some View {
        VStack {
            if vm.spotifyLoading {
                MusicLoadingView(customLoadingText: "Saving your playlist to Spotify...")
            } else {
                VStack {
                    withAnimation(.easeOut(duration: 0.5)) {
                        Text(vm.message)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    if vm.moreLoading {
                        Spacer()
                        MusicLoadingView()
                        Spacer()
                    } else {
                        ScrollViewReader { proxy in
                            ScrollView {
                                ForEach(vm.playlist) { song in
                                    if let index = vm.playlist.firstIndex(of: song) {
                                        SongView(homeVM: vm, song: $vm.playlist[index])
                                            .opacity(appearedItems.contains(song.id) ? 1 : 0)
                                            .offset(y: appearedItems.contains(song.id) ? 0 : 20)
                                            .onAppear {
                                                if !appearedItems.contains(song.id) {
                                                    let delay = (Double(index) * 0.1) - Double(vm.moreCount)
                                                    _ = withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                                                        appearedItems.insert(song.id)
                                                    }
                                                }
                                            }
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                            .onReceive(vm.$playlist) { newPlaylist in
                                let currentCount = newPlaylist.count
                                if currentCount > previousPlaylistCount && vm.moreCount != 0 {
                                    if let lastSong = newPlaylist.last {
                                        withAnimation(.smooth(duration: 1)) {
                                            proxy.scrollTo(lastSong.id, anchor: .bottom)
                                        }
                                    }
                                }
                                previousPlaylistCount = currentCount // Update the previous count
                            }
                        }
                    }
                    
                    HStack(spacing: 15) {
                        Text("Available on")
                            .font(.footnote)
                            .foregroundColor(.white)
                        
                        Image("Spotify")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 25)
                    }
                        
                    HStack(alignment: .top) {
                        Spacer()
                        ActionButton(action: {
                            vm.reset()
                        }, type: .reset)
                        .disabled(vm.moreLoading)

                        Spacer()
                        ActionButton(action: {
                            vm.handleMore()
                        }, type: .more(count: vm.moreCount))
                        .disabled(vm.moreLoading)

                        Spacer()
                        ActionButton(action: {
                            Task {
                                await vm.handleAddToSpotifyButton()
                            }
                        }, type: .spotify)
                        .disabled(vm.moreLoading)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                .alert("Error", isPresented: $vm.isShowingError) {} message: {
                    Text(vm.error ?? "Something went wrong")
                }
                .alert(isPresented: $vm.isPlaylistReady) {
                    Alert(
                        title: Text("Success"),
                        message: Text("Playlist has been created!"),
                        primaryButton: .default(Text("View in Spotify")) {
                            vm.handleSendToSpotify()
                        },
                        secondaryButton: .default(Text("Start Over")) {
                            // Action for retrying (e.g., re-run creation)
                            vm.reset()
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    
    PlaylistView(vm: HomeViewModel(service: OpenAIService(), spotifyService: SpotifyService(), auth: Auth(), userService: UserService(context: modelContext)))
}
