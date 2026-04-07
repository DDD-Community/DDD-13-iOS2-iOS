import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "DataInterface",
  bundleId: .appBundleID(name: ".DataInterface"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
  .Data(implements: .Model),
  ],
  sources: ["Sources/**"],
  hasTests: false
)
