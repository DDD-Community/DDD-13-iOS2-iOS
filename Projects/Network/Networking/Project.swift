import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Networking",
  bundleId: .appBundleID(name: ".Networking"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Network(implements: .Foundations)
  ],
  sources: ["Sources/**"],
  hasTests: false
)
