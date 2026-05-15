import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Shared",
  bundleId: .appBundleID(name: ".Shared"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Shared(implements: .DesignSystem),
    .Shared(implements: .Utill),
  ],
  sources: ["Sources/**"],
  hasTests: false
)
