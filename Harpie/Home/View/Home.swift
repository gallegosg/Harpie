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
                                .foregroundStyle(.white)
                                .font(.custom("AvenirNext-Medium", size: 40))
                                .fontWeight(.bold)
                                .padding(.bottom, 10)
                            Text("Just type in a feeling, mood or genre and we'll generate a playlist for you!")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .fontWeight(.medium)
                                .padding()
                            Spacer()
                            
                        }
                        .multilineTextAlignment(.center)
                        
                        VStack {
                            TextField(
                                "What are you in the mood for?",
                                text: $vm.searchText
                            )
                            .focused($isTextFieldFocused)
                            .multilineTextAlignment(.center)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .border(.secondary)
                            .textFieldStyle(.roundedBorder)
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
                                Text("Go")
                                    .font(.custom("AvenirNext-Medium", size: 20))
                                    .bold()
                                    .foregroundStyle(.white)
                                    .frame(width: 100, height: 15) // Move frame inside the label
                            }
                            .padding()
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            
                            Spacer()
                        }
                    }
                    .alert("Error", isPresented: $vm.isShowingError) {} message: {
                        Text(vm.error ?? "Something went wrong")
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
