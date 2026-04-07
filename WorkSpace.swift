//
//  WorkSpace.swift
//  Manifests
//
//  Created by DDD-iOS2 on 4/7/26.
//

import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let workspaceName: String = {
    if let projectName = ProcessInfo.processInfo.environment["PROJECT_NAME"] {
        print("🔍 PROJECT_NAME 환경변수 발견: \(projectName)")
        return projectName
    } else {
        print("🎵 ProjectConfig에서 프로젝트 이름 사용: \(ProjectConfig.projectName)")
        return ProjectConfig.projectName
    }
}()

let workspace = Workspace(
name: workspaceName,
projects: [
    "Projects/**"
])
