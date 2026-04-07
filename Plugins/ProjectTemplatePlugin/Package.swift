// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MyPlugin",
    products: [
        .executable(name: "tuist-my-cli", targets: ["tuist-my-cli"]),
    ],
    targets: [
        .executableTarget(
            name: "tuist-my-cli"
        ),
    ]
)
