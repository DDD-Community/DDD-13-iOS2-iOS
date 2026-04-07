import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "DomainInterface",
  bundleId: .appBundleID(name: ".DomainInterface"),
  product: .framework,
  settings:  .settings(),
  dependencies: [
    .Domain(implements: .Entity)
  ],
  sources: ["Sources/**"],
  hasTests: false
)
