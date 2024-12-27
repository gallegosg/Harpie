//
//  ContentView.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/8/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var vm: HomeViewModel
    private var auth = Auth()
    
    init() {
        // Initialize the view model with placeholder values
        _vm = StateObject(wrappedValue: HomeViewModel(
            service: OpenAIService(),
            spotifyService: SpotifyService(),
            auth: Auth(),
            userService: nil
        ))
    }
    
    var body: some View {
        Group {            
            if vm.isInitialized {
                Home(vm: vm)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            let userService = UserService(context: modelContext)
            vm.userService = userService
            vm.initialize()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GradientBackground())
    }
}

#Preview {
    ContentView()
}
