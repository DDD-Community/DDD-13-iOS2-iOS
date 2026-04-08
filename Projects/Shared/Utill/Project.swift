import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Utill",
  bundleId: .appBundleID(name: ".Utill"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [

  ],
  sources: ["Sources/**"],
  hasTests: false
)
