//
//  AppEnvironment.swift
//  Utill
//
//  Info.plist를 통해 노출된 빌드 환경 값을 안전하게 읽기 위한 헬퍼
//

import Foundation

public enum AppEnvironment {
    public static var kakaoRestAPIKey: String {
        readRequired(key: "KAKAO_REST_API_KEY")
    }

    public static var kakaoAppKey: String {
        readRequired(key: "KAKAO_APP_KEY")
    }

    public static var serverBaseURL: String {
        readRequired(key: "SERVER_BASE_URL")
    }

    private static func readRequired(key: String) -> String {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
            !value.isEmpty
        else {
            #if DEBUG
            fatalError("\(key)가 비어 있습니다. Config/Secrets.xcconfig를 확인해 주세요")
            #else
            Log.error("\(key)가 비어 있습니다. Config/Secrets.xcconfig를 확인해 주세요")
            return ""
            #endif
        }

        return value
    }
}
