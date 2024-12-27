//
//  Color+Extension.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/11/24.
//

import SwiftUI

extension Color {
    /// Generate a random color
    static var random: Color {
        Color(
            red: .random(in: 0.3...0.7),
            green: .random(in: 0.3...0.7),
            blue: .random(in: 0.3...0.7)
        )
    }
}
