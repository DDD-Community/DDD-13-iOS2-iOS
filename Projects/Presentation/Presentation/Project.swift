import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Presentation",
  bundleId: .appBundleID(name: ".Presentation"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .project(target: "CoreDependencies", path: .relativeToRoot("Projects/Core/Dependencies")),
    .Shared(implements: .Shared),
    .Domain(implements: .Entity),
    .Domain(implements: .DomainInterface)
  ],
  sources: ["Sources/**"]
)
