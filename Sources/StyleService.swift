import UIKit

/// Talks to the Reechi proxy backend (see `server/`) to turn a selfie into a
/// styled image. The proxy holds the real provider API key — the app never does.
struct StyleService {
    let baseURL: URL
    var appToken: String = Config.appToken

    private struct Request: Encodable { let style: String; let image: String }
    private struct Response: Decodable { let image: String }   // base64 (no data: prefix)

    enum ServiceError: LocalizedError {
        case server(Int), badImage
        var errorDescription: String? {
            switch self {
            case .server(let code): return "Server error (\(code))"
            case .badImage:         return "Couldn’t read the generated image"
            }
        }
    }

    func generate(style: PhotoStyle, image: UIImage) async throws -> UIImage {
        // Downscale before upload — keeps requests fast/cheap.
        let resized = image.downscaled(maxDimension: 1024)
        guard let jpeg = resized.jpegData(compressionQuality: 0.9) else { throw ServiceError.badImage }

        var req = URLRequest(url: baseURL.appendingPathComponent("generate"))
        req.httpMethod = "POST"
        req.timeoutInterval = 120
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(appToken, forHTTPHeaderField: "X-App-Token")
        req.httpBody = try JSONEncoder().encode(Request(style: style.name,
                                                        image: jpeg.base64EncodedString()))

        let (data, resp) = try await URLSession.shared.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        guard code == 200 else { throw ServiceError.server(code) }

        let decoded = try JSONDecoder().decode(Response.self, from: data)
        guard let bytes = Data(base64Encoded: decoded.image),
              let ui = UIImage(data: bytes) else { throw ServiceError.badImage }
        return ui
    }
}

extension UIImage {
    /// Proportionally scale down so the longest side is at most `maxDimension`.
    func downscaled(maxDimension: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return self }
        let scale = maxDimension / longest
        let target = CGSize(width: size.width * scale, height: size.height * scale)
        return UIGraphicsImageRenderer(size: target).image { _ in
            draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
