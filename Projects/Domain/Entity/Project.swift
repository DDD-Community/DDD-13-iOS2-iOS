import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Entity",
  bundleId: .appBundleID(name: ".Entity"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    
  ],
  sources: ["Sources/**"],
  hasTests: false
)
