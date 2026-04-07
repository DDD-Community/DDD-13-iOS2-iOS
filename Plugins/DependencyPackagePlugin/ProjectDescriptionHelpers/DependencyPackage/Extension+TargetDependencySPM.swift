//
//  Extension+TargetDependencySPM.swift
//  DependencyPackagePlugin
//
//  Created by DDD-iOS2 on 4/7/26.
//

import ProjectDescription

public extension TargetDependency.SPM {
  static let asyncMoya = TargetDependency.external(name: "AsyncMoya", condition: .none)
  static let composableArchitecture = TargetDependency.external(name: "ComposableArchitecture", condition: .none)
  static let tcaCoordinator = TargetDependency.external(name: "TCACoordinators", condition: .none)
  static let weaveDI = TargetDependency.external(name: "WeaveDI", condition: .none)
  static let sharing = TargetDependency.external(name: "Sharing", condition: .none)
}
