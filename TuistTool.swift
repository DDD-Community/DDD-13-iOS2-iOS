//
//  tuisttool.swift
//

import Foundation

// 🆕 Tuist 4.174.0+ mise를 통한 실행 헬퍼
@discardableResult
func runTuist(arguments: [String] = []) -> Int32 {
  return run("mise", arguments: ["exec", "--", "tuist"] + arguments)
}

@discardableResult
func run(_ command: String, arguments: [String] = []) -> Int32 {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
  process.arguments = [command] + arguments
  process.standardOutput = FileHandle.standardOutput
  process.standardError = FileHandle.standardError

  // 🔥 현재 프로세스의 환경변수를 자식 프로세스에 전달
  var environment = ProcessInfo.processInfo.environment

  // setenv로 설정된 환경변수들을 수동으로 추가
  if let projectName = getenv("PROJECT_NAME") {
    environment["PROJECT_NAME"] = String(cString: projectName)
  }
  if let bundleId = getenv("BUNDLE_ID_PREFIX") {
    environment["BUNDLE_ID_PREFIX"] = String(cString: bundleId)
  }
  if let teamId = getenv("TEAM_ID") {
    environment["TEAM_ID"] = String(cString: teamId)
  }

  process.environment = environment

  do {
    try process.run()
    process.waitUntilExit()
    return process.terminationStatus
  } catch {
    print("❌ 실행 실패: \(error)")
    return -1
  }
}

func runCapture(_ command: String, arguments: [String] = []) throws -> String {
  let process = Process()
  let pipe = Pipe()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
  process.arguments = [command] + arguments
  process.standardOutput = pipe
  try process.run()
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
}

func prompt(_ message: String) -> String {
  print("\(message): ", terminator: "")
  fflush(stdout) // Force flush output buffer

  guard let input = readLine() else {
    return ""
  }

  let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)

  // Debug output (개발시에만 활성화)
  // print("🔍 Debug: 입력된 값 = '\(trimmedInput)' (길이: \(trimmedInput.count))")

  return trimmedInput
}

// MARK: - Tuist 명령어 (tuist 4.97.2 최적화)
func generate() {
  // ✅ 루트 경로 환경 변수 설정
  setenv("TUIST_ROOT_DIR", FileManager.default.currentDirectoryPath, 1)

  // ✅ 프리뷰 모드 환경 변수 추가
  setenv("TUIST_FOR_PREVIEW", "TRUE", 1)

  // 📁 기존 hasTests: true 모듈들의 Tests/Sources 디렉토리 확인 (하위 호환성)
  ensureTestsDirectoriesForHasTestsModules()

  // ✅ tuist generate 실행 (4.174.0+)
  runTuist(arguments: ["generate"])
}

// tuist 4.97.2 새로운 기능들
func inspect() {
    print("🔍 사용 가능한 inspect 명령어들:")
    run("tuist", arguments: ["inspect", "--help"])
}

func inspectImplicitImports() {
    print("🔍 암시적 의존성 검사 중...")
    run("tuist", arguments: ["inspect", "implicit-imports"])
}

func inspectCodeCoverage() {
    print("📊 코드 커버리지 분석 중...")
    run("tuist", arguments: ["inspect", "code-coverage"])
}

// MARK: - 새 프로젝트 생성
func newProject() {
    print("\n🚀 새 프로젝트 생성을 시작합니다.")

    let projectName = prompt("프로젝트 이름을 입력하세요")
    guard !projectName.isEmpty else {
        print("❌ 프로젝트 이름은 필수입니다.")
        return
    }

    let bundleIdPrefix = prompt("번들 ID 접두사를 입력하세요 (기본값: io.Roy.Module)")
    let finalBundleId = bundleIdPrefix.isEmpty ? "io.Roy.Module" : bundleIdPrefix

    let teamId = prompt("팀 ID를 입력하세요 (기본값: N94CS4N6VR)")
    let finalTeamId = teamId.isEmpty ? "N94CS4N6VR" : teamId

    print("\n📋 설정 정보:")
    print("📱 프로젝트명: \(projectName)")
    print("📦 번들 ID 접두사: \(finalBundleId)")
    print("👥 팀 ID: \(finalTeamId)")

    let confirm = prompt("\n위 설정으로 프로젝트를 생성하시겠습니까? (y/N)")
    guard confirm.lowercased() == "y" else {
        print("❌ 프로젝트 생성이 취소되었습니다.")
        return
    }

    generateProjectWithSettings(
        name: projectName,
        bundleIdPrefix: finalBundleId,
        teamId: finalTeamId
    )
}

func generateProjectWithArgs() {
    let args = Array(CommandLine.arguments.dropFirst(2)) // command와 하위 명령 제외

    guard args.count >= 1 else {
        print("사용법: ./tuisttool generate --name <프로젝트명> [--bundle-id <번들ID>] [--team-id <팀ID>]")
        return
    }

    var projectName = ""
    var bundleIdPrefix = "io.Roy.Module"
    var teamId = "N94CS4N6VR"

    var i = 0
    while i < args.count {
        switch args[i] {
        case "--name", "-n":
            if i + 1 < args.count {
                projectName = args[i + 1]
                i += 1
            }
        case "--bundle-id", "-b":
            if i + 1 < args.count {
                bundleIdPrefix = args[i + 1]
                i += 1
            }
        case "--team-id", "-t":
            if i + 1 < args.count {
                teamId = args[i + 1]
                i += 1
            }
        default:
            if projectName.isEmpty {
                projectName = args[i]
            }
        }
        i += 1
    }

    guard !projectName.isEmpty else {
        print("❌ 프로젝트 이름은 필수입니다.")
        print("사용법: ./tuisttool newproject <프로젝트명> [--bundle-id <번들ID>] [--team-id <팀ID>]")
        return
    }

    generateProjectWithSettings(
        name: projectName,
        bundleIdPrefix: bundleIdPrefix,
        teamId: teamId
    )
}

