//
//  SignupTermsRepositoryProtocol.swift
//  DataInterface
//

import Entity
/// 회원 가입 이용약관 데이터 소스 접근 추상화 Repository 프로토콜
public protocol SignupTermsRepositoryProtocol: Sendable {
    /// 회원가입 이용약관 조회
    func fetchSignupTerms() async throws -> [SignupTerm]
}
