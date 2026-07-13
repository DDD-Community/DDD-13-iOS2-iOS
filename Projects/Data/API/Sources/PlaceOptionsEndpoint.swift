//
//  PlaceOptionsEndpoint.swift
//  API
//

import Alamofire
import Foundations

public enum PlaceOptionsEndpoint: EndPoint {
    case fetch

    public var baseURL: String { APIConfiguration.serverBaseURL }
    public var path: String { "/api/v1/places/options" }
    public var method: HTTPMethod { .get }
    public var task: APITask { .requestPlain }
}
