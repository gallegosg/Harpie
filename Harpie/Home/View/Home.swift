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
    
    var body: some View {
        VStack {
            Spacer()
            if vm.isLoading || vm.shouldScatter {
                ZStack {
                    StarsView(shouldScatter: $vm.shouldScatter)
                    ProgressView()
                        .foregroundStyle(.white)
                }
                .onChange(of: vm.shouldScatter) { old, new in
                    if !new {
                        vm.disableLoading()
                    }
                }
            } else if vm.playlist.isEmpty {
                VStack {
                    VStack {
                        Spacer()
                        Text("Music Find")
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
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .border(.secondary)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom, 30)
                        .onChange(of: vm.searchText) { oldValue, newValue in
                            if vm.searchText.count > K.searchTextLimit {
                                vm.searchText = String(vm.searchText.prefix(K.searchTextLimit))
                            }
                        }
                        
                        Button("Go") {
                            Task {
                                await vm.handleGenerateButton()
                            }
                        }
                        .padding()
                        .font(.custom("AvenirNext-Medium", size: 20))
                        .bold()
                        .foregroundStyle(.white)
                        .background(Color.clear)
                        .frame(width: 150, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
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
