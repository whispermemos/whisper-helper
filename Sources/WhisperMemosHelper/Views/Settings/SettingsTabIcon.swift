import AppKit
import SwiftUI

/*
 * The icons of the Settings tabs, used by SettingsView. General and Instructions
 * are pictures made for WhisperType, copied into Resources/. Account is drawn
 * here in the same style as WhisperType's lighter icons: a grey symbol on a
 * near-white rounded square with a grey outline.
 */
enum SettingsTabIcon {
    private static let size: CGFloat = 30
    // the square is smaller than the image, like in the copied pictures
    private static let inset: CGFloat = 4
    private static let cornerRadius: CGFloat = 5.5
    private static let symbolPointSize: CGFloat = 13

    /// A picture from the app's Resources folder, e.g. "settings-general".
    /// A bare `swift run` has no Resources folder, so it shows the SF Symbol instead.
    static func picture(_ name: String, fallbackSymbol: String) -> Image {
        if let picture = Bundle.main.image(forResource: name) {
            return Image(nsImage: picture)
        }
        return Image(systemName: fallbackSymbol)
    }

    static func light(symbol: String) -> Image {
        // the drawing block runs again for every screen scale, so the icon stays sharp
        let icon = NSImage(size: NSSize(width: size, height: size), flipped: false) { bounds in
            let square = bounds.insetBy(dx: inset, dy: inset)
            let squarePath = NSBezierPath(roundedRect: square, xRadius: cornerRadius, yRadius: cornerRadius)
            NSGradient(starting: NSColor(white: 0.91, alpha: 1), ending: .white)?.draw(in: squarePath, angle: 90)

            // the outline sits half a point inside the square, so it is not cut off
            let outline = NSBezierPath(
                roundedRect: square.insetBy(dx: 0.25, dy: 0.25),
                xRadius: cornerRadius,
                yRadius: cornerRadius
            )
            outline.lineWidth = 0.5
            NSColor(white: 0.62, alpha: 1).setStroke()
            outline.stroke()

            let configuration = NSImage.SymbolConfiguration(pointSize: symbolPointSize, weight: .semibold)
                .applying(NSImage.SymbolConfiguration(paletteColors: [NSColor(white: 0.3, alpha: 1)]))
            guard let glyph = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?
                .withSymbolConfiguration(configuration)
            else {
                return true
            }

            let origin = NSPoint(x: bounds.midX - glyph.size.width / 2, y: bounds.midY - glyph.size.height / 2)
            glyph.draw(at: origin, from: .zero, operation: .sourceOver, fraction: 1)
            return true
        }
        return Image(nsImage: icon)
    }
}
