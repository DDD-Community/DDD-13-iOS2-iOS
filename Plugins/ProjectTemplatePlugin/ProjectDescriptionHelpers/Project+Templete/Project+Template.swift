//
//  Project+Template.swift
//  MyPlugin
//
//  Created by DDD-iOS2 on 4/7/26.
//

import ProjectDescription

public extension Project {
  static func makeAppModule(
    name: String = Environment.appName,
    bundleId: String,
    platform: Platform = .iOS,
    product: Product,
    packages: [Package] = [],
    deploymentTarget: ProjectDescription.DeploymentTargets = Environment.deploymentTarget,
    destinations: ProjectDescription.Destinations = Environment.deploymentDestination,
    settings: ProjectDescription.Settings,
    scripts: [ProjectDescription.TargetScript] = [],
    dependencies: [ProjectDescription.TargetDependency] = [],
    sources: ProjectDescription.SourceFilesList = ["Sources/**"],
    resources: ProjectDescription.ResourceFileElements? = nil,
    infoPlist: ProjectDescription.InfoPlist = .default,
    entitlements: ProjectDescription.Entitlements? = nil,
    schemes: [ProjectDescription.Scheme] = []
  ) -> Project {

    let appTarget: Target = .target(
      name: name,
      destinations: destinations,
      product: product,
      bundleId: bundleId,
      deploymentTargets: deploymentTarget,
      infoPlist: infoPlist,
      sources: sources,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies
    )

    let appProdTarget: Target = .target(
      name: "\(name)-Prod",
      destinations: destinations,
      product: product,
      bundleId: "\(bundleId)",
      deploymentTargets: deploymentTarget,
      infoPlist: infoPlist,
      sources: sources,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies
    )


    let appStageTarget: Target = .target(
      name: "\(name)-Stage",
      destinations: destinations,
      product: product,
      bundleId: "\(bundleId)",
      deploymentTargets: deploymentTarget,
      infoPlist: infoPlist,
      sources: sources,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies
    )


    let appDevTarget: Target = .target(
      name: "\(name)-Debug",
      destinations: destinations,
      product: product,
      bundleId: "\(bundleId)",
      deploymentTargets: deploymentTarget,
      infoPlist: infoPlist,
      sources: sources,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies
    )

    let appTestTarget : Target = .target(
      name: "\(name)Tests",
      destinations: destinations,
      product: .unitTests,
      bundleId: "\(bundleId).\(name)Tests",
      deploymentTargets: deploymentTarget,
      infoPlist: .default,
      sources: ["Tests/Sources/**"],
      dependencies: [.target(name: name)]
    )

    let targets = [appTarget, appDevTarget, appStageTarget, appProdTarget ,appTestTarget]

    return Project(
      name: name,
      options: .options(
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko"
      ),
      packages: packages,
      settings: settings,
      targets: targets,
      schemes: schemes
    )
  }

  static func makeModule(
    name: String = Environment.appName,
    bundleId: String,
    platform: Platform = .iOS,
    product: Product,
    packages: [Package] = [],
    deploymentTarget: ProjectDescription.DeploymentTargets = Environment.deploymentTarget,
    destinations: ProjectDescription.Destinations = Environment.deploymentDestination,
    settings: ProjectDescription.Settings,
    scripts: [ProjectDescription.TargetScript] = [],
    dependencies: [ProjectDescription.TargetDependency] = [],
    sources: ProjectDescription.SourceFilesList = ["Sources/**"],
    resources: ProjectDescription.ResourceFileElements? = nil,
    infoPlist: ProjectDescription.InfoPlist = .default,
    entitlements: ProjectDescription.Entitlements? = nil,
    schemes: [ProjectDescription.Scheme] = [],
    hasTests: Bool = false
  ) -> Project {
    
    let appTarget: Target = .target(
      name: name,
      destinations: destinations,
      product: product,
      bundleId: bundleId,
      deploymentTargets: deploymentTarget,
      infoPlist: infoPlist,
      sources: sources,
      resources: resources,
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies
    )

    var targets = [appTarget]

    if hasTests {
      let appTestTarget : Target = .target(
        name: "\(name)Tests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(bundleId).\(name)Tests",
        deploymentTargets: deploymentTarget,
        infoPlist: .default,
        sources: ["Tests/Sources/**"],
        dependencies: [.target(name: name)]
      )
      targets.append(appTestTarget)
    }
    
    return Project(
      name: name,
      packages: packages,
      settings: settings,
      targets: targets,
      schemes: schemes
    )
  }
}



extension Scheme {
  public static func makeScheme(target configuration: ConfigurationName, name: String) -> Scheme {
    return Scheme.scheme(
      name: name,
      shared: true,
      buildAction: .buildAction(
        targets: [.target(name)]
      ),
      testAction: .targets(
        ["\(name)Tests"],
        configuration: configuration,
        options: .options(
          coverage: true,
          codeCoverageTargets: [.target(name)]
        )
      ),
      runAction: RunAction.runAction(configuration: configuration),
      archiveAction: .archiveAction(configuration: configuration),
      profileAction: ProfileAction.profileAction(configuration: configuration),
      analyzeAction: .analyzeAction(configuration: configuration)
    )
  }

  public static func makeTestPlanScheme(target: ConfigurationName, name: String) -> Scheme {
    return Scheme.scheme(
      name: name,
      shared: true,
      buildAction: .buildAction(targets: ["\(name)", "\(name)Tests"]),
      testAction: .testPlans(["Tests/Sources/\(name)TestPlan.xctestplan"]),
      runAction: RunAction.runAction(configuration: "Debug"),
      archiveAction: .archiveAction(configuration: "Debug"),
      profileAction: ProfileAction.profileAction(configuration: "Debug"),
      analyzeAction: .analyzeAction(configuration: "Debug")
    )
  }
}


public extension Scheme {
    static func scheme(name: String, environment: ConfigurationEnvironment) -> Scheme {
        let appName = Project.Environment.appName
        let schemeName: String = (environment == .prod)
            ? appName
            : "\(appName)-\(environment.name)"

      return Scheme.scheme(
            name: schemeName,
            shared: true,
            buildAction: .buildAction(
              targets: [.target(name)]
            ),
            testAction: 
                .targets(
                  ["\(name)Tests"],
                  configuration: environment.configurationName,
                  options:.options(
                    coverage: true,
                    codeCoverageTargets: [.target(name)]
                  )
            ),
            runAction: RunAction.runAction(configuration: environment.configurationName),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: ProfileAction.profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: environment.configurationName)
        )
    }
}
