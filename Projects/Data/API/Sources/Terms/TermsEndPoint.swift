//
//  TermsEndPoint.swift
//  API
//

import Foundations
import Alamofire

public enum TermsEndPoint: EndPoint {
    case fetchSignupTerms // 회원 가입 이용약관 조회
    
    public var baseURL: String {
        // TODO: baseURL secret파일에 추가하고 가져오기
        let url = "https://port-0-bangawo-server-dev-mnaf2uuja2b612e3.sel3.cloudtype.app"
        return url
    }
    
    public var path: String {
        switch self {
        case .fetchSignupTerms:
            return "/v1/terms"
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
