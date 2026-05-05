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
}

extension KakaoLocalEndpoint: EndPoint {
    public var baseURL: String {
        "https://dapi.kakao.com"
    }

    public var path: String {
        switch self {
        case .searchKeyword: return "/v2/local/search/keyword.json"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .searchKeyword: return .get
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
        }
    }
}
