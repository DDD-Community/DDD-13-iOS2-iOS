import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "ProfileInputFeature",
  bundleId: .appBundleID(name: ".ProfileInputFeature"),
  product: .staticFramework,
  settings: .settings(),
  dependencies: [
    .Shared(implements: .Shared),
    .Shared(implements: .Utill),
    .Shared(implements: .DesignSystem),
    .Domain(implements: .Entity),
    .Core(implements: .CoreDependencies),
    .SPM.composableArchitecture,
  ],
  sources: ["Sources/**"],
  hasTests: true
)
