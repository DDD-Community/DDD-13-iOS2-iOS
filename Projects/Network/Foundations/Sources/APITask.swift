//
//  APITask.swift
//  Foundations
//
//  Copyright © 2025 DDD, Ltd., All rights reserved.
//

import Foundation
import Alamofire

/// API 요청 시 파라미터 전달 방식을 정의하는 열거형
public enum APITask {
    /// 파라미터 없는 단순 요청
    case requestPlain
    /// JSON Body로 파라미터 전달
    case requestJSONEncodable(body: Encodable & Sendable)
    /// URL 쿼리 파라미터로 전달
    case requestParameters(parameters: Parameters)
    /// 인터셉터 없는 요청
    case requestWithoutInterceptor(body: (Encodable & Sendable)? = nil)
    /// 인터셉터 없는 쿼리 파라미터 요청 (외부 API용)
    case requestParametersWithoutInterceptor(parameters: Parameters)
}
