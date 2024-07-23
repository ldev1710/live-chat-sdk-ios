
import PackageDescription

let package = Package(
    name: "LiveChatSDK",
    products: [
        .library(name: "LiveChatSDK", targets: ["LiveChatSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift", from: "16.1.0"),
    ],
    targets: [
        .target(name: "LiveChatSDK", dependencies: ["SocketIO"]),
    ]
)
