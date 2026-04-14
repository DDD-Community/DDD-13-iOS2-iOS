//
//  NetworkManager.swift
//  Networking
//
//  Created by yeosong on 4/14/26.
//

import Foundation
import Alamofire
import Foundations

public final class NetworkManager: Sendable {
    public static let shared = NetworkManager()
    
    private init() {}
    
    public func request<T: Decodable>(_ endPoint: EndPoint) async -> T? {
        let request = makeDataRequest(endPoint)
        let result = await request.serializingData().result
        
        let data: Foundation.Data
        
        do {
            data = try result.get()
        } catch {
            print("data fetch error: \(error.localizedDescription)")
            return nil
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            print("data decode error - origin data: \(String(data: data, encoding: .utf8) ?? "")")
            return nil
        }
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
        }
    }
}
