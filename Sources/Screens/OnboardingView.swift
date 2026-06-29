import SwiftUI

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let symbol: String
    let gradient: [Color]
    let title: String
    let subtitle: String

    static let all: [OnboardingSlide] = [
        .init(symbol: "wand.and.stars",
              gradient: [Color(red: 1.0, green: 0.50, blue: 0.20), Color(red: 0.95, green: 0.25, blue: 0.45)],
              title: "Turn selfies into art",
              subtitle: "One photo → trending AI styles in seconds. No skills needed."),
        .init(symbol: "square.grid.2x2.fill",
              gradient: [Color(red: 0.55, green: 0.35, blue: 0.95), Color(red: 0.20, green: 0.60, blue: 0.95)],
              title: "Every viral trend",
              subtitle: "Action Figure, Ghibli, Anime, Polaroid & more — added as trends pop."),
        .init(symbol: "square.and.arrow.up.fill",
              gradient: [Color(red: 0.20, green: 0.70, blue: 0.55), Color(red: 0.15, green: 0.45, blue: 0.70)],
              title: "Share & go viral",
              subtitle: "Save in HD and post your before/after. Watch the likes roll in.")
    ]
}

struct OnboardingContainer: View {
    var onDone: () -> Void
    @State private var page = 0
    @State private var showPaywall = false
    private let slides = OnboardingSlide.all

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(slides.indices, id: \.self) { i in
                        slideView(slides[i]).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                Button(page < slides.count - 1 ? "Continue" : "Get Started") {
                    if page < slides.count - 1 { withAnimation { page += 1 } }
                    else { showPaywall = true }
                }
                .font(.headline).foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(Theme.brand, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24).padding(.bottom, 24)
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(onClose: onDone)
        }
    }

    private func slideView(_ slide: OnboardingSlide) -> some View {
        VStack(spacing: 30) {
            Spacer()
            RoundedRectangle(cornerRadius: 40)
                .fill(LinearGradient(colors: slide.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 200, height: 240)
                .overlay(Image(systemName: slide.symbol)
                    .font(.system(size: 84, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95)))
                .shadow(color: slide.gradient.first!.opacity(0.55), radius: 30, y: 14)
            VStack(spacing: 12) {
                Text(slide.title)
                    .font(.system(size: 30, weight: .heavy)).foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(slide.subtitle)
                    .font(.body).foregroundStyle(Theme.textDim)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer(); Spacer()
        }
    }
}
