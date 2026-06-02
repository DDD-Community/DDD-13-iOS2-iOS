//
//  AuthEndPoint.swift
//  API
//

import Alamofire
import Foundation
import Foundations
import Model
import Utill

/// 인증 관련 API 엔드포인트 정의
public enum AuthEndPoint: EndPoint {
    /// 로그인
    case login(LoginRequestDTO)

    /// 닉네임 검증
    case nicknameValidate(NicknameValidateRequestDTO)

    /// 회원가입
    case registerMember(RegisterMemberRequestDTO)

    public var baseURL: String {
        AppEnvironment.serverBaseURL
    }

    public var path: String {
        switch self {
        case .login:
            return "/api/v1/auth/login"

        case .nicknameValidate:
            return "/api/v1/members/nickname/validate"

        case .registerMember:
            return "/api/v1/members/register"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .login, .nicknameValidate, .registerMember:
            return .post
        }
    }

    public var task: APITask {
        switch self {
        case let .login(dto):
            return .requestWithoutInterceptor(body: dto) // 인터셉터가 필요 없는 요청
        case let .nicknameValidate(dto):
            return .requestJSONEncodable(body: dto)
        case let .registerMember(dto):
            return .requestJSONEncodable(body: dto)
        }
    }
}
