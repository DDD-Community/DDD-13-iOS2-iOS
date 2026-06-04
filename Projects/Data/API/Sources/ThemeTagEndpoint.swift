//
//  ThemeTagEndpoint.swift
//  API
//

import Alamofire
import Foundation
import Foundations

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
