import SwiftUI
import PhotosUI

struct CreateFlowView: View {
    let style: PhotoStyle
    @Environment(\.dismiss) private var dismiss

    enum Stage { case pick, generating, result }
    @State private var stage: Stage = .pick
    @State private var pickerItem: PhotosPickerItem?
    @State private var sourceImage: UIImage?
    @State private var resultImage: UIImage?
    @State private var progress: Double = 0
    @State private var showSaved = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            switch stage {
            case .pick:        pickStage
            case .generating:  generatingStage
            case .result:      resultStage
            }
        }
        .navigationTitle(style.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    sourceImage = img
                    startGenerating()
                }
            }
        }
    }

    // MARK: Pick
    private var pickStage: some View {
        VStack(spacing: 22) {
            Spacer()
            RoundedRectangle(cornerRadius: 28)
                .fill(style.linearGradient)
                .frame(width: 180, height: 220)
                .overlay(Image(systemName: style.symbol)
                    .font(.system(size: 70, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92)))
                .shadow(color: style.gradient.first!.opacity(0.5), radius: 24, y: 10)

            VStack(spacing: 6) {
                Text("\(style.name) style")
                    .font(.title2.bold()).foregroundStyle(.white)
                Text(style.tagline)
                    .font(.subheadline).foregroundStyle(Theme.textDim)
            }

            Spacer()

            PhotosPicker(selection: $pickerItem, matching: .images) {
                Label("Choose your photo", systemImage: "photo.on.rectangle.angled")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(Theme.brand, in: RoundedRectangle(cornerRadius: 16))
            }
            Text("1 free try · then unlock Pro")
                .font(.caption).foregroundStyle(Theme.textDim)
        }
        .padding(24)
    }

    // MARK: Generating
    private var generatingStage: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                if let src = sourceImage {
                    Image(uiImage: src).resizable().scaledToFill()
                        .frame(width: 220, height: 220).clipShape(RoundedRectangle(cornerRadius: 24))
                        .blur(radius: 6).opacity(0.6)
                }
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Theme.brand, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 120, height: 120).rotationEffect(.degrees(-90))
                Text("\(Int(progress * 100))%")
                    .font(.title2.bold().monospacedDigit()).foregroundStyle(.white)
            }
            VStack(spacing: 6) {
                Text("Creating your \(style.name)…")
                    .font(.headline).foregroundStyle(.white)
                Text("AI is working its magic ✨")
                    .font(.caption).foregroundStyle(Theme.textDim)
            }
            Spacer()
        }
        .padding(24)
    }

    // MARK: Result
    private var resultStage: some View {
        VStack(spacing: 18) {
            HStack(spacing: 12) {
                beforeAfter(title: "Before", image: sourceImage)
                beforeAfter(title: "After", image: resultImage, glow: true)
            }
            .padding(.top, 8)

            Text("✨ Your \(style.name) is ready!")
                .font(.title3.bold()).foregroundStyle(.white)

            HStack(spacing: 12) {
                Button { withAnimation { showSaved = true } } label: {
                    actionLabel("Save", "square.and.arrow.down")
                }
                if let resultImage {
                    ShareLink(item: Image(uiImage: resultImage), preview: .init("My \(style.name)", image: Image(uiImage: resultImage))) {
                        actionLabel("Share", "square.and.arrow.up")
                    }
                }
            }

            Button { dismiss() } label: {
                Text("Try another style")
                    .font(.headline).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 15)
                    .background(Theme.brand, in: RoundedRectangle(cornerRadius: 16))
            }
            Spacer()
        }
        .padding(20)
        .overlay(alignment: .top) {
            if showSaved {
                Label("Saved to Photos", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold()).foregroundStyle(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(.green.opacity(0.9), in: Capsule())
                    .padding(.top, 8).transition(.move(edge: .top).combined(with: .opacity))
                    .task { try? await Task.sleep(nanoseconds: 1_600_000_000); withAnimation { showSaved = false } }
            }
        }
    }

    private func beforeAfter(title: String, image: UIImage?, glow: Bool = false) -> some View {
        VStack(spacing: 6) {
            Group {
                if let image {
                    Image(uiImage: image).resizable().scaledToFill()
                } else {
                    Theme.bgRaised
                }
            }
            .frame(width: 150, height: 200).clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(glow ? Theme.accent : .white.opacity(0.1), lineWidth: glow ? 2 : 1))
            .shadow(color: glow ? Theme.accent.opacity(0.5) : .clear, radius: 14)
            Text(title).font(.caption.bold()).foregroundStyle(glow ? Theme.accent : Theme.textDim)
        }
    }

    private func actionLabel(_ text: String, _ icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.subheadline.bold()).foregroundStyle(.white)
            .frame(maxWidth: .infinity).padding(.vertical, 13)
            .background(Theme.bgRaised, in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: Logic
    private func startGenerating() {
        progress = 0
        stage = .generating
        Task {
            for i in 1...60 {
                try? await Task.sleep(nanoseconds: 40_000_000) // ~2.4s total
                progress = Double(i) / 60.0
            }
            if let src = sourceImage {
                resultImage = StyleTransformer.apply(style: style, to: src)
            }
            withAnimation { stage = .result }
        }
    }
}
