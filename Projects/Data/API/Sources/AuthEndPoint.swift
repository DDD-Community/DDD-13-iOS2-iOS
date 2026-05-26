//
//  AuthEndPoint.swift
//  API
//

import Foundation

import Alamofire

import Foundations
import Model
import Utill

/// 인증 관련 API 엔드포인트 정의
public enum AuthEndPoint: EndPoint {
    /// 로그인
    case login(LoginRequestDTO)

    public var baseURL: String {
        AppEnvironment.serverBaseURL
    }

    public var path: String {
        switch self {
        case .login:
            return "/api/v1/auth/login"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }

    public var task: APITask {
        switch self {
        case let .login(dto):
            return .requestWithoutInterceptor(body: dto) // 인터셉터가 필요 없는 요청
        }
    }
}
