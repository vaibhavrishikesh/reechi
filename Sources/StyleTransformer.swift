import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// MOCK "AI" transform for the glimpse — applies a CoreImage filter chain per style so each
/// result looks visibly different. Real AI image generation is wired in a later phase.
enum StyleTransformer {
    private static let context = CIContext()

    static func apply(style: PhotoStyle, to image: UIImage) -> UIImage {
        guard let input = CIImage(image: image) else { return image }
        let extent = input.extent
        var output = input

        switch style.name {
        case "Action Figure", "Pixar 3D":
            let c = CIFilter.colorControls()
            c.inputImage = output; c.saturation = 1.7; c.contrast = 1.18; c.brightness = 0.04
            output = c.outputImage ?? output
            let s = CIFilter.sharpenLuminance()
            s.inputImage = output; s.sharpness = 0.6
            output = s.outputImage ?? output

        case "Ghibli":
            let c = CIFilter.colorControls()
            c.inputImage = output; c.saturation = 1.35; c.brightness = 0.06; c.contrast = 1.05
            output = c.outputImage ?? output
            let v = CIFilter.vibrance()
            v.inputImage = output; v.amount = 0.5
            output = v.outputImage ?? output

        case "Anime Hero", "Cyberpunk":
            let comic = CIFilter.comicEffect()
            comic.inputImage = output
            output = comic.outputImage ?? output

        case "Polaroid":
            let p = CIFilter.photoEffectTransfer()
            p.inputImage = output
            output = p.outputImage ?? output
            let vig = CIFilter.vignette()
            vig.inputImage = output; vig.intensity = 1.2; vig.radius = 2.0
            output = vig.outputImage ?? output

        default:
            let c = CIFilter.colorControls()
            c.inputImage = output; c.saturation = 1.4
            output = c.outputImage ?? output
        }

        guard let cg = context.createCGImage(output, from: extent) else { return image }
        return UIImage(cgImage: cg, scale: image.scale, orientation: image.imageOrientation)
    }
}
