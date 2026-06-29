import SwiftUI

struct PhotoStyle: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let tagline: String
    let symbol: String          // SF Symbol shown on the card
    let gradient: [Color]       // card background gradient
    let isPro: Bool
    let trending: Bool
}

extension PhotoStyle {
    var linearGradient: LinearGradient {
        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static let all: [PhotoStyle] = [
        PhotoStyle(name: "Action Figure",
                   tagline: "Become a collectible toy",
                   symbol: "figure.stand",
                   gradient: [Color(red: 1.0, green: 0.50, blue: 0.20), Color(red: 0.95, green: 0.25, blue: 0.45)],
                   isPro: false, trending: true),
        PhotoStyle(name: "Ghibli",
                   tagline: "Dreamy anime world",
                   symbol: "leaf.fill",
                   gradient: [Color(red: 0.20, green: 0.70, blue: 0.55), Color(red: 0.15, green: 0.45, blue: 0.70)],
                   isPro: false, trending: true),
        PhotoStyle(name: "Anime Hero",
                   tagline: "Bold manga style",
                   symbol: "sparkles",
                   gradient: [Color(red: 0.55, green: 0.35, blue: 0.95), Color(red: 0.30, green: 0.25, blue: 0.80)],
                   isPro: true, trending: false),
        PhotoStyle(name: "Polaroid",
                   tagline: "Vintage film vibe",
                   symbol: "camera.fill",
                   gradient: [Color(red: 0.75, green: 0.55, blue: 0.35), Color(red: 0.50, green: 0.35, blue: 0.25)],
                   isPro: true, trending: false),
        PhotoStyle(name: "Pixar 3D",
                   tagline: "Cute animated character",
                   symbol: "cube.fill",
                   gradient: [Color(red: 0.20, green: 0.60, blue: 0.95), Color(red: 0.40, green: 0.30, blue: 0.90)],
                   isPro: true, trending: true),
        PhotoStyle(name: "Cyberpunk",
                   tagline: "Neon future glow",
                   symbol: "bolt.fill",
                   gradient: [Color(red: 0.90, green: 0.20, blue: 0.60), Color(red: 0.25, green: 0.20, blue: 0.55)],
                   isPro: true, trending: false),
    ]
}
