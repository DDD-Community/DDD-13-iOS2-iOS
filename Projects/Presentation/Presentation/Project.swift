import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Presentation",
  bundleId: .appBundleID(name: ".Presentation"),
  product: .staticFramework,
  settings: .settings(),
  dependencies: [
    .Presentation(implements: .AuthFlowFeature),
    .Presentation(implements: .HomeFeature),
    .Presentation(implements: .RootFeature),
    .Core(implements: .CoreDependencies),
    .Shared(implements: .Shared),
    .Domain(implements: .Entity),
    .Domain(implements: .DomainInterface)
  ],
  sources: ["Sources/**"]
)
