import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Foundations",
  bundleId: .appBundleID(name: ".Foundations"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    
  ],
  sources: ["Sources/**"],
  hasTests: false
)
