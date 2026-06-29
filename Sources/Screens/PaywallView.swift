import SwiftUI

struct PaywallView: View {
    var onClose: () -> Void
    @State private var selectedPlan = 0   // 0 = weekly trial, 1 = yearly

    private let features = [
        ("infinity", "Unlimited style generations"),
        ("bolt.fill", "Fastest HD processing"),
        ("crown.fill", "All Pro styles unlocked"),
        ("nosign", "No watermark, no ads")
    ]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        crownArt
                        Text("Unlock every AI style")
                            .font(.system(size: 26, weight: .heavy)).foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        featureList
                        planCards
                    }
                    .padding(.horizontal, 22).padding(.top, 6)
                }
                ctaSection
            }
        }
    }

    private var header: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.headline).foregroundStyle(Theme.textDim)
                    .frame(width: 36, height: 36).background(Theme.bgRaised, in: Circle())
            }
            Spacer()
            Button("Restore") { }.font(.subheadline).foregroundStyle(Theme.textDim)
        }
        .padding(.horizontal, 18).padding(.top, 14)
    }

    private var crownArt: some View {
        ZStack {
            Circle().fill(Theme.brand).frame(width: 92, height: 92)
                .shadow(color: Theme.accent.opacity(0.6), radius: 22, y: 8)
            Image(systemName: "crown.fill").font(.system(size: 42)).foregroundStyle(.white)
        }
        .padding(.top, 8)
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(features, id: \.1) { icon, text in
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .bold)).foregroundStyle(Theme.accent)
                        .frame(width: 26)
                    Text(text).font(.subheadline).foregroundStyle(.white)
                    Spacer()
                }
            }
        }
        .padding(18)
        .background(Theme.bgRaised, in: RoundedRectangle(cornerRadius: 18))
    }

    private var planCards: some View {
        VStack(spacing: 12) {
            planCard(index: 0, title: "Weekly", price: "$4.99 / week",
                     note: "3-day free trial", badge: "TRIAL")
            planCard(index: 1, title: "Yearly", price: "$29.99 / year",
                     note: "Just $2.50/mo · save 88%", badge: "BEST VALUE")
        }
    }

    private func planCard(index: Int, title: String, price: String, note: String, badge: String) -> some View {
        let selected = selectedPlan == index
        return Button { selectedPlan = index } label: {
            HStack(spacing: 14) {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .font(.title3).foregroundStyle(selected ? Theme.accent : Theme.textDim)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.headline).foregroundStyle(.white)
                    Text(note).font(.caption).foregroundStyle(Theme.textDim)
                }
                Spacer()
                Text(price).font(.subheadline.bold()).foregroundStyle(.white)
            }
            .padding(16)
            .background(Theme.bgRaised, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(selected ? Theme.accent : .clear, lineWidth: 2))
            .overlay(alignment: .topTrailing) {
                Text(badge).font(.system(size: 9, weight: .heavy)).foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Theme.brand, in: Capsule()).offset(x: -10, y: -8)
            }
        }
        .buttonStyle(.plain)
    }

    private var ctaSection: some View {
        VStack(spacing: 10) {
            Button(action: onClose) {
                Text(selectedPlan == 0 ? "Start Free Trial" : "Continue")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 17)
                    .background(Theme.brand, in: RoundedRectangle(cornerRadius: 16))
            }
            Text("Cancel anytime · Terms · Privacy")
                .font(.caption2).foregroundStyle(Theme.textDim)
        }
        .padding(.horizontal, 22).padding(.top, 10).padding(.bottom, 18)
    }
}
