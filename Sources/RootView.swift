import SwiftUI

struct RootView: View {
    @AppStorage("didOnboard") private var didOnboard = false

    var body: some View {
        Group {
            if didOnboard {
                HomeView()
            } else {
                OnboardingContainer(onDone: { didOnboard = true })
            }
        }
        .preferredColorScheme(.dark)
    }
}
