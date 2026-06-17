//
//  DeparturePlaceEndpoint.swift
//  API
//

import Alamofire
import Foundation
import Foundations
import Model

public enum DeparturePlaceEndpoint: EndPoint {
    case fetchDeparturePlaces
    case updateDeparturePlace(id: Int, UpdateDeparturePlaceRequestDTO)
    case addDeparturePlace(AddDeparturePlaceRequestDTO)
    case deleteDeparturePlace(id: Int)
    case setDefaultDeparturePlace(id: Int)

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .fetchDeparturePlaces: return "/api/v1/departure-places"
        case .updateDeparturePlace(let id, _): return "/api/v1/departure-places/\(id)"
        case .addDeparturePlace: return "/api/v1/departure-places"
        case .deleteDeparturePlace(let id): return "/api/v1/departure-places/\(id)"
        case .setDefaultDeparturePlace(let id): return "/api/v1/departure-places/\(id)/default"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchDeparturePlaces: return .get
        case .updateDeparturePlace: return .put
        case .addDeparturePlace: return .post
        case .deleteDeparturePlace: return .delete
        case .setDefaultDeparturePlace: return .patch
        }
    }

    public var task: APITask {
        switch self {
        case .fetchDeparturePlaces: return .requestPlain
        case .updateDeparturePlace(_, let dto): return .requestJSONEncodable(body: dto)
        case .addDeparturePlace(let dto): return .requestJSONEncodable(body: dto)
        case .deleteDeparturePlace: return .requestPlain
        case .setDefaultDeparturePlace: return .requestPlain
        }
    }
}
