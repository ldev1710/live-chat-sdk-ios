// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "LiveChatSDK",
    products: [
        .library(name: "LiveChatSDK", targets: ["LiveChatSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift", .upToNextMinor(from: "16.1.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.29.0")
    ],
    targets: [
        .target(
            name: "LiveChatSDK",
            dependencies: [
                "SocketIO",
                .product(name: "FirebaseMessaging", package: "Firebase"),
            ],
            path: "./LiveChatSDK"
        ),
    ]
)
