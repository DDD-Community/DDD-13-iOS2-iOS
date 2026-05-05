import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "AuthFlowFeature",
  bundleId: .appBundleID(name: ".AuthFlowFeature"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Shared(implements: .Shared),
    .Shared(implements: .Utill),
    .Shared(implements: .DesignSystem),
    .Domain(implements: .Entity),
    .Core(implements: .CoreDependencies),
  ],
  sources: ["Sources/**"]
)
