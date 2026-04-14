import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "UseCase",
  bundleId: .appBundleID(name: ".UseCase"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Data(implements: .Repository),
    .Domain(implements: .DomainInterface),
    .SPM.composableArchitecture,
  ],
  sources: ["Sources/**"],
  hasTests: true
)
