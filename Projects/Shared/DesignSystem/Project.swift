import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "DesignSystem",
  bundleId: .appBundleID(name: ".DesignSystem"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .SPM.kakaoMapsSDK
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**", "FontAsset/**"],
  hasTests: false,
  resourceSynthesizers: [
    .custom(
      name: "Colors",
      parser: .assets,
      extensions: ["xcassets"]
    ),
    .custom(
      name: "Images",
      parser: .assets,
      extensions: ["xcassets"]
    ),
    .fonts(),
    .custom(
      name: "Localizable",
      parser: .strings,
      extensions: ["strings", "stringsdict"]
    ),
  ]
)
