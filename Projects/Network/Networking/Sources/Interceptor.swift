//
//  Interceptor.swift
//  Networking
//
//  Created by yeosong on 4/13/26.
//

import Foundation
import Alamofire
import Utill

class Interceptor: RequestInterceptor, @unchecked Sendable {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard let accessToken = KeyChainManager.readItem(key: "accessToken") else {
            // 토큰이 없는경우 로그인 화면으로 이동
            DispatchQueue.main.async {
                UserDefaults.standard.set(false, forKey: "isLogin")
            }
            
            //completion(.failure(AuthError.noToken))
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization("Bearer \(accessToken)"))
        print("JWT: \(accessToken)")
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
//        
//        if response.statusCode == 401 { // 토큰 관련 에러일 경우
//                // ✅ @MainActor를 명시하여 비동기 작업의 실행 컨텍스트를 고정합니다.
//                Task { @MainActor in
//                    let refreshCompleted = await refreshAccessToken()
//                    
//                    if refreshCompleted, let _ = KeyChainManager.readItem(key: "accessToken") {
//                        completion(.retry) // 이제 안전하게 호출 가능
//                    } else {
//                        print("refresh Token 만료")
//                        UserDefaults.standard.set(false, forKey: "isLogin")
//                        completion(.doNotRetry)
//                    }
//                }
//            } else {
//                completion(.doNotRetryWithError(error))
//            }
    }
    
        // 토큰 리프레시 함수
        private func refreshAccessToken() async -> Bool {
            print("토큰 리프레시 함수 실행")
            // TODO: 리프레시 함수 구현
//            guard let refreshTokenResponse = await AuthService.refreshingToken() else {
//                return false
//            }
            
            // 갱신된 토큰 저장
//            if let newAccessToken = refreshTokenResponse.data?.accessToken,
//               let newRefreshToken = refreshTokenResponse.data?.refreshToken {
//                KeyChainManager.updateItem(key: "accessToken", value: newAccessToken)
//                KeyChainManager.updateItem(key: "refreshToken", value: newRefreshToken)
//                UserDefaults.standard.set(Date(), forKey: "tokenIssueDate") // 새 발급 시간 저장
//                return true
//            } else {
//                return false
//            }
            return true
        }
}
