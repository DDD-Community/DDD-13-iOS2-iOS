import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "ThirdPartys",
  bundleId: .appBundleID(name: ".ThirdPartys"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .SPM.kakaoSDKCommon,
    .SPM.kakaoSDKAuth,
    .SPM.kakaoSDKUser,
    .SPM.kakaoSDKShare,
    .SPM.kakaoSDKTemplate
  ],
  sources: ["Sources/**"],
  hasTests: false
)