func generateProjectWithSettings(name: String, bundleIdPrefix: String, teamId: String) {
    print("\n⚙️ 환경변수 설정 중...")
    setenv("PROJECT_NAME", name, 1)
    setenv("BUNDLE_ID_PREFIX", bundleIdPrefix, 1)
    setenv("TEAM_ID", teamId, 1)

    // 🚨 중요: tuist generate 전에 필수 디렉토리들 미리 생성
    print("📁 필수 디렉토리 사전 생성 중...")

    // 1. 기본 테스트 디렉토리 생성 (템플릿에 필요)
    ensureDirectoryExists(at: "Projects/App/Tests")
    ensureDirectoryExists(at: "Projects/App/Tests/Sources")

    // 2. FontAsset 디렉토리 생성 (경고 해결)
    ensureDirectoryExists(at: "Projects/Shared/DesignSystem/FontAsset")

    print("📁 디렉토리 생성 완료:")
    print("   - Tests: \(FileManager.default.fileExists(atPath: "Projects/App/Tests") ? "✅" : "❌")")
    print("   - FontAsset: \(FileManager.default.fileExists(atPath: "Projects/Shared/DesignSystem/FontAsset") ? "✅" : "❌")")

    // 기본 테스트 파일 생성 (없으면)
    let originalTestFilePath = "Projects/App/Tests/Sources/\(name)Tests.swift"
    if !FileManager.default.fileExists(atPath: originalTestFilePath) {
        let testFileContent = """
        //
        //  \(name)Tests.swift
        //  \(name)Tests
        //
        //  Created by TuistTool.
        //

        import XCTest

        final class \(name)Tests: XCTestCase {

            override func setUpWithError() throws {
                // Put setup code here.
            }

            override func tearDownWithError() throws {
                // Put teardown code here.
            }

            func testExample() throws {
                // This is an example of a functional test case.
            }

            func testPerformanceExample() throws {
                // This is an example of a performance test case.
                self.measure {
                    // Put the code you want to measure the time of here.
                }
            }

        }
        """

        do {
            try testFileContent.write(toFile: originalTestFilePath, atomically: true, encoding: .utf8)
            print("✅ 기본 테스트 파일 생성: \(originalTestFilePath)")
        } catch {
            print("⚠️ 기본 테스트 파일 생성 실패: \(error)")
        }
    }

    print("🧹 기존 프로젝트 정리 중...")
    _ = run("tuist", arguments: ["clean"])

    // 기존 워크스페이스 파일들 삭제
    let filesToRemove = [
        "MultiModuleTemplate.xcworkspace",
        "\(name).xcworkspace"  // 혹시 이미 있을 수도 있으니
    ]

    for file in filesToRemove {
        if FileManager.default.fileExists(atPath: file) {
            do {
                try FileManager.default.removeItem(atPath: file)
                print("🗑️ 기존 워크스페이스 삭제: \(file)")
            } catch {
                print("⚠️ 워크스페이스 삭제 실패 (\(file)): \(error)")
            }
        }
    }

    print("🔧 Tuist dependencies 설치 중...")
    let installResult = run("tuist", arguments: ["install"])
    if installResult != 0 {
        print("❌ Dependencies 설치에 실패했습니다.")
        return
    }

    // 🚨 중요: tuist generate 전에 이름 변경 수행!
    prepareTemplateForNewProject(oldName: "MultiModuleTemplate", newName: name, bundleIdPrefix: bundleIdPrefix, teamId: teamId)

    // 💯 이름 변경 완료 후 최종 검증
    print("🔍 이름 변경 최종 검증 중...")
    let projectConfigPath = "Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Project+Templete/ProjectConfig.swift"
    if let content = try? String(contentsOfFile: projectConfigPath, encoding: .utf8) {
        if content.contains("projectName: String = \"\(name)\"") {
            print("✅ 최종 검증 성공: ProjectConfig.swift에서 \(name) 확인됨")
        } else {
            print("❌ 최종 검증 실패: ProjectConfig.swift에서 \(name)을 찾을 수 없음")
            print("   현재 프로젝트명 라인:")
            let lines = content.components(separatedBy: .newlines)
            for (i, line) in lines.enumerated() {
                if line.contains("projectName") {
                    print("   라인 \(i+1): \(line)")
                }
            }
            print("❌ 프로젝트 생성을 중단합니다.")
            return
        }
    }

    print("🔧 Tuist 프로젝트 생성 중...")
    let result = run("tuist", arguments: ["generate"])

    if result == 0 {
        print("✅ Tuist 프로젝트 생성 성공!")

        // 생성된 워크스페이스 확인 및 이름 변경
        let expectedWorkspaceName = "\(name).xcworkspace"
        let oldWorkspaceName = "MultiModuleTemplate.xcworkspace"

        print("🔍 생성된 워크스페이스 확인 중...")

        // 새 이름으로 이미 생성되었는지 확인
        if FileManager.default.fileExists(atPath: expectedWorkspaceName) {
            print("✅ 올바른 이름의 워크스페이스 생성됨: \(expectedWorkspaceName)")
        }
        // 아직 옛날 이름으로 생성되었다면 이름 변경
        else if FileManager.default.fileExists(atPath: oldWorkspaceName) {
            do {
                try FileManager.default.moveItem(atPath: oldWorkspaceName, toPath: expectedWorkspaceName)
                print("📝 Workspace 이름 변경: \(oldWorkspaceName) → \(expectedWorkspaceName)")
            } catch {
                print("⚠️ Workspace 이름 변경 실패: \(error)")
            }
        }
        else {
            print("⚠️ 예상된 워크스페이스 파일을 찾을 수 없습니다")
            // 현재 디렉토리의 .xcworkspace 파일들 확인
            if let files = try? FileManager.default.contentsOfDirectory(atPath: ".") {
                let workspaceFiles = files.filter { $0.hasSuffix(".xcworkspace") }
                print("   현재 디렉토리의 워크스페이스 파일들: \(workspaceFiles)")
            }
        }

        // renameProjectArtifacts는 이미 prepareTemplateForNewProject에서 호출됨

        print("\n✅ 프로젝트 '\(name)'이 성공적으로 생성되었습니다!")
        print("💡 다음 명령어로 Xcode에서 열 수 있습니다:")
        print("   open \(expectedWorkspaceName)")
    } else {
        print("❌ 프로젝트 생성에 실패했습니다.")
    }
}

