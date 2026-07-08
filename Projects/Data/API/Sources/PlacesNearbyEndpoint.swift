//
//  PlacesNearbyEndpoint.swift
//  API
//

import Foundation

import Alamofire

import Foundations

public enum PlacesNearbyEndpoint {
    case fetch(latitude: Double, longitude: Double, radiusMeters: Double, category: String?)
}

extension PlacesNearbyEndpoint: EndPoint {
    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String { "/api/v1/places/nearby" }

    public var method: HTTPMethod { .get }

    public var task: APITask {
        switch self {
        case let .fetch(latitude, longitude, radiusMeters, category):
            var parameters: Parameters = [
                "latitude": latitude,
                "longitude": longitude,
                "radiusMeters": radiusMeters
            ]

            if let category {
                parameters["category"] = category
            }

            return .requestParameters(parameters: parameters)
        }
    }
}
