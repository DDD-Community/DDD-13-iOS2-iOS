import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "HomeFeature",
  bundleId: .appBundleID(name: ".HomeFeature"),
  product: .staticFramework,
  settings: .settings(),
  dependencies: [
    .Shared(implements: .Shared),
    .Shared(implements: .Utill),
    .Shared(implements: .DesignSystem),
    .Domain(implements: .UseCase),
    .Domain(implements: .Entity),
    .Core(implements: .CoreDependencies),
    .SPM.composableArchitecture,
  ],
  sources: ["Sources/**"]
)
