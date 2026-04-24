//
//  Log.swift
//  Utill
//
//  Created by DDD-iOS2 on 4/20/26.
//  Copyright (c) 2025 DDD, Ltd., All rights reserved.
//

import os
import Foundation

/// 앱 전역에서 사용하는 로거
/// - DEBUG 모드: Logger API로 출력 (콘솔앱에서 확인 가능)
/// - RELEASE 모드: 출력하지 않음
/// - FORCE_LOG = true: 빌드 환경 무관하게 NSLog로 강제 출력 (AdHoc 디버깅용)
public struct Log {
    /// AdHoc 등 Release 빌드에서 강제로 로그를 확인할 때 true로 변경
    private static let forceLog = false

    private static let logger = Logger( // Logger인스턴스 한 번만 생성해서 재사용
        subsystem: Bundle.main.bundleIdentifier ?? "com.ddd-ios2.Bangawo", // 현재 앱 번들 ID
        category: "Bangawo" // console.app에서 이 값으로 카테고리별 필터링 가능 - 일단 Bangawo 하나로 통일
    )

    private init() {}

    /// 디버깅용 로그 (개발 중 값 확인, 상태 추적)
    public static func debug(
        _ output: Any = "",
        function: String = #function,// 함수명
        file: String = #file, // 호출한 파일명 (ex. Interceptor.swift)
        line: Int = #line // 호출한 라인
    ) {
        let filename = (file as NSString).lastPathComponent // lastPathComponent를 통해서 불필요한 path는 제거
        let message = "\(output)"

        if forceLog { // 테플같은 릴리즈 빌드에서 디버깅할 때 사용
            NSLog("[DEBUG] [%@:%i] %@ - %@", filename, line as NSNumber, function, message)
            return
        }

        #if DEBUG // 릴리즈 바이너리에 코드 추가 안됨.
        logger.debug("[\(filename, privacy: .public):\(line)] \(function, privacy: .public) - \(message, privacy: .public)")
        #endif
    }

    /// 흐름 추적용 로그 (API 호출, 화면 전환 등)  - ex. 로그인 플로우 시작
    public static func info(
        _ output: Any = "",
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        let filename = (file as NSString).lastPathComponent
        let message = "\(output)"

        if forceLog {
            NSLog("[INFO] [%@:%i] %@ - %@", filename, line as NSNumber, function, message)
            return
        }

        #if DEBUG
        logger.info("[\(filename, privacy: .public):\(line)] \(function, privacy: .public) - \(message, privacy: .public)")
        #endif
    }

    /// 에러 로그 (네트워크 실패, 디코딩 에러 등)
    public static func error(
        _ output: Any = "",
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        let filename = (file as NSString).lastPathComponent
        let message = "\(output)"

        if forceLog {
            NSLog("[ERROR] [%@:%i] %@ - %@", filename, line as NSNumber, function, message)
            return
        }

        #if DEBUG
        logger.error("[\(filename, privacy: .public):\(line)] \(function, privacy: .public) - \(message, privacy: .public)")
        #endif
    }
}
