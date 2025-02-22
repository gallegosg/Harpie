//
//  GradientBackground.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/10/24.
//

import SwiftUI

//struct GradientBackground: View {
//    @State private var gradientShift: CGFloat = 0.0
//    @State private var randomColors: [Color] = [
//        Color.red, Color.blue, Color.purple
//    ]
//
//    // Define possible gradient start and end points
//    let gradientPoints: [UnitPoint] = [
//        .top, .bottom, .leading, .trailing, .topLeading, .topTrailing, .bottomLeading, .bottomTrailing
//    ]
//
//    @State private var startPoint: UnitPoint = .top
//    @State private var endPoint: UnitPoint = .bottom
//
//    var body: some View {
//        LinearGradient(
//            gradient: Gradient(colors: randomColors), // Keep colors consistent
//            startPoint: startPoint,
//            endPoint: endPoint
//        )
//        .hueRotation(.degrees(gradientShift)) // Animation effect on color hue
//        .ignoresSafeArea()
//        .onAppear {
//            randomColors.shuffle()
//
//            // Randomly choose start and end points, but ensure a smooth gradient
//            startPoint = gradientPoints.randomElement() ?? .top
//            endPoint = gradientPoints.randomElement() ?? .bottom
//
//            // Set up periodic gradient shift (to keep it dynamic)
//            withAnimation(
//                Animation.linear(duration: 10)
//                    .repeatForever(autoreverses: true)
//            ) {
//                gradientShift = CGFloat.random(in: 0...360)
//            }
//
//            // Timer for periodic changes in start and end points while maintaining gradient appearance
//            Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
//                withAnimation(.easeInOut(duration: 10.0)) {
//                    startPoint = gradientPoints.randomElement() ?? .top
//                    endPoint = gradientPoints.randomElement() ?? .bottom
//                }
//            }
//        }
//    }
//}

struct GradientBackground: View {
    @State private var angle: Double = 0
    @State private var color1: Color = .red
    @State private var color2: Color = .purple

    var body: some View {
        ZStack {
            
            GeometryReader { geometry in
                let center = UnitPoint.center
                
                AngularGradient(
                    gradient: Gradient(colors: [color1, color2, color1]),
                    center: center,
                    angle: .degrees(angle)
                )
                .ignoresSafeArea()
                .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: angle)
                .onAppear {
                    // Start spinning animation
                    angle = 360
                    
                    // Animate color changes smoothly
                    Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                        withAnimation(.easeInOut(duration: 5)) {
                            color1 = Color.random
                            color2 = Color.random
                        }
                    }
                }
            }
        }
    }
}
