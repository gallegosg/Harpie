import SwiftUI

struct MusicLoadingView: View {
    @State private var amplitudes: [CGFloat] = Array(repeating: 0.5, count: 8)
    @State private var currentTextIndex: Int = 0
    
    // Array of music-related loading texts
    let loadingTexts = [
        "Mixing your perfect playlist...",
        "Fetching beats just for you...",
        "Tuning into your vibe...",
        "Thinking up some catchy tunes...",
        "Spinning tracks into magic...",
        "Curating your musical journey...",
        "Searching the soundwaves...",
        "Grooving while we process...",
        "Finding the rhythm of your mood...",
        "Cooking up a sonic masterpiece...",
        "Analyzing your musical taste...",
        "Building your playlist, note by note...",
        "Chasing melodies for you...",
        "Harmonizing your next hits...",
        "Shuffling through the music vault..."
    ]
    
    var body: some View {
        ZStack {
            // Equalizer bars (centered)
            HStack(spacing: 8) {
                ForEach(0..<8) { index in
                    BarView(amplitude: amplitudes[index])
                        .frame(width: 12)
                        .foregroundColor(.white.opacity(0.7))
                        .clipShape(Capsule())
                }
            }
            .frame(width: 150, height: 80)
            .onAppear {
                currentTextIndex = Int.random(in: 0..<loadingTexts.count)
                startAnimations()
                startTextCycle()
            }
            
            // Loading text (cycling through array)
            Text(loadingTexts[currentTextIndex])
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .offset(y: 60)
        }
        .frame(maxWidth: .infinity, maxHeight: 170)
    }
    
    // Start bar animations
    private func startAnimations() {
        for i in 0..<8 {
            withAnimation(
                Animation.easeInOut(duration: Double.random(in: 0.5...0.8))
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.1)
            ) {
                amplitudes[i] = CGFloat.random(in: 0.2...1.0)
            }
        }
    }
    
    // Cycle through loading texts
    private func startTextCycle() {
        Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2)) {
                currentTextIndex = Int.random(in: 0..<loadingTexts.count)
            }
        }
    }
}

// Single equalizer bar
struct BarView: View {
    let amplitude: CGFloat
    
    var body: some View {
        Rectangle()
            .frame(height: 80 * amplitude)
            .offset(y: (80 * (1 - amplitude)) / 2)
    }
}

// Preview
struct MusicLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        MusicLoadingView()
            .background(Color.gray.opacity(0.2))
    }
}
