import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")
let bundleIdAttribute: Template.Attribute = .optional("bundle_id", default: "io.Roy.Module")
let teamIdAttribute: Template.Attribute = .optional("team_id", default: "N94CS4N6VR")

let template = Template(
    description: "멀티 모듈 iOS 프로젝트 템플릿",
    attributes: [
        nameAttribute,
        bundleIdAttribute,
        teamIdAttribute
    ],
    items: [
        // 전체 프로젝트 구조 복사
        .directory(
            path: ".",
            sourcePath: "../../../"
        ),
        // Project+Environment.swift 파일을 동적으로 생성
        .string(
            path: "Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Project+Templete/Project+Enviorment.swift",
            contents: """
//
//  Project+Enviorment.swift
//  MyPlugin
//
//  Created by DDD-iOS2 on 4/7/26.
//

import Foundation
import ProjectDescription

public extension Project {
  enum Environment {
    public static let appName = "\(nameAttribute)"
    public static let appStageName = "\(nameAttribute)-Stage"
    public static let appProdName = "\(nameAttribute)-Prod"
    public static let appDevName = "\(nameAttribute)-Dev"
    public static let deploymentTarget : ProjectDescription.DeploymentTargets = .iOS("17.0")
    public static let deploymentDestination: ProjectDescription.Destinations = [.iPhone]
    public static let organizationTeamId = "\(teamIdAttribute)"
    public static let bundlePrefix = "\(bundleIdAttribute)"
    public static let appVersion = "1.0.0"
    public static let mainBundleId = "\(bundleIdAttribute)"
  }
}
"""
        )
    ]
)