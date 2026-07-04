import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Service",
  bundleId: .appBundleID(name: ".Service"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Domain(implements: .Entity),
    .Domain(implements: .DomainInterface),
    .Shared(implements: .Utill),
    .SPM.kakaoSDKAuth,
    .SPM.kakaoSDKUser,
    .SPM.kakaoSDKShare,
    .SPM.kakaoSDKTemplate,
    .SPM.nidThirdPartyLogin
  ],
  sources: ["Sources/**"],
  hasTests: false
)
