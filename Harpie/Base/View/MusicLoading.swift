import SwiftUI

struct MusicLoading: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Musical notes
            HStack(spacing: 20) {
                ForEach(0..<3) { index in
                    Image(systemName: "music.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.white)
                        .offset(y: isAnimating ? -20 : 20)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it takes up all available space
        .onAppear {
            isAnimating = true
        }
    }
}
struct MusicLoading_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            MusicLoading()
        }
    }
}
