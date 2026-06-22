//
//  PlacePickEndpoint.swift
//  API
//

import Alamofire
import Foundation
import Foundations

public enum PlacePickEndpoint: EndPoint {
    case pick(meetingId: Int, placeId: Int)
    case unpick(meetingId: Int, placeId: Int)
    case fetchStatus(meetingId: Int)

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case let .pick(meetingId, placeId),
             let .unpick(meetingId, placeId):
            return "/api/v1/meetings/\(meetingId)/places/\(placeId)/pick"

        case let .fetchStatus(meetingId):
            return "/api/v1/meetings/\(meetingId)/places/pick-status"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .pick: return .post
        case .unpick: return .delete
        case .fetchStatus: return .get
        }
    }

    public var task: APITask {
        switch self {
        case .pick, .unpick, .fetchStatus: return .requestPlain
        }
    }
}
