import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "StationSearchFeature",
  bundleId: .appBundleID(name: ".StationSearchFeature"),
  product: .staticFramework,
  settings: .settings(),
  dependencies: [
    .Shared(implements: .Shared),
    .Shared(implements: .Utill),
    .Shared(implements: .DesignSystem),
    .Domain(implements: .Entity),
    .Core(implements: .CoreDependencies),
  ],
  sources: ["Sources/**"]
)
