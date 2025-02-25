import SwiftUI

struct StarsView: View {
    @State private var stars: [Star] = []
    @Binding var shouldScatter: Bool
    private let starCount = 100
    private let movementSpeed = 0.01 // Adjust for smoothness
    private let scatterSpeed: Double = 1 // Speed for scattering effect

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(stars.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: stars[index].size, height: stars[index].size)
                        .position(stars[index].position)
                        .opacity(stars[index].opacity)
                }
            }
            .onAppear {
                stars = createStars(in: geometry.size)
            }
            .onReceive(Timer.publish(every: movementSpeed, on: .main, in: .common).autoconnect()) { _ in
                updateStarPositions(in: geometry.size)
            }
            .onChange(of: shouldScatter) { old, scatter in
                if scatter && geometry.size.width > 0 && geometry.size.height > 0 {
                    scatterStars(geometry: geometry)
                }
            }
        }
    }

    private func createStars(in size: CGSize) -> [Star] {
        guard size.width > 0, size.height > 0 else { return [] }
        return (0..<starCount).map { _ in
            Star(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0..<size.width),
                    y: CGFloat.random(in: 0..<size.height)
                ),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.3...0.8),
                direction: CGVector(
                    dx: CGFloat.random(in: -0.5...0.5),
                    dy: CGFloat.random(in: -0.5...0.5)
                )
            )
        }
    }
    
    private func updateStarPositions(in size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        for index in stars.indices {
            var star = stars[index]
            let newX = star.position.x + star.direction.dx
            let newY = star.position.y + star.direction.dy
            
            // Wrap positions around edges based on visible bounds
            star.position = CGPoint(
                x: newX.truncatingRemainder(dividingBy: size.width),
                y: newY.truncatingRemainder(dividingBy: size.height)
            )
            if star.position.x < 0 { star.position.x += size.width }
            if star.position.y < 0 { star.position.y += size.height }
            stars[index] = star
        }
    }
    
    // Scatter stars once and continue from there
    private func scatterStars(geometry: GeometryProxy) {
        let size = geometry.size
        guard size.width > 0, size.height > 0 else { return }
        
        for index in stars.indices {
            var star = stars[index]
            let scatterX = star.position.x + CGFloat.random(in: -size.width...size.width * 2)
            let scatterY = star.position.y + CGFloat.random(in: -size.height...size.height * 2)
            
            withAnimation(.easeOut(duration: scatterSpeed)) {
                star.position = CGPoint(x: scatterX, y: scatterY)
                stars[index] = star
            }
        }
        
        // Reset shouldScatter after scattering, no forced return
        DispatchQueue.main.asyncAfter(deadline: .now() + scatterSpeed) {
            shouldScatter = false
        }
    }
}

struct Star: Identifiable {
    let id: UUID
    var position: CGPoint
    let size: CGFloat
    let opacity: Double
    var direction: CGVector
}

#Preview {
    StarsView(shouldScatter: .constant(false))
        .background(Color.black)
}
