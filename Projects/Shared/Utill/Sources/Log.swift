//
//  Log.swift
//  Utill
//
//  Created by DDD-iOS2 on 4/20/26.
//  Copyright (c) 2025 DDD, Ltd., All rights reserved.
//

import os.log
import Foundation

/// 앱 전역에서 사용하는 로거
/// - DEBUG 모드: os_log로 출력 (콘솔앱에서 확인 가능)
/// - RELEASE 모드: 출력하지 않음
/// - FORCE_LOG = true: 빌드 환경 무관하게 NSLog로 강제 출력 (AdHoc 디버깅용)
public struct Log {
    /// AdHoc 등 Release 빌드에서 강제로 로그를 확인할 때 true로 변경
    private static let forceLog = false

    private init() {}

    /// 로그 출력
    /// - Parameters:
    ///   - output: 출력할 내용
    ///   - function: 호출한 함수명 (자동 캡처)
    ///   - file: 호출한 파일 경로 (자동 캡처)
    ///   - line: 호출한 라인 번호 (자동 캡처)
    public static func debug(
        _ output: Any = "",
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        let filename = (file as NSString).lastPathComponent

        if forceLog {
            if let output = output as? CVarArg {
                NSLog("[%@:%i] %@ - %@", filename, line, function, output)
            }
            return
        }

        #if DEBUG
        let log = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.ddd-ios2.Bangawo", category: "Bangawo")
        if let output = output as? CVarArg {
            os_log(.debug, log: log, "[%@:%i] %@ - %@", filename, line, function, output)
        }
        #endif
    }
}
