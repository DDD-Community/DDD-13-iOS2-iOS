//
//  EndPoint.swift
//  Foundations
//
//  Created by DDD-iOS2 on 4/13/26.
//  Copyright © 2025 DDD, Ltd., All rights reserved.
//

import Foundation
import Alamofire

/// API 엔드포인트를 정의하기 위한 프로토콜
/// 각 API 모듈에서 이 프로토콜을 채택하여 엔드포인트를 구성
public protocol EndPoint {
    /// API 서버 기본 URL (e.g., "https://api.bangawo.com")
    var baseURL: String { get }
    /// API 경로 (e.g., "/users/login")
    var path: String { get }
    /// HTTP 메서드 (GET, POST, PUT, DELETE 등)
    var method: HTTPMethod { get }
    /// HTTP 헤더
    var headers: HTTPHeaders? { get }
    /// 요청 파라미터 방식 (body, query 등)
    var task: APITask { get }
}

extension EndPoint {
    /// 기본 헤더: JSON Content-Type
    public var headers: HTTPHeaders? {
        return ["Content-Type": "application/json"]
    }
}
