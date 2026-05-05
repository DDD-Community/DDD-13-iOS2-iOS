import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "DataInterface",
  bundleId: .appBundleID(name: ".DataInterface"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Domain(implements: .Entity),
  ],
  sources: ["Sources/**"],
  hasTests: false
)
