//
//  Home.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/9/24.
//

import SwiftUI
import SwiftData
struct Home: View {
    @StateObject var vm: HomeViewModel
    @StateObject private var rewardVM = RewardedViewModel()
    @State private var showAlert: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            StarsView(shouldScatter: $vm.shouldScatter)

            VStack {
                Spacer()
                if vm.isLoading {
                    MusicLoadingView()
                } else if vm.playlist.isEmpty {
                    VStack {
                        VStack {
                                Spacer()
                                Text("Quick Mix")
                                    .font(.custom("Plaster", size: 40))
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 3, y: 3)
                                    .padding(.bottom, 10)
                                Text("Just type in a **feeling, mood or genre** and we'll generate a playlist for you!")
                                    .foregroundStyle(.white)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .padding()
                                Spacer()
                                
                            }
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 30)
                            
                        VStack {
                            TextField(
                                "",
                                text: $vm.searchText,
                                prompt: Text("e.g., Chill Pop, 2000s Rock, Rainy Day").foregroundColor(.black.opacity(0.4))
                            )
                            .focused($isTextFieldFocused)
                            .multilineTextAlignment(.center)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .frame(height: 40)
                            .background(RoundedRectangle(cornerRadius: 25).fill(Color.white.opacity(0.6)))
                            .foregroundStyle(.black)
                            .onChange(of: vm.searchText) { oldValue, newValue in
                                if vm.searchText.count > K.searchTextLimit {
                                    vm.searchText = String(vm.searchText.prefix(K.searchTextLimit))
                                }
                            }
                            
                            Text(vm.warningText ?? "")
                                .padding(.bottom, 30)
                            
                            Button(action: {
                                isTextFieldFocused = false // Dismiss keyboard first
                                Task {
                                    try? await Task.sleep(nanoseconds: 2_000_000)
                                    await vm.handleGenerateButton()
                                }
                            }) {
                                Text("Create My Mix!")
                                    .font(.custom("AvenirNext-Medium", size: 20))
                                    .bold()
                                    .foregroundStyle(.white)
                                    .frame(width: 175, height: 20) // Move frame inside the label
                            }
                            .padding()
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            
                            Text("Remaining Playlists: \(vm.remainingCount)")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            
                            Spacer()
                        }
                    }
                    .alert("Error", isPresented: $vm.isShowingError) {} message: {
                        Text(vm.error ?? "Something went wrong")
                    }
                    .alert(isPresented: $vm.showLimitReached) {
                        Alert(
                            title: Text("You've run out of playlists for today"),
                            message: Text("You can watch an ad to generate another playlist or wait until tomorrow."),
                            primaryButton: .default(Text("Dismiss")) {
                            },
                            secondaryButton: .cancel(Text("Get Another Playlist")) {
                                rewardVM.showAd()
                            }
                        )
                    }
                    
                } else {
                    PlaylistView(vm: vm)
                }
                Spacer()
                HStack {
                    Spacer()
                    if vm.isUserLoggedIn {
                        Button ("Logout") {
                            vm.handleLogoutButton()
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
        }
        .task {
            await rewardVM.loadAd()
        }
    }
    
    func noPermissionsAlert() -> Alert {
        Alert(
            title: Text(String(localized: "No Location Access")),
            message: Text(String(localized: "Please authorize location access in Settings")),
            dismissButton: .default(Text(String(localized: "Okay"))))
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext

    Home(vm: HomeViewModel(service: OpenAIService(), spotifyService: SpotifyService(), auth: Auth(), userService: UserService(context: modelContext)))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GradientBackground())
        .environment(\.modelContext, modelContext)
}
