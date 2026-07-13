//
//  ConfigurationEnvironment.swift
//  DependencyPackagePlugin
//

import Foundation
import ProjectDescription

public enum ConfigurationEnvironment: CaseIterable {
    case debug, prod

    public var name: String {
        switch self {
        case .debug: "Debug"
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
        case .debug: .debug
        case .prod: .release
        }
    }
}
