//
//  SongView.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/10/24.
//

import SwiftUI

struct SongView: View {
    @Binding var song: Song
    var body: some View {
        Button {
            song.checked.toggle()
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.headline)
                    Text(song.artist)
                        .font(.subheadline)
                }
                Spacer()
                Image(systemName: song.checked ? "checkmark.square.fill" : "square")
                    .font(.title2)
            }
            .padding(5)
            .foregroundStyle(.white)
            .background(Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        
    }
}

#Preview {
    SongView(song: .constant(Song.init(id: UUID(), title: "Three Little Birds", artist: "Bob Marley")))
}