private func prepareTemplateForNewProject(oldName: String, newName: String, bundleIdPrefix: String, teamId: String) {
    print("🔄 템플릿 준비 중...")
    print("   - 이전 이름: \(oldName)")
    print("   - 새 이름: \(newName)")
    print("   - 번들 ID: \(bundleIdPrefix)")
    print("   - 팀 ID: \(teamId)")

    // 1단계: 프로젝트 아티팩트 이름 변경
    renameProjectArtifacts(oldName: oldName, newName: newName)

    // 2단계: 환경 설정 파일 업데이트
    updateEnvironmentDefaults(oldName: oldName, newName: newName, bundleIdPrefix: bundleIdPrefix, teamId: teamId)

    // 3단계: ProjectConfig.swift 업데이트 (핵심!)
    updateProjectConfig(newName: newName, bundleIdPrefix: bundleIdPrefix, teamId: teamId)

    // 4단계: xconfig 파일들 업데이트
    updateXConfigFiles(newName: newName)

    // 5단계: 검증
    verifyNameChange(oldName: oldName, newName: newName)
}

private func renameProjectArtifacts(oldName: String, newName: String) {
    guard oldName != newName else { return }

    let appRoot = "Projects/App"

    let oldProjectPath = "\(appRoot)/\(oldName).xcodeproj"
    let newProjectPath = "\(appRoot)/\(newName).xcodeproj"
    renameItemIfNeeded(at: oldProjectPath, to: newProjectPath, description: ".xcodeproj 이동")

    updateXcodeProjectContent(at: newProjectPath, oldName: oldName, newName: newName)

    let oldTestsFolder = "\(appRoot)/\(oldName)Tests"
    let newTestsFolder = "\(appRoot)/\(newName)Tests"
    renameItemIfNeeded(at: oldTestsFolder, to: newTestsFolder, description: "테스트 타겟 폴더 이동")

    // 테스트 디렉토리 강제 생성 (더 확실하게)
    ensureDirectoryExists(at: newTestsFolder)
    ensureDirectoryExists(at: "\(newTestsFolder)/Sources")

    print("📁 테스트 디렉토리 확인:")
    print("   - \(newTestsFolder): \(FileManager.default.fileExists(atPath: newTestsFolder) ? "✅" : "❌")")
    print("   - \(newTestsFolder)/Sources: \(FileManager.default.fileExists(atPath: "\(newTestsFolder)/Sources") ? "✅" : "❌")")

    let oldTestFile = "\(newTestsFolder)/Sources/\(oldName)Tests.swift"
    let newTestFile = "\(newTestsFolder)/Sources/\(newName)Tests.swift"
    renameItemIfNeeded(at: oldTestFile, to: newTestFile, description: "테스트 파일 이름 변경")
    replaceOccurrences(inFileAtPath: newTestFile, replacements: [oldName: newName, "\(oldName)Tests": "\(newName)Tests"])

    let applicationSourcesPath = "\(appRoot)/Sources/Application"
    let oldAppFile = "\(applicationSourcesPath)/\(oldName)App.swift"
    let newAppFile = "\(applicationSourcesPath)/\(newName)App.swift"
    renameItemIfNeeded(at: oldAppFile, to: newAppFile, description: "App Entry 파일 이름 변경")
    replaceOccurrences(
        inFileAtPath: newAppFile,
        replacements: [
            "\(oldName)App": "\(newName)App",
            "TuistAssets+\(oldName)": "TuistAssets+\(newName)",
            "TuistBundle+\(oldName)": "TuistBundle+\(newName)"
        ]
    )
}

private func renameItemIfNeeded(at oldPath: String, to newPath: String, description: String) {
    let fileManager = FileManager.default
    guard oldPath != newPath else { return }
    guard fileManager.fileExists(atPath: oldPath) else { return }

    do {
        if fileManager.fileExists(atPath: newPath) {
            try fileManager.removeItem(atPath: newPath)
        }
        try fileManager.moveItem(atPath: oldPath, toPath: newPath)
    } catch {
        print("⚠️ \(description) 실패: \(error)")
    }
}

private func ensureDirectoryExists(at path: String) {
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: path) {
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("⚠️ 디렉토리 생성 실패 (\(path)): \(error)")
        }
    }
}

