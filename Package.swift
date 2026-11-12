// swift-tools-version: 6.0
import PackageDescription

// The Whisper Memos Mac helper. No dependencies: it talks to our worker over a WebSocket.
let package = Package(
    name: "WhisperMemosHelper",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(name: "WhisperMemosHelper"),
        .testTarget(name: "WhisperMemosHelperTests", dependencies: ["WhisperMemosHelper"]),
    ],
    swiftLanguageModes: [.v5]
)
