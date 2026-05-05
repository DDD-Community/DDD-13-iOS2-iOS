import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "DataUseCase",
  bundleId: .appBundleID(name: ".DataUseCase"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Domain(implements: .Entity),
    .Domain(implements: .UseCase),
    .Domain(implements: .DataInterface),
  ],
  sources: ["Sources/**"],
  hasTests: true
)
