import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Model",
  bundleId: .appBundleID(name: ".Model"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Domain(implements: .Entity)
  ],
  sources: ["Sources/**"],
  hasTests: false
)
