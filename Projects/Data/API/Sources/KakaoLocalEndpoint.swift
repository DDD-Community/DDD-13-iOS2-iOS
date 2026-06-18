//
//  KakaoLocalEndpoint.swift
//  API
//
//  Kakao Local REST API 엔드포인트 정의
//

import Foundation

import Alamofire

import Foundations
import Utill

public enum KakaoLocalEndpoint {
    case searchKeyword(query: String, categoryGroupCode: String)
    case searchCategory(x: String, y: String, radius: Int, categoryGroupCode: String, sort: String)
}

extension KakaoLocalEndpoint: EndPoint {
    public var baseURL: String {
        "https://dapi.kakao.com"
    }

    public var path: String {
        switch self {
        case .searchKeyword: return "/v2/local/search/keyword.json"
        case .searchCategory: return "/v2/local/search/category.json"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .searchKeyword: return .get
        case .searchCategory: return .get
        }
    }

    public var headers: HTTPHeaders? {
        [
            "Authorization": "KakaoAK \(AppEnvironment.kakaoRestAPIKey)",
            "Content-Type": "application/json"
        ]
    }

    public var task: APITask {
        switch self {
        case let .searchKeyword(query, categoryGroupCode):
            return .requestParametersWithoutInterceptor(parameters: [
                "query": query,
                "category_group_code": categoryGroupCode
            ])

        case let .searchCategory(x, y, radius, categoryGroupCode, sort):
            return .requestParametersWithoutInterceptor(parameters: [
                "category_group_code": categoryGroupCode,
                "x": x,
                "y": y,
                "radius": radius,
                "sort": sort
            ])
        }
    }
}
