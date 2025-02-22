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
                            if scatter {
                                scatterStars(geometry: geometry)
                            }
                        }
        }
    }

    private func createStars(in size: CGSize) -> [Star] {
        (0..<starCount).map { _ in
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
        for index in stars.indices {
            let newX = stars[index].position.x + stars[index].direction.dx
            let newY = stars[index].position.y + stars[index].direction.dy
            
            stars[index].position = CGPoint(
                x: newX.truncatingRemainder(dividingBy: size.width),
                y: newY.truncatingRemainder(dividingBy: size.height)
            )
            
            // Keep positions within bounds
            if stars[index].position.x < 0 { stars[index].position.x += size.width }
            if stars[index].position.y < 0 { stars[index].position.y += size.height }
        }
    }
    
    // Scatter stars quickly
    private func scatterStars(geometry: GeometryProxy) {
        for index in stars.indices {
            let scatterX = CGFloat.random(in: -geometry.size.width..<geometry.size.width * 5)
            let scatterY = CGFloat.random(in: -geometry.size.height..<geometry.size.height * 5)
            
            // Move to scatter position
            withAnimation(Animation.easeOut(duration: scatterSpeed)) {
                stars[index].position = CGPoint(x: scatterX, y: scatterY)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + scatterSpeed - 0.1) {
            shouldScatter = false
        }
        
        // Return to normal after scattering
        DispatchQueue.main.asyncAfter(deadline: .now() + scatterSpeed * 2) {
            withAnimation(Animation.easeIn(duration: scatterSpeed)) {
                for index in stars.indices {
                    let newX = CGFloat.random(in: 0..<geometry.size.width)
                    let newY = CGFloat.random(in: 0..<geometry.size.height)
                    stars[index].position = CGPoint(x: newX, y: newY)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + scatterSpeed * 2) {
                shouldScatter = false
            }
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
