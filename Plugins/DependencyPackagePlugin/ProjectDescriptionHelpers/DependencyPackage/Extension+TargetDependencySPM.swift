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
  static let sharing = TargetDependency.external(name: "Sharing", condition: .none)
  static let kakaoMapsSDK = TargetDependency.external(name: "KakaoMapsSDK-SPM", condition: .none)
  static let kakaoSDKCommon = TargetDependency.external(name: "KakaoSDKCommon", condition: .none)
  static let kakaoSDKAuth = TargetDependency.external(name: "KakaoSDKAuth", condition: .none)
  static let kakaoSDKUser = TargetDependency.external(name: "KakaoSDKUser", condition: .none)
}
