//
//  VoteEndpoint.swift
//  API
//

import Alamofire
import Foundation
import Foundations
import Model

public enum VoteEndpoint: EndPoint {
    case fetchDateVote(meetingId: Int)
    case fetchPlaceVote(meetingId: Int)

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .fetchDateVote(let meetingId): return "/api/v1/meetings/\(meetingId)/date-vote"
        case .fetchPlaceVote(let meetingId): return "/api/v1/meetings/\(meetingId)/place-vote"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchDateVote: return .get
        case .fetchPlaceVote: return .get
        }
    }

    public var task: APITask {
        switch self {
        case .fetchDateVote: return .requestPlain
        case .fetchPlaceVote: return .requestPlain
        }
    }
}
