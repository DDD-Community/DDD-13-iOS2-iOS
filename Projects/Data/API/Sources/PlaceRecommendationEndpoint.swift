//
//  PlaceRecommendationEndpoint.swift
//  API
//

import Alamofire
import Foundation
import Foundations
import Model

public enum PlaceRecommendationEndpoint: EndPoint {
    case start(meetingId: Int, StartPlaceRecommendationRequestDTO)

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .start(let meetingId, _): return "/api/v1/meetings/\(meetingId)/location/start"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .start: return .post
        }
    }

    public var task: APITask {
        switch self {
        case .start(_, let dto): return .requestJSONEncodable(body: dto)
        }
    }
}
