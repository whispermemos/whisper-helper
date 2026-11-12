import AppKit
import CoreImage.CIFilterBuiltins

/*
 * Draws a QR code for a piece of text with Core Image, no packages needed.
 * Used by OnboardingPairingStep to show the pairing link for the iPhone camera.
 */
enum QRCode {
    static func image(for text: String) -> NSImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        guard let output = filter.outputImage else { return nil }

        // one pixel per square. the view scales it up without smoothing.
        let representation = NSCIImageRep(ciImage: output)
        let image = NSImage(size: representation.size)
        image.addRepresentation(representation)
        return image
    }
}
