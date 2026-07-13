//
//  APIConfiguration.swift
//  Foundations
//
//  Copyright © 2025 DDD, Ltd., All rights reserved.
//

import Foundation

public enum APIConfiguration {
    public static var serverBaseURL: String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SERVER_BASE_URL") as? String,
              !value.isEmpty
        else {
            fatalError("SERVER_BASE_URL not found in Info.plist — Secrets.xcconfig가 빌드 설정에 포함되어 있는지 확인하세요.")
        }
        return value
    }
}
