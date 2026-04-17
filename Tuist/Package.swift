// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
  productTypes: [
    "ComposableArchitecture": .staticFramework,
    "TCACoordinators": .staticFramework,
    "Moya": .staticFramework,
    "AsyncMoya": .staticFramework,
    "IssueReporting": .staticFramework,
    "XCTestDynamicOverlay": .staticFramework,
    "Clocks": .staticFramework,
    "ConcurrencyExtras": .staticFramework,
    "WeaveDI": .staticFramework,
    "Sharing": .staticFramework
  ],
  targetSettings: [
    "WeaveDICore": ["SWIFT_STRICT_CONCURRENCY": "minimal"],
    "WeaveDI": ["SWIFT_STRICT_CONCURRENCY": "minimal"],
    "ComposableArchitecture": ["SWIFT_STRICT_CONCURRENCY": "minimal"],
    "TCACoordinators": ["SWIFT_STRICT_CONCURRENCY": "minimal"],
    "AsyncMoya": ["SWIFT_STRICT_CONCURRENCY": "minimal"],
    "Moya": ["SWIFT_STRICT_CONCURRENCY": "minimal"],
    "CombineMoya": ["SWIFT_STRICT_CONCURRENCY": "minimal"],
    "RxMoya": ["SWIFT_STRICT_CONCURRENCY": "minimal"],
  ]
)
#endif

let package = Package(
  name: "MultiModuleTemplate",
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.18.0"),
    .package(url: "https://github.com/johnpatrickmorgan/TCACoordinators.git", exact: "0.11.1"),
    .package(url: "https://github.com/Roy-wonji/WeaveDI.git", from: "3.4.0"),
    .package(url: "https://github.com/Roy-wonji/AsyncMoya", from: "1.1.8"),
    .package(url: "https://github.com/pointfreeco/swift-sharing", from: "1.0.0")
  ]
)
