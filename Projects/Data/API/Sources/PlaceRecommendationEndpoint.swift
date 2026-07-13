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
    case fetchRecommendations(meetingId: Int)

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .start(let meetingId, _): return "/api/v1/meetings/\(meetingId)/location/start"
        case .fetchRecommendations(let meetingId): return "/api/v1/meetings/\(meetingId)/recommendations"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .start: return .post
        case .fetchRecommendations: return .get
        }
    }

    public var task: APITask {
        switch self {
        case .start(_, let dto): return .requestJSONEncodable(body: dto)
        case .fetchRecommendations: return .requestPlain
        }
    }
}
