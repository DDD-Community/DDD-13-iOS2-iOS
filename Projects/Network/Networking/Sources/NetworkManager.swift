//
//  NetworkManager.swift
//  Networking
//

import Foundation

import Alamofire

import Foundations
import Utill

public final class NetworkManager: Sendable {
    public static let shared = NetworkManager()
    
    private init() {}
    
    public func request<T: Decodable>(_ endPoint: EndPoint) async throws(NetworkError) -> T {
        let request = makeDataRequest(endPoint)
        Log.debug("🌐 [Request] \(endPoint.method.rawValue) \(endPoint.baseURL)\(endPoint.path)")
        let response = await request.serializingData().response
        
        let data: Foundation.Data
        switch response.result {
        case .success(let responseData):
            Log.debug("✅ [Response] \(responseData.count) bytes")
            data = responseData
        case .failure(let afError):
            Log.debug("❌ [Response Failed] \(afError.localizedDescription)")
            // Alamofire는 에러를 AFError로 래핑하여 반환함
            // Interceptor에서 completion(.failure(NetworkError.noToken))을 호출하면
            // Alamofire가 이를 AFError.underlyingError에 감싸서 전달하므로
            // 여기서 다시 꺼내서 원래의 NetworkError로 변환
            if let underlyingError = afError.underlyingError as? NetworkError {
                throw underlyingError
            }
            if let statusCode = response.response?.statusCode {
                let message = response.data.flatMap { String(data: $0, encoding: .utf8) }
                Log.debug("❌ [HTTP \(statusCode)] \(message ?? "No response body")")
                throw .serverError(statusCode: statusCode, message: message)
            }
            // Interceptor가 아닌 일반 네트워크 실패 (타임아웃, DNS 오류 등)
            throw .connectionFailed
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            Log.debug("✅ [Decode Success]\n\(prettyPrinted(data))")
            return decodedData
        } catch {
            if let raw = String(data: data, encoding: .utf8) {
                Log.debug("📦 [Decode Failed Raw Response] \(raw)")
            }
            Log.debug("❌ [Decode Error] \(error.localizedDescription)")
            throw .decodingFailed
        }

    }
    // 서버에서 빈 body를 응답해줄 경우 사용
    public func requestVoid(_ endPoint: EndPoint) async throws(NetworkError) {
        let request = makeDataRequest(endPoint)
        Log.debug("🌐 [Request] \(endPoint.method.rawValue) \(endPoint.baseURL)\(endPoint.path)")
        let response = await request.serializingData().response

        switch response.result {
        case .success(let responseData):
            Log.debug("✅ [Response] \(responseData.count) bytes")
            return
        case .failure(let afError):
            Log.debug("❌ [Response Failed] \(afError.localizedDescription)")
            if let underlyingError = afError.underlyingError as? NetworkError {
                throw underlyingError
            }
            if let statusCode = response.response?.statusCode {
                let message = response.data.flatMap { String(data: $0, encoding: .utf8) }
                if (200..<300).contains(statusCode) { // body가 비면 response를 serialized하지 못하기 때문에 에러로 빠진다. 이후 상태코드를 통해 api 성공인지 실패인지 확인한다.
                    Log.debug("✅ [HTTP \(statusCode)] Empty response body")
                    return
                }
                Log.debug("❌ [HTTP \(statusCode)] \(message ?? "No response body")")
                throw .serverError(statusCode: statusCode, message: message)
            }
            throw .connectionFailed
        }
    }
    
    private func prettyPrinted(_ data: Foundation.Data) -> String {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let prettyData = try? JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted, .withoutEscapingSlashes]
            ),
            let prettyString = String(data: prettyData, encoding: .utf8)
        else {
            return String(data: data, encoding: .utf8) ?? "\(data.count) bytes"
        }

        return prettyString
    }

    private func makeDataRequest(_ endPoint: EndPoint) -> DataRequest {
        switch endPoint.task {
        case .requestPlain:
            return AF.request(
                "\(endPoint.baseURL)\(endPoint.path)",
                method: endPoint.method,
                headers: endPoint.headers,
                interceptor: Interceptor()
            ).validate()
        case let .requestJSONEncodable(body):
            return AF.request(
                "\(endPoint.baseURL)\(endPoint.path)",
                method: endPoint.method,
                parameters: body,
                encoder: JSONParameterEncoder.default,
                headers: endPoint.headers,
                interceptor: Interceptor()
            ).validate()
        case let .requestParameters(parameters):
            return AF.request(
                "\(endPoint.baseURL)\(endPoint.path)",
                method: endPoint.method,
                parameters: parameters,
                encoding: URLEncoding.default,
                headers: endPoint.headers,
                interceptor: Interceptor()
            ).validate()
        case let .requestParametersWithEncoding(parameters, encoding):
            return AF.request(
                "\(endPoint.baseURL)\(endPoint.path)",
                method: endPoint.method,
                parameters: parameters,
                encoding: encoding,
                headers: endPoint.headers,
                interceptor: Interceptor()
            ).validate()
        case let .requestWithoutInterceptor(body):
            if let body = body {
                return AF.request(
                    "\(endPoint.baseURL)\(endPoint.path)",
                    method: endPoint.method,
                    parameters: body,
                    encoder: JSONParameterEncoder.default,
                    headers: endPoint.headers
                ).validate()
            } else {
                return AF.request(
                    "\(endPoint.baseURL)\(endPoint.path)",
                    method: endPoint.method,
                    headers: endPoint.headers
                ).validate()
            }
        case let .requestParametersWithoutInterceptor(parameters):
            return AF.request(
                "\(endPoint.baseURL)\(endPoint.path)",
                method: endPoint.method,
                parameters: parameters,
                encoding: URLEncoding.default,
                headers: endPoint.headers
            ).validate()
        }
    }
}
