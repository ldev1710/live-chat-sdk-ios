// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "LiveChatSDK",
    products: [
        .library(name: "LiveChatSDK", targets: ["LiveChatSDK","Firebase"])
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift", .upToNextMinor(from: "16.1.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMinor(from: "10.29.0"))
    ],
    targets: [
        .target(name: "LiveChatSDK", dependencies: ["SocketIO","Firebase"], path: "./LiveChatSDK"),
    ]
)
