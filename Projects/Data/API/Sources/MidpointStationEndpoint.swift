//
//  MidpointStationEndpoint.swift
//  API
//

import Alamofire
import Foundation
import Foundations

public enum MidpointStationEndpoint: EndPoint {
    case fetch(meetingId: Int)

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .fetch(let meetingId): return "/api/v1/meetings/\(meetingId)/midpoint-stations"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetch: return .get
        }
    }

    public var task: APITask {
        switch self {
        case .fetch: return .requestPlain
        }
    }
}
