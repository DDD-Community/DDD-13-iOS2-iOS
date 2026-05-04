import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "CoreDependencies",
  bundleId: .appBundleID(name: ".Dependencies"),
  product: .staticFramework,
  settings: .settings(),
  dependencies: [
    .Domain(implements: .Entity),
    .Domain(implements: .DomainInterface),
    .Domain(implements: .UseCase),
    .project(target: "DataUseCase", path: .relativeToRoot("Projects/Data/UseCase")),
    .Data(implements: .Repository),
    .Data(implements: .Service),
    .SPM.composableArchitecture
  ],
  sources: ["Sources/**"],
  hasTests: false
)
