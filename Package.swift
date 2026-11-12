// swift-tools-version: 6.0
import PackageDescription

// The Whisper Memos Mac helper. It talks to our worker over a WebSocket.
// The only dependency is Sparkle, which updates the app.
let package = Package(
    name: "WhisperMemosHelper",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.10.0"),
    ],
    targets: [
        .executableTarget(
            name: "WhisperMemosHelper",
            dependencies: [.product(name: "Sparkle", package: "Sparkle")]
        ),
        .testTarget(name: "WhisperMemosHelperTests", dependencies: ["WhisperMemosHelper"]),
    ],
    swiftLanguageModes: [.v5]
)
