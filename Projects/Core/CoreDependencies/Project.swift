import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "CoreDependencies",
  bundleId: .appBundleID(name: ".CoreDependencies"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Domain(implements: .Entity),
    .Domain(implements: .DomainInterface),
    .Domain(implements: .UseCase),
    .SPM.composableArchitecture,
  ],
  sources: ["Sources/**"],
  hasTests: false
)