// MARK: - Tests 디렉토리 자동 생성
private func ensureTestsDirectoriesForHasTestsModules() {
    print("🔍 hasTests: true인 모듈들의 Tests/Sources 디렉토리 확인 중...")

    let fileManager = FileManager.default
    guard let enumerator = fileManager.enumerator(atPath: "Projects") else {
        print("⚠️ Projects 디렉토리를 찾을 수 없습니다")
        return
    }

    var createdCount = 0
    var existingCount = 0

    while let relativePath = enumerator.nextObject() as? String {
        guard relativePath.hasSuffix("Project.swift") else { continue }

        let fullPath = "Projects/\(relativePath)"
        let projectDir = URL(fileURLWithPath: fullPath).deletingLastPathComponent().path

        // Project.swift 파일에서 hasTests: true 확인
        do {
            let content = try String(contentsOfFile: fullPath, encoding: .utf8)
            if content.contains("hasTests: true") {
                let testsSourcesPath = "\(projectDir)/Tests/Sources"

                if !fileManager.fileExists(atPath: testsSourcesPath) {
                    ensureDirectoryExists(at: testsSourcesPath)
                    print("📁 Created Tests/Sources for \(URL(fileURLWithPath: projectDir).lastPathComponent)")
                    createdCount += 1
                } else {
                    existingCount += 1
                }
            }
        } catch {
            print("⚠️ \(fullPath) 파일 읽기 실패: \(error)")
        }
    }

    if createdCount > 0 {
        print("✅ \(createdCount)개의 Tests/Sources 디렉토리가 생성되었습니다")
    }
    if existingCount > 0 {
        print("ℹ️ \(existingCount)개의 Tests/Sources 디렉토리가 이미 존재합니다")
    }
    if createdCount == 0 && existingCount == 0 {
        print("ℹ️ hasTests: true인 모듈을 찾을 수 없습니다")
    }
}

private func updateEnvironmentDefaults(oldName: String, newName: String, bundleIdPrefix: String, teamId: String) {
    let environmentPath = "Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Project+Templete/Project+Enviorment.swift"

    print("🔧 Project+Environment.swift 업데이트 중...")

    guard FileManager.default.fileExists(atPath: environmentPath) else {
        print("⚠️ Environment 파일을 찾을 수 없습니다: \(environmentPath)")
        return
    }

    do {
        var content = try String(contentsOfFile: environmentPath, encoding: .utf8)
        let originalContent = content

        // ProjectConfig.projectName 참조로 변경 (하드코딩 제거)
        let projectNamePattern = #"return \"[^\"]+\""#
        let projectNameReplacement = "return ProjectConfig.projectName"
        content = content.replacingOccurrences(of: projectNamePattern, with: projectNameReplacement, options: .regularExpression)

        // 기존 하드코딩된 값들 업데이트 (백업용)
        content = content.replacingOccurrences(of: #"BUNDLE_ID_PREFIX"] ?? \"[^\"]+\""#, with: "BUNDLE_ID_PREFIX\"] ?? \"\(bundleIdPrefix)\"", options: .regularExpression)
        content = content.replacingOccurrences(of: #"TEAM_ID"] ?? \"[^\"]+\""#, with: "TEAM_ID\"] ?? \"\(teamId)\"", options: .regularExpression)

        // 이전 이름을 새 이름으로 바꾸기
        content = content.replacingOccurrences(of: oldName, with: newName)

        if content != originalContent {
            try content.write(toFile: environmentPath, atomically: true, encoding: .utf8)
            print("✅ Project+Environment.swift 업데이트 완료")
        } else {
            print("ℹ️ Project+Environment.swift 변경사항 없음")
        }

    } catch {
        print("❌ Environment 파일 업데이트 실패: \(error)")
    }
}

private func updateXcodeProjectContent(at projectPath: String, oldName: String, newName: String) {
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: projectPath) else { return }

    let pbxprojPath = "\(projectPath)/project.pbxproj"
    replaceOccurrences(
        inFileAtPath: pbxprojPath,
        replacements: [
            "\(oldName)": "\(newName)",
            "\(oldName)Tests": "\(newName)Tests"
        ]
    )

    let schemesDirectory = "\(projectPath)/xcshareddata/xcschemes"
    guard let schemes = try? fileManager.contentsOfDirectory(atPath: schemesDirectory) else { return }

    for scheme in schemes where scheme.contains(oldName) {
        let oldSchemePath = "\(schemesDirectory)/\(scheme)"
        let newSchemeName = scheme.replacingOccurrences(of: oldName, with: newName)
        let newSchemePath = "\(schemesDirectory)/\(newSchemeName)"
        renameItemIfNeeded(at: oldSchemePath, to: newSchemePath, description: "스킴 파일 이름 변경")
        replaceOccurrences(inFileAtPath: newSchemePath, replacements: [oldName: newName])
    }
}

private func replaceOccurrences(inFileAtPath path: String, replacements: [String: String]) {
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: path) else { return }

    do {
        var content = try String(contentsOfFile: path, encoding: .utf8)
        var updated = false
        for (target, replacement) in replacements {
            if content.contains(target) {
                content = content.replacingOccurrences(of: target, with: replacement)
                updated = true
            }
        }

        if updated {
            try content.write(toFile: path, atomically: true, encoding: .utf8)
        }
    } catch {
        print("⚠️ 문자열 치환 실패 (\(path)): \(error)")
    }
}

private func replacePattern(inFileAtPath path: String, pattern: String, replacement: String) {
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: path) else { return }

    do {
        let content = try String(contentsOfFile: path, encoding: .utf8)
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: (content as NSString).length)
        let template = NSRegularExpression.escapedTemplate(for: replacement)
        let newContent = regex.stringByReplacingMatches(in: content, options: [], range: range, withTemplate: template)
        if newContent != content {
            try newContent.write(toFile: path, atomically: true, encoding: .utf8)
        }
    } catch {
        print("⚠️ 문자열 패턴 치환 실패 (\(path)): \(error)")
    }
}

