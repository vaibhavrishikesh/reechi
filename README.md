# AI Photo Styles

Selfie → trending AI art styles (Action Figure, Ghibli, Anime, Polaroid…) in 2 taps.
First iOS app — SwiftUI. Built and run **entirely from the CLI** (no Xcode GUI required).

> Current state: **working MVP glimpse** — onboarding + paywall + home (style grid) +
> full pick-photo → generating → before/after result flow. The AI transform is currently
> **mocked** with CoreImage filters; real AI image generation is a later phase.

## Build & run (no Xcode GUI)

Requires: Xcode 16.x command-line tools, [`xcodegen`](https://github.com/yonaskolb/XcodeGen)
(`brew install xcodegen`), and an iOS Simulator.

```bash
./run.sh        # xcodegen → xcodebuild → install → launch on the iPhone 16 simulator
```

Or manually:

```bash
xcodegen generate
xcodebuild -project AIPhotoStyles.xcodeproj -scheme AIPhotoStyles \
  -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/AIPhotoStyles.app
xcrun simctl launch booted com.tranquilwaters.aiphotostyles
```

The Xcode project is generated from `project.yml` by xcodegen, so it is **not** committed.

## Structure

```
project.yml                  # xcodegen spec (source of truth for the .xcodeproj)
Sources/
  AIPhotoStylesApp.swift      # @main entry
  RootView.swift              # onboarding gate → Home
  Theme.swift                 # colors / brand gradient
  StyleTransformer.swift      # MOCK per-style CoreImage transform
  Models/PhotoStyle.swift     # style catalog
  Screens/
    HomeView.swift            # style-cards grid
    CreateFlowView.swift      # pick → generating → result
    OnboardingView.swift      # 3-slide intro
    PaywallView.swift         # hard paywall
```

## Roadmap

- [ ] Wire real AI image generation (backend proxy + nano-banana/FLUX)
- [ ] RevenueCat for real subscriptions / credit packs
- [ ] App icon + assets
- [ ] Real-device install (needs Apple-ID code signing)
