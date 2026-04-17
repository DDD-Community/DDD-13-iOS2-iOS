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
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping @Sendable (Result<URLRequest, Error>) -> Void) { // swift6 concurrency data race 문제 때문에 @Sendable 처리
        guard let accessToken = KeyChainManager.readItem(key: KeyChainKey.accessToken) else {
            // ex)토큰이 없는경우 로그인 화면으로 이동
            DispatchQueue.main.async {
                UserDefaults.standard.set(false, forKey: UserDefaultsKey.isLogin) // @AppStorage를 통해서 관리
            }
            
            completion(.failure(NetworkError.noToken))
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization("Bearer \(accessToken)"))
        print("JWT: \(accessToken)")
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping @Sendable (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        if response.statusCode == 401 { // ex)토큰 관련 에러일 경우
            Task {
                let refreshCompleted = await refreshAccessToken()
                
                if refreshCompleted, let _ = KeyChainManager.readItem(key: KeyChainKey.accessToken) {
                    completion(.retry)
                } else {
                    print("refresh Token 만료")
                    // TODO: 로그인창으로 보내기
                    await MainActor.run {
                        UserDefaults.standard.set(false, forKey: UserDefaultsKey.isLogin)
                    }
                    completion(.doNotRetry)
                }
            }
        } else {
            completion(.doNotRetryWithError(error))
        }
    }
    
        // 토큰 리프레시 함수
        private func refreshAccessToken() async -> Bool {
            print("토큰 리프레시 함수 실행")
            // TODO: 리프레시 함수 구현
//            guard let refreshTokenResponse = await AuthService.refreshingToken() else {
//                return false
//            }
            
            // TODO: 갱신된 토큰 저장
//            if let newAccessToken = refreshTokenResponse.data?.accessToken,
//               let newRefreshToken = refreshTokenResponse.data?.refreshToken {
//                KeyChainManager.updateItem(key: KeyChainKey.accessToken, value: newAccessToken)
//                KeyChainManager.updateItem(key: KeyChainKey.refreshToken, value: newRefreshToken)
//                UserDefaults.standard.set(Date(), forKey: UserDefaultsKey.tokenIssueDate)
//                return true
//            } else {
//                return false
//            }
            return true
        }
}
