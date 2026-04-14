//
//  ProjectConfig.swift
//  MultiModuleTemplate
//
//  Created by DDD-iOS2 on 4/7/26.
//

import Foundation
import ProjectDescription

/// 🎯 프로젝트 설정을 한 곳에서 관리합니다
/// 여기서 프로젝트 이름을 바꾸면 모든 곳에 자동으로 적용됩니다!
public struct ProjectConfig {

    // MARK: - 🎯 프로젝트 이름 설정 (여기만 바꾸면 됩니다!)
    /// 프로젝트 이름을 여기서 설정하세요
    public static let projectName: String = "Bangawo"

    // MARK: - 📱 앱 정보 (자동 생성됨)
    public static let appName = projectName
    public static let appDisplayName = projectName  // 🎯 앱 화면에 표시될 이름
    public static let appStageName = "\(projectName)-Stage"
    public static let appProdName = "\(projectName)-Prod"
    public static let appDevName = "\(projectName)-Dev"

    // MARK: - 🔧 기타 설정
    public static let bundleIdPrefix = "com.ddd-ios2.Bangawo"
    public static let teamId = "DH9CS7PA5D"
    public static let deploymentTarget: ProjectDescription.DeploymentTargets = .iOS("26.0")
    public static let deploymentDestination: ProjectDescription.Destinations = [.iPhone]
    public static let appVersion = "1.0.0"

    // MARK: - 🎨 테마 설정 (필요시 수정)
    public static let organizationName = "Roy"
    public static let description = "🎵 Multi-module application template"
}

// MARK: - 🛠 Helper Extensions
public extension ProjectConfig {
    /// 워크스페이스 이름 (프로젝트 이름과 동일)
    static var workspaceName: String {
        return projectName
    }

    /// 메인 번들 ID
    static var mainBundleId: String {
        return bundleIdPrefix
    }
}