// MARK: - 핵심 ProjectConfig.swift 업데이트 함수 (강화 버전)
private func updateProjectConfig(newName: String, bundleIdPrefix: String, teamId: String) {
    let projectConfigPath = "Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Project+Templete/ProjectConfig.swift"

    print("🔧 ProjectConfig.swift 업데이트 중...")
    print("   - 새 이름: \(newName)")
    print("   - 파일 경로: \(projectConfigPath)")

    guard FileManager.default.fileExists(atPath: projectConfigPath) else {
        print("❌ ProjectConfig.swift 파일을 찾을 수 없습니다: \(projectConfigPath)")
        return
    }

    do {
        var content = try String(contentsOfFile: projectConfigPath, encoding: .utf8)
        let originalContent = content
        print("📄 원본 파일 크기: \(content.count) 문자")

        // 1. 더 강력한 프로젝트 이름 업데이트 (여러 패턴 시도)
        let patterns = [
            (#"public static let projectName: String = "[^"]*""#, "public static let projectName: String = \"\(newName)\""),
            (#"projectName: String = "[^"]*""#, "projectName: String = \"\(newName)\""),
            (#"let projectName: String = "[^"]*""#, "let projectName: String = \"\(newName)\""),
            (#"= "MultiModuleTemplate""#, "= \"\(newName)\"")  // 직접 매칭
        ]

        var updateCount = 0
        for (pattern, replacement) in patterns {
            let beforeUpdate = content
            content = content.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
            if content != beforeUpdate {
                updateCount += 1
                print("✅ 패턴 매칭 성공: \(pattern)")
            }
        }

        // 2. 번들 ID 접두사 업데이트
        let bundleIdPatterns = [
            (#"public static let bundleIdPrefix = "[^"]*""#, "public static let bundleIdPrefix = \"\(bundleIdPrefix)\""),
            (#"bundleIdPrefix = "[^"]*""#, "bundleIdPrefix = \"\(bundleIdPrefix)\"")
        ]

        for (pattern, replacement) in bundleIdPatterns {
            let beforeUpdate = content
            content = content.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
            if content != beforeUpdate {
                updateCount += 1
                print("✅ 번들 ID 업데이트 성공")
            }
        }

        // 3. 팀 ID 업데이트
        let teamIdPatterns = [
            (#"public static let teamId = "[^"]*""#, "public static let teamId = \"\(teamId)\""),
            (#"teamId = "[^"]*""#, "teamId = \"\(teamId)\"")
        ]

        for (pattern, replacement) in teamIdPatterns {
            let beforeUpdate = content
            content = content.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
            if content != beforeUpdate {
                updateCount += 1
                print("✅ 팀 ID 업데이트 성공")
            }
        }

        if content != originalContent {
            try content.write(toFile: projectConfigPath, atomically: true, encoding: .utf8)
            print("✅ ProjectConfig.swift 업데이트 완료 (총 \(updateCount)개 변경)")

            // 변경 내용 검증
            let verifyContent = try String(contentsOfFile: projectConfigPath, encoding: .utf8)
            if verifyContent.contains("projectName: String = \"\(newName)\"") {
                print("✅ 이름 변경 검증 성공: \(newName)")
            } else {
                print("⚠️ 이름 변경 검증 실패!")
                print("   현재 내용에서 projectName 라인:")
                let lines = verifyContent.components(separatedBy: .newlines)
                for (i, line) in lines.enumerated() {
                    if line.contains("projectName") {
                        print("   라인 \(i+1): \(line)")
                    }
                }
            }
        } else {
            print("⚠️ ProjectConfig.swift 변경사항 없음 - 패턴이 매칭되지 않았습니다")
            // 디버깅을 위해 현재 내용 출력
            let lines = content.components(separatedBy: .newlines)
            for (i, line) in lines.enumerated() {
                if line.contains("projectName") {
                    print("   기존 라인 \(i+1): \(line)")
                }
            }
        }

    } catch {
        print("❌ ProjectConfig.swift 업데이트 실패: \(error)")
    }
}

// MARK: - 이름 변경 검증 함수
private func verifyNameChange(oldName: String, newName: String) {
    print("🔍 이름 변경 검증 중...")

    let projectConfigPath = "Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Project+Templete/ProjectConfig.swift"

    if let content = try? String(contentsOfFile: projectConfigPath, encoding: .utf8) {
        if content.contains("projectName: String = \"\(newName)\"") {
            print("✅ ProjectConfig.swift 이름 변경 확인됨")
        } else {
            print("⚠️ ProjectConfig.swift에서 새 이름을 찾을 수 없습니다")
            print("   파일 내용 확인이 필요합니다")
        }
    }

    // Workspace.swift와 Project+Environment.swift 검증
    let workspacePath = "WorkSpace.swift"
    let environmentPath = "Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Project+Templete/Project+Enviorment.swift"

    for path in [workspacePath, environmentPath] {
        if FileManager.default.fileExists(atPath: path) {
            if let content = try? String(contentsOfFile: path, encoding: .utf8) {
                if content.contains(oldName) && oldName != newName {
                    print("⚠️ \(path)에 이전 이름(\(oldName))이 남아있습니다")
                } else {
                    print("✅ \(path) 검증 통과")
                }
            }
        }
    }
}

func fetch()    { run("tuist", arguments: ["fetch"]) }
func build()    { clean(); install(); generate() }  // fetch -> install로 변경 (tuist 4.97.2)
func edit()     { run("tuist", arguments: ["edit"]) }
func clean()    { run("tuist", arguments: ["clean"]) }
func install()  { run("tuist", arguments: ["install"]) }  // 새로운 install 명령어 사용
func cache()    {
    print("🚀 바이너리 캐시 생성 중...")
    run("tuist", arguments: ["cache"])  // 프로젝트명 제거하고 일반화
}
func reset() {
  print("🧹 캐시 및 로컬 빌드 정리 중...")
  run("rm", arguments: ["-rf", "\(NSHomeDirectory())/Library/Caches/Tuist"])
  run("rm", arguments: ["-rf", "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData"])
  run("rm", arguments: ["-rf", ".tuist", ".build"])
  run("rm", arguments: ["-rf", "Tuist/Dependencies"])  // 새로운 의존성 디렉토리도 정리
  install(); generate()  // fetch -> install로 변경
}

// MARK: - Parsers (Modules.swift / SPM 목록에서 자동 파싱)
func availableModuleTypes() -> [String] {
  let filePath = "Plugins/DependencyPlugin/ProjectDescriptionHelpers/TargetDependency+Module/Modules.swift"
  guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else { return [] }
  let pattern = "enum (\\w+):"
  let regex = try? NSRegularExpression(pattern: pattern)
  let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []
  return matches.compactMap {
    guard let range = Range($0.range(at: 1), in: content) else { return nil }
    let name = String(content[range])
    return name.hasSuffix("s") ? String(name.dropLast()) : name
  }
}

func parseModulesFromFile(keyword: String) -> [String] {
  let filePath = "Plugins/DependencyPlugin/ProjectDescriptionHelpers/TargetDependency+Module/Modules.swift"
  guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
    print("❗️ Modules.swift 파일을 읽을 수 없습니다.")
    return []
  }
  let pattern = "enum \(keyword).*?\\{([\\s\\S]*?)\\}"
  guard let regex = try? NSRegularExpression(pattern: pattern),
        let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
        let innerRange = Range(match.range(at: 1), in: content) else {
    return []
  }
  let innerContent = content[innerRange]
  let casePattern = "case (\\w+)"
  let caseRegex = try? NSRegularExpression(pattern: casePattern)
  let lines = innerContent.components(separatedBy: .newlines)
  return lines.compactMap { line in
    guard let match = caseRegex?.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
          let range = Range(match.range(at: 1), in: line) else { return nil }
    return String(line[range])
  }
}

func parseSPMLibraries() -> [String] {
  let filePath = "Plugins/DependencyPackagePlugin/ProjectDescriptionHelpers/DependencyPackage/Extension+TargetDependencySPM.swift"
  guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
    print("❗️ SPM 목록 파일을 읽을 수 없습니다.")
    return []
  }
  let pattern = "static let (\\w+)"
  let regex = try? NSRegularExpression(pattern: pattern)
  let lines = content.components(separatedBy: .newlines)
  return lines.compactMap { line in
    guard let match = regex?.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
          let range = Range(match.range(at: 1), in: line) else { return nil }
    return String(line[range])
  }
}

// MARK: - Module Auto Registration Helper
func addModuleToPluginAutomatically(moduleName: String, layer: String) -> Bool {
  let modulesFilePath = "Plugins/DependencyPlugin/ProjectDescriptionHelpers/TargetDependency+Module/Modules.swift"

  guard FileManager.default.fileExists(atPath: modulesFilePath) else {
    print("❌ Modules.swift 파일을 찾을 수 없습니다: \(modulesFilePath)")
    return false
  }

  do {
    var content = try String(contentsOfFile: modulesFilePath, encoding: .utf8)
    let originalContent = content

    // 레이어별 enum 이름 매핑
    let enumName: String
    switch layer {
    case "Presentation":
      enumName = "Presentations"
    case "Shared":
      enumName = "Shareds"
    case "Domain":
      enumName = "Domains"
    case "Network":
      enumName = "Networks"
    case "Data":
      enumName = "Datas"
    default:
      print("❌ 알 수 없는 레이어: \(layer)")
      return false
    }

    // enum 찾기 및 case 추가
    let enumPattern = "enum \(enumName): String, CaseIterable \\{([\\s\\S]*?)\\}"

    guard let enumRegex = try? NSRegularExpression(pattern: enumPattern),
          let enumMatch = enumRegex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
          let enumRange = Range(enumMatch.range, in: content) else {
      print("❌ \(enumName) enum을 찾을 수 없습니다")
      return false
    }

    // enum 내부 검사하여 중복 확인
    if let innerRange = Range(enumMatch.range(at: 1), in: content) {
      let innerContent = String(content[innerRange])
      if innerContent.contains("case \(moduleName)") {
        print("ℹ️ 모듈 '\(moduleName)'이 이미 \(enumName)에 존재합니다")
        return true
      }
    }

    // 마지막 case 뒤에 새로운 case 추가
    let enumEndIndex = content.index(before: enumRange.upperBound)
    let newCase = "    case \(moduleName)\n  "
    content.insert(contentsOf: newCase, at: enumEndIndex)

    // 파일 업데이트
    if content != originalContent {
      try content.write(toFile: modulesFilePath, atomically: true, encoding: .utf8)
      print("✅ \(enumName)에 '\(moduleName)' 모듈이 자동으로 추가되었습니다")
      return true
    }

  } catch {
    print("❌ Modules.swift 파일 업데이트 실패: \(error)")
    return false
  }

  return false
}

// MARK: - registerModule
func registerModule() {
  print("\n🚀 새 모듈 등록을 시작합니다.")
  let moduleInput = prompt("모듈 이름을 입력하세요 (예: Presentation_Home, Shared_Logger, Domain_Auth 등)")
  let moduleName = prompt("생성할 모듈 이름을 입력하세요 (예: Home)")

  // ✅ 모듈명 유효성 검사
  guard !moduleName.isEmpty else {
    print("❌ 모듈명이 비어있습니다.")
    return
  }

  guard moduleName.count >= 1 else {
    print("❌ 모듈명이 올바르지 않습니다.")
    return
  }

  var dependencies: [String] = []
  while true {
    print("의존성 종류 선택:")
    print("  1) SPM")
    print("  2) 내부 모듈")
    print("  3) 종료")
    let choice = prompt("번호 선택")
    if choice == "3" { break }

    if choice == "1" {
      let options = parseSPMLibraries()
      for (i, lib) in options.enumerated() { print("  \(i + 1). \(lib)") }
      let selected = Int(prompt("선택할 번호 입력")) ?? 0
      if (1...options.count).contains(selected) {
        dependencies.append(".SPM.\(options[selected - 1])")
      }
    } else if choice == "2" {
      let types = availableModuleTypes()
      for (i, type) in types.enumerated() { print("  \(i + 1). \(type)") }
      let typeIndex = Int(prompt("의존할 모듈 타입 번호 입력")) ?? 0
      guard (1...types.count).contains(typeIndex) else { continue }
      let keyword = types[typeIndex - 1]

      let options = parseModulesFromFile(keyword: keyword)
      for (i, opt) in options.enumerated() { print("  \(i + 1). \(opt)") }
      let moduleIndex = Int(prompt("선택할 번호 입력")) ?? 0
      if (1...options.count).contains(moduleIndex) {
        dependencies.append(".\(keyword)(implements: .\(options[moduleIndex - 1]))")
      }
    }
  }

  // 🧪 hasTests 옵션 선택
  print("\n🧪 테스트 설정:")
  let hasTestsChoice = prompt("이 모듈에 테스트를 포함하시겠습니까? (y/N)").lowercased()
  let hasTests = hasTestsChoice == "y" || hasTestsChoice == "yes"

  let author = (try? runCapture("git", arguments: ["config", "--get", "user.name"])) ?? "Unknown"
  let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
  let currentDate = formatter.string(from: Date())

  let layer: String = {
    let lower = moduleInput.lowercased()
    if lower.starts(with: "presentation") { return "Presentation" }
    else if lower.starts(with: "shared")   { return "Shared" }
    else if lower.starts(with: "domain")   { return "Domain" }
    else if lower.starts(with: "network")  { return "Network" }
    else if lower.starts(with: "data")     { return "Data" }
    else { return "Shared" }  // 기본값을 Shared로 변경
  }()

  let result = run("tuist", arguments: [
    "scaffold", "Module",
    "--layer", layer,
    "--name", moduleName,
    "--author", author,
    "--current-date", currentDate
  ])

  if result == 0 {
    let projectFile = "Projects/\(layer)/\(moduleName)/Project.swift"

    // Project.swift 파일을 완전히 다시 작성
    let dependencyList = dependencies.isEmpty ? "" : "\n    " + dependencies.joined(separator: ",\n    ") + ","

    let projectContent = """
import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "\(moduleName)",
  bundleId: .appBundleID(name: ".\(moduleName)"),
  product: .staticFramework,
  settings: .settings(),
  dependencies: [\(dependencyList)
  ],
  sources: ["Sources/**"]\(hasTests ? ",\n  hasTests: true" : "")
)
"""

    do {
      try projectContent.write(toFile: projectFile, atomically: true, encoding: .utf8)
      print("✅ Project.swift 파일 생성 완료")
      if !dependencies.isEmpty {
        print("✅ 의존성 추가: \(dependencies.count)개")
      }
      if hasTests {
        print("✅ hasTests: true 추가 - 템플릿에서 Tests/Sources 구조 자동 생성됨")
      } else {
        print("ℹ️ hasTests: false - Tests 폴더는 생성되지만 프로젝트에 포함되지 않음")
      }
    } catch {
      print("❌ Project.swift 파일 작성 실패: \(error)")
    }

    // ✅ 자동으로 Modules.swift에 모듈 추가
    print("\n📝 Modules.swift에 모듈 등록 중...")
    if addModuleToPluginAutomatically(moduleName: moduleName, layer: layer) {
      print("✅ Modules.swift 등록 완료")
    } else {
      print("⚠️ Modules.swift 등록 실패 - 수동으로 추가해주세요")
    }

    print("✅ 모듈 생성 완료: Projects/\(layer)/\(moduleName)")

    // ──────────────────────────────
    // ✅ Domain 모듈일 경우 Interface 폴더 생성 여부 확인
    if layer == "Domain" {
      let askInterface = prompt("이 Domain 모듈에 Interface 폴더를 생성할까요? (y/N)").lowercased()
      if askInterface == "y" {
        let interfaceDir = "Projects/Domain/\(moduleName)/Interface/Sources"
        let baseFilePath = "\(interfaceDir)/Base.swift"

        if !FileManager.default.fileExists(atPath: interfaceDir) {
          do {
            try FileManager.default.createDirectory(atPath: interfaceDir, withIntermediateDirectories: true, attributes: nil)
            print("📂 Interface 폴더 생성 → \(interfaceDir)")
          } catch {
            print("❌ Interface 폴더 생성 실패: \(error)")
          }
        } else {
          print("ℹ️ Interface 폴더 이미 존재 → 건너뜀")
        }

        // Base.swift 생성(없으면)
        if !FileManager.default.fileExists(atPath: baseFilePath) {
          let baseTemplate = """
          //
          //  Base.swift
          //  Domain.\(moduleName).Interface
          //
          //  Created by \(author) on \(currentDate).
          //
          
          import Foundation
          
          public protocol \(moduleName)Interface {
              // TODO: 정의 추가
          }
          """
          do {
            try baseTemplate.write(toFile: baseFilePath, atomically: true, encoding: .utf8)
            print("✅ Base.swift 생성 → \(baseFilePath)")
          } catch {
            print("❌ Base.swift 생성 실패: \(error)")
          }
        } else {
          print("ℹ️ Base.swift 이미 존재 → 건너뜀")
        }
      }
    }
  } else {
    print("❌ 모듈 생성 실패")
  }
}

// MARK: - XConfig 파일 업데이트
private func updateXConfigFiles(newName: String) {
    print("🔧 xconfig 파일들 업데이트 중...")

    let configFiles = ["Dev.xcconfig", "Stage.xcconfig", "Prod.xcconfig", "Release.xcconfig"]

    for configFile in configFiles {
        let configPath = "Config/\(configFile)"

        guard FileManager.default.fileExists(atPath: configPath) else {
            print("⚠️ \(configFile) 파일을 찾을 수 없습니다: \(configPath)")
            continue
        }

        do {
            var content = try String(contentsOfFile: configPath, encoding: .utf8)
            let originalContent = content

            // 이미 동적 설정된 경우는 건너뛰기
            if content.contains("PRODUCT_NAME = $(PROJECT_NAME)") && content.contains("BUNDLE_DISPLAY_NAME = $(PROJECT_NAME)") {
                print("ℹ️ \(configFile) 이미 동적 설정됨")
                continue
            }

            // 하드코딩된 프로젝트 이름을 동적 참조로 변경
            let patterns = [
                (#"PRODUCT_NAME = [^$\n\r]*$"#, "PRODUCT_NAME = $(PROJECT_NAME)"),
                (#"PRODUCT_NAME = [^$\n\r]*-Dev$"#, "PRODUCT_NAME = $(PROJECT_NAME)-Dev"),
                (#"PRODUCT_NAME = [^$\n\r]*-Stage$"#, "PRODUCT_NAME = $(PROJECT_NAME)-Stage"),
                (#"PRODUCT_NAME = [^$\n\r]*-Prod$"#, "PRODUCT_NAME = $(PROJECT_NAME)-Prod"),
                (#"BUNDLE_DISPLAY_NAME = [^$\n\r]*$"#, "BUNDLE_DISPLAY_NAME = $(PROJECT_NAME)"),
                (#"BUNDLE_DISPLAY_NAME = [^$\n\r]*\(Dev\)$"#, "BUNDLE_DISPLAY_NAME = $(PROJECT_NAME)(Dev)"),
                (#"BUNDLE_DISPLAY_NAME = [^$\n\r]*\(Stage\)$"#, "BUNDLE_DISPLAY_NAME = $(PROJECT_NAME)(Stage)"),
                (#"BUNDLE_DISPLAY_NAME = [^$\n\r]*\(Prod\)$"#, "BUNDLE_DISPLAY_NAME = $(PROJECT_NAME)(Prod)")
            ]

            for (pattern, replacement) in patterns {
                content = content.replacingOccurrences(of: pattern, with: replacement, options: .regularExpression)
            }

            if content != originalContent {
                try content.write(toFile: configPath, atomically: true, encoding: .utf8)
                print("✅ \(configFile) 업데이트 완료")
            } else {
                print("ℹ️ \(configFile) 변경사항 없음")
            }

        } catch {
            print("❌ \(configFile) 업데이트 실패: \(error)")
        }
    }

    print("✅ xconfig 파일들 업데이트 완료")
}

// MARK: - Entrypoint
enum Command: String {
  case edit, generate, fetch, build, clean, install, cache, reset, moduleinit, newproject
  case inspect, inspectimports = "inspect-imports", inspectcoverage = "inspect-coverage"
}

let args = CommandLine.arguments.dropFirst()
guard let cmd = args.first, let command = Command(rawValue: cmd) else {
  print("""
    🚀 Tuist 4.97.2 도구 사용법:
      ./tuisttool generate                            # 프로젝트 생성
      ./tuisttool build                               # 클린 + 의존성 설치 + 생성
      ./tuisttool install                             # 의존성 설치 (새로운 명령어)
      ./tuisttool cache                               # 바이너리 캐시 생성
      ./tuisttool clean                               # 프로젝트 정리
      ./tuisttool reset                               # 전체 캐시 리셋
      ./tuisttool moduleinit                          # 새 모듈 생성
      ./tuisttool inspect                             # 프로젝트 구조 분석
      ./tuisttool inspect-imports                     # 암시적 의존성 검사
      ./tuisttool inspect-coverage                    # 코드 커버리지 분석
      ./tuisttool newproject [옵션...]                # 새 프로젝트 생성

    새 프로젝트 생성 예시:
      ./tuisttool newproject                          # 대화형으로 입력
      ./tuisttool newproject MyAwesomeApp             # 간단한 사용법
      ./tuisttool newproject MyApp --bundle-id com.company.app --team-id ABC123DEF
    """)
  exit(1)
}

switch command {
  case .edit:             edit()
  case .generate:         generate()
  case .fetch:            fetch()
  case .build:            build()
  case .clean:            clean()
  case .install:          install()
  case .cache:            cache()
  case .reset:            reset()
  case .moduleinit:       registerModule()
  case .inspect:          inspect()
  case .inspectimports:   inspectImplicitImports()
  case .inspectcoverage:  inspectCodeCoverage()
  case .newproject:
    // 인자가 있으면 인자로 처리, 없으면 대화형으로 처리
    if CommandLine.arguments.count > 2 {
        generateProjectWithArgs()
    } else {
        newProject()
    }
}
