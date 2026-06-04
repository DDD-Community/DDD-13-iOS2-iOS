//
//  ThemeTagEndpoint.swift
//  API
//
//  Created by khyeji98 on 2026-06-04.
//

import Alamofire
import Foundation
import Foundations

/// 모임 목적(테마) 관련 API 엔드포인트.
public enum ThemeTagEndpoint: EndPoint {
    case fetchThemeTags

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .fetchThemeTags: return "/api/v1/theme-tags"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchThemeTags: return .get
        }
    }

    public var task: APITask {
        switch self {
        case .fetchThemeTags: return .requestPlain
        }
    }
}
