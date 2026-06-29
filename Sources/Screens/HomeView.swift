import SwiftUI

struct HomeView: View {
    private let styles = PhotoStyle.all
    private let columns = [GridItem(.flexible(), spacing: 14),
                           GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        trendingBanner
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Pick a style")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(styles) { style in
                                    NavigationLink(value: style) {
                                        StyleCard(style: style)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: PhotoStyle.self) { style in
                CreateFlowView(style: style)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Reechi")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(Theme.brand)
                Text("Turn your selfie into trending art")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textDim)
            }
            Spacer()
            ZStack {
                Circle().fill(Theme.bgRaised).frame(width: 40, height: 40)
                Image(systemName: "crown.fill")
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(.top, 8)
    }

    private var trendingBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(Theme.brand, in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 3) {
                Text("Trending now")
                    .font(.headline).foregroundStyle(.white)
                Text("Action Figure & Ghibli are blowing up")
                    .font(.caption).foregroundStyle(Theme.textDim)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(Theme.textDim)
        }
        .padding(14)
        .background(Theme.bgRaised, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct StyleCard: View {
    let style: PhotoStyle

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(style.linearGradient)
                .aspectRatio(0.82, contentMode: .fit)
                .overlay(
                    Image(systemName: style.symbol)
                        .font(.system(size: 54, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))
                        .shadow(radius: 8, y: 4)
                )
                .overlay(alignment: .bottomLeading) {
                    LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.55)],
                                   startPoint: .center, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(style.name)
                            .font(.headline).foregroundStyle(.white)
                        Text(style.tagline)
                            .font(.caption2).foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(12)
                }

            HStack(spacing: 6) {
                if style.trending {
                    badge(text: "TRENDING", system: "flame.fill", tint: Theme.accent)
                }
                if style.isPro {
                    badge(text: "PRO", system: "crown.fill", tint: .yellow)
                }
            }
            .padding(10)
        }
    }

    private func badge(text: String, system: String, tint: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: system).font(.system(size: 8, weight: .bold))
            Text(text).font(.system(size: 9, weight: .heavy))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 7).padding(.vertical, 4)
        .background(tint.opacity(0.9), in: Capsule())
    }
}
