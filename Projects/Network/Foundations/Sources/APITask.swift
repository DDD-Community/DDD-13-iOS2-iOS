//
//  APITask.swift
//  Foundations
//
//  Created by DDD-iOS2 on 4/13/26.
//  Copyright © 2025 DDD, Ltd., All rights reserved.
//

import Foundation
import Alamofire

/// API 요청 시 파라미터 전달 방식을 정의하는 열거형
public enum APITask {
    /// 파라미터 없는 단순 요청
    case requestPlain
    /// JSON Body로 파라미터 전달
    case requestJSONEncodable(Encodable)
    /// URL 쿼리 파라미터로 전달
    case requestParameters(parameters: Parameters, encoding: ParameterEncoding)
}
