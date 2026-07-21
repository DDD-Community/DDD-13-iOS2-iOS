import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeModule(
  name: "Presentation",
  bundleId: .appBundleID(name: ".Presentation"),
  product: .staticFramework,
  settings: .settings(),
  dependencies: [
    .Presentation(implements: .AuthFlowFeature),
    .Presentation(implements: .HomeFeature),
    .Presentation(implements: .ProfileInputFeature),
    .Presentation(implements: .RootFeature),
    .Presentation(implements: .StationSearchFeature),
  ],
  sources: ["Sources/**"]
)
