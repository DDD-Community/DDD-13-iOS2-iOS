//
//  StorageEndPoint.swift
//  API
//

import Alamofire
import Foundation
import Foundations
import Model
import Utill

public enum StorageEndPoint: EndPoint {
    case getSignedUploadURL(SignedUploadURLRequestDTO)

    public var baseURL: String {
        AppEnvironment.serverBaseURL
    }

    public var path: String {
        switch self {
        case .getSignedUploadURL:
            return "/api/v1/storage/images"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .getSignedUploadURL:
            return .post
        }
    }

    public var task: APITask {
        switch self {
        case let .getSignedUploadURL(dto):
            return .requestJSONEncodable(body: dto)
        }
    }
}
