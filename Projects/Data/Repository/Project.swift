import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Repository",
  bundleId: .appBundleID(name: ".Repository"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Network(implements: .Networking),
    .Domain(implements: .DataInterface)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
