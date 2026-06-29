import SwiftUI

enum Theme {
    static let bg       = Color(red: 0.04, green: 0.04, blue: 0.07)
    static let bgRaised = Color(red: 0.10, green: 0.10, blue: 0.15)
    static let card     = Color(red: 0.13, green: 0.13, blue: 0.19)
    static let accent   = Color(red: 1.00, green: 0.46, blue: 0.28)   // warm coral
    static let textDim  = Color.white.opacity(0.55)

    /// App title gradient
    static let brand = LinearGradient(
        colors: [Color(red: 1.0, green: 0.55, blue: 0.30),
                 Color(red: 0.95, green: 0.30, blue: 0.55)],
        startPoint: .leading, endPoint: .trailing)
}
