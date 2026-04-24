//
//  BaseResponse.swift
//  Model
//
//  Created by DDD-iOS2 on 4/13/26.
//  Copyright © 2025 DDD, Ltd., All rights reserved.
//

import Foundation

/// 서버 응답에 data가 없는 경우 사용하는 빈 응답 모델
/// 예: BaseResponse<EmptyResponseModel> 형태로 활용
public struct EmptyResponseModel: Codable {
    public init() {}
}

/// 서버 API의 공통 응답 래퍼 모델
/// 모든 API 응답은 status, message, data 구조를 따름
/// - Parameter T: 실제 응답 데이터의 타입 (Codable 준수 필요)
///
/// 사용 예시:
/// ```swift
/// // data가 있는 경우
/// let response: BaseResponse<UserModel> = try decode(data)
///
/// // data가 없는 경우
/// let response: BaseResponse<EmptyResponseModel> = try decode(data)
/// ```
public struct BaseResponse<T: Codable>: Codable {
    /// HTTP 상태 코드 (e.g., 200, 400, 500)
    public let status: Int
    /// 서버에서 전달하는 응답 메시지
    public let message: String
    /// 실제 응답 데이터 (없을 수 있으므로 Optional)
    public let data: T?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case data
    }

    /// JSON 디코딩 시 data 필드가 없어도 에러 없이 nil로 처리
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Int.self, forKey: .status)
        message = try container.decode(String.self, forKey: .message)
        data = try container.decodeIfPresent(T.self, forKey: .data)
    }
}
