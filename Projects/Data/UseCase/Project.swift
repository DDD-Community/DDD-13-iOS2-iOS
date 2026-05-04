import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "DataUseCase",
  bundleId: .appBundleID(name: ".DataUseCase"),
  product: .staticFramework,
  settings: .settings(),
  dependencies: [
    .Domain(implements: .Entity),
    .Domain(implements: .UseCase),
    .Domain(implements: .DomainInterface),
    .Domain(implements: .DataInterface),
    .Data(implements: .Service),
    .Shared(implements: .Utill)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
