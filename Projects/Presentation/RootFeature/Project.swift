import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "RootFeature",
  bundleId: .appBundleID(name: ".RootFeature"),
  product: .staticFramework,
  settings: .settings(),
  dependencies: [
    .Presentation(implements: .AuthFlowFeature),
    .Presentation(implements: .HomeFeature),
    .Shared(implements: .Utill),
    .SPM.composableArchitecture,
  ],
  sources: ["Sources/**"],
  hasTests: true
)
