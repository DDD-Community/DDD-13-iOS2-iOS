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
    .SPM.kakaoSDKUser
  ],
  sources: ["Sources/**"],
  hasTests: false
)
