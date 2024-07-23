
import PackageDescription

let package = Package(
    name: "LiveChatSDK",
    products: [
        .library(name: "LiveChatSDK", targets: ["LiveChatSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift", .upToNextMinor(from: "15.0.0")),
    ],
    platforms: [
       .iOS(.v12),
    ],
    targets: [
        .target(name: "LiveChatSDK", dependencies: ["SocketIO"]),
    ]
)
