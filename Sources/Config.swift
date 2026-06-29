import Foundation

/// App-wide configuration for the AI backend.
///
/// While `backendURL` is `nil`, the app falls back to the offline CoreImage
/// mock (`StyleTransformer`) so it still runs with no server. Point this at your
/// deployed proxy (see `server/`) to enable real AI generation.
enum Config {
    /// e.g. `URL(string: "https://api.reechi.app")` or your ngrok/LAN URL while testing.
    static let backendURL: URL? = nil

    /// Shared token the proxy checks on every request. Replace with real
    /// per-user auth (e.g. RevenueCat receipt / Sign in with Apple) later.
    static let appToken = "dev-reechi-token"

    /// Whether real generation is enabled right now.
    static var aiEnabled: Bool { backendURL != nil }
}
