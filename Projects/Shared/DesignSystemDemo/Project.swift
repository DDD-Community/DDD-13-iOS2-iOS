import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "DesignSystemDemo",
  bundleId: .appBundleID(name: ".DesignSystemDemo"),
  product: .app,
  settings: .appBaseSetting(appName: "DesignSystemDemo"),
  dependencies: [
    .Shared(implements: .DesignSystem),
    .SPM.kakaoMapsSDK
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  infoPlist: .extendingDefault(
    with: [
      "KAKAO_APP_KEY": .string("$(KAKAO_DEMO_APP_KEY)"),
      "NSAppTransportSecurity": .dictionary([
        "NSAllowsArbitraryLoads": .boolean(true)
      ]),
      "UILaunchScreen": .dictionary([:])
    ]
  ),
  hasTests: false
)
