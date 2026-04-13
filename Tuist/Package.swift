// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
  productTypes: [
    "ComposableArchitecture": .staticFramework,
    "Moya": .staticFramework,
    "AsyncMoya": .staticFramework,
    "IssueReporting": .staticFramework,
    "XCTestDynamicOverlay": .staticFramework,
    "Clocks": .staticFramework,
    "ConcurrencyExtras": .staticFramework,
    "Sharing": .staticFramework
  ]
)
#endif

let package = Package(
  name: "MultiModuleTemplate",
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.25.0"),
    .package(url: "https://github.com/Roy-wonji/AsyncMoya", from: "1.1.8"),
    .package(url: "https://github.com/pointfreeco/swift-sharing", from: "1.0.0")
  ]
)
