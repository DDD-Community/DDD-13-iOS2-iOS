//
//  SignupTermsRepositoryImpl.swift
//  Repository
//

import DataInterface
import Model
import Entity
import API
import Networking

/// 회원가입 이용약관 Repository 구현체
public final class SignupTermsRepositoryImpl: SignupTermsRepositoryProtocol {
    public init() {}
    
    public func fetchSignupTerms() async throws -> [SignupTerm] {
        let response: [SignuptermsResponseDTO] = try await NetworkManager.shared.request(TermsEndPoint.fetchSignupTerms)
        
        return response.map { $0.toEntity() } // 배열 변환
    }
}
