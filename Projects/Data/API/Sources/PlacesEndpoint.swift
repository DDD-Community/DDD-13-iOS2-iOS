//
//  PlacesEndpoint.swift
//  API
//

import Foundation

import Alamofire

import Foundations

public enum PlacesEndpoint {
    case fetchDetails(ids: [Int])
}

extension PlacesEndpoint: EndPoint {
    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String { "/api/v1/places" }

    public var method: HTTPMethod { .get }

    public var task: APITask {
        switch self {
        case let .fetchDetails(ids):
            return .requestParametersWithEncoding(
                parameters: ["ids": ids],
                encoding: URLEncoding(arrayEncoding: .noBrackets)
            )
        }
    }
}
