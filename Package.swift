// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LiveChatSDK",
    platforms: [
        .iOS(.v14), // Đặt phiên bản iOS tối thiểu ở đây
    ],
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
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "SocketIO", package: "socket.io-client-swift")
            ],
            path: "./LiveChatSDK"
        ),
    ]
)
