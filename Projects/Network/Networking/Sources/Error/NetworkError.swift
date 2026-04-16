//
//  AuthError.swift
//  Networking
//
//  Created by yeosong on 4/16/26.
//

import Foundation

/// 네트워크 요청 과정에서 발생할 수 있는 에러 정의
public enum NetworkError: Error {
    // MARK: - 인증
    /// 키체인에 토큰이 없음
    case noToken
    /// 액세스 토큰 만료 (401)
    case tokenExpired
    /// 리프레시 토큰 갱신 실패
    case refreshFailed

    // MARK: - 서버
    /// HTTP 에러 응답 (400, 403, 500 등)
    case serverError(statusCode: Int, message: String?)

    // MARK: - 클라이언트
    /// 서버 연결 실패 (타임아웃, 네트워크 끊김 등)
    case connectionFailed
    /// 응답 데이터 디코딩 실패
    case decodingFailed
    /// 알 수 없는 에러
    case unknown(Error)
}
