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

    var body: some View {
        Button ("Logout") {
            vm.handleLogoutButton()
        }
        if vm.isLoading {
            ProgressView()
        } else if vm.playlist.isEmpty {
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
                
                Button("Shastify") {
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
            }
        } else {
            PlaylistView(vm: vm)
        }
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext

    Home(vm: HomeViewModel(service: OpenAIService(), spotifyService: SpotifyService(), auth: Auth(), userService: UserService(context: modelContext)))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GradientBackground())
        .environment(\.modelContext, modelContext)
}
