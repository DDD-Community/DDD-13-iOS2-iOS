//
//  ConfigurationEnvironment.swift
//  DependencyPackagePlugin
//
//  Created by DDD-iOS2 on 4/7/26.
//

import Foundation
import ProjectDescription

public enum ConfigurationEnvironment: CaseIterable {
    case dev, stage, prod

    public var name: String {
        switch self {
        case .dev:   "Dev"
        case .stage: "Stage"
        case .prod:  "Prod"
        }
    }

    /// 스킴 액션에서 쓰는 ConfigurationName
    public var configurationName: ConfigurationName {
        .init(stringLiteral: name)
    }

    /// 필요 시 빌드 최적화 레벨 매핑 (없으면 제거)
    public var buildOptimization: ConfigurationName {
        switch self {
        case .dev, .stage:   .debug
        case .prod: .release
        }
    }
}
