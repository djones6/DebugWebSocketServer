// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "DebugWebSocketServer",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.6.0"),
        .package(url: "https://github.com/IBM-Swift/Kitura-WebSocket.git", from: "2.0.0"),
        .package(url: "https://github.com/IBM-Swift/LoggerAPI.git", from: "1.8.0"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.8.0"),
    ],
    targets: [
        .target(
            name: "MyWebSocketService",
            dependencies: ["Kitura-WebSocket", "LoggerAPI", "HeliumLogger"]),
        .target(
            name: "DebugWebSocketServer",
            dependencies: ["Kitura", .target(name: "MyWebSocketService"), "LoggerAPI", "HeliumLogger"]),
    ]
)
