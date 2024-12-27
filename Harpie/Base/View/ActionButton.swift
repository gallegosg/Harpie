//
//  ActionButton.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/11/24.
//

import SwiftUI

enum ActionButtonType: Equatable {
    case spotify
    case reset
    case more(count: Int)
    
    static func == (lhs: ActionButtonType, rhs: ActionButtonType) -> Bool {
        switch (lhs, rhs) {
        case (.spotify, .spotify), (.reset, .reset):
            return true
        case (.more(let count1), .more(let count2)):
            return count1 == count2
        default:
            return false
        }
    }
}

struct ActionButton: View {
    let action: () -> Void
    let type: ActionButtonType
    @State private var disabled: Bool = false
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                switch type {
                case .spotify:
                    VStack {
                        Image(systemName: "music.note")
                        Text("Add to")
                        Text("Spotify")
                    }
                case .reset:
                    VStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                case .more(let count):
                    VStack {
                        Image(systemName: "plus")
                        Text("More")
                        Text("\(K.moreLimit - count) left")
                            .font(.subheadline)
                    }
                    .foregroundStyle(disabled ? Color.white.opacity(0.5) : Color.white)
                }
            }
            .foregroundStyle(.white)
        }
        .disabled(disabled)
        .onChange(of: type) {_, _ in
            switch type {
            case .more(let count):
                disabled = K.moreLimit - count <= 0
                print(disabled)
            case .spotify, .reset:
                disabled = false
            }
        }
    }
}

#Preview {
    ActionButton(action: dummy, type: .more(count: 1))
        .background(Color.black)
}
func dummy() -> Void {
    print("dummy")
}
