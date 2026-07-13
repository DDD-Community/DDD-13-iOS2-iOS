//
//  TermsEndPoint.swift
//  API
//

import Foundations
import Alamofire
import Utill

public enum TermsEndPoint: EndPoint {
    case fetchSignupTerms // 회원 가입 이용약관 조회
    
    public var baseURL: String {
        AppEnvironment.serverBaseURL
    }
    
    public var path: String {
        switch self {
        case .fetchSignupTerms:
            return "/api/v1/terms"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .fetchSignupTerms:
            return .get
        }
    }
    
    public var task: APITask {
        switch self {
        case .fetchSignupTerms:
            return .requestWithoutInterceptor(body: nil)
        }
    }
}
