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
    case submitDateVote(meetingId: Int, SubmitDateVoteRequestDTO)
    case confirmDateVote(meetingId: Int, ConfirmDateVoteRequestDTO)

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .fetchDateVote(let meetingId): return "/api/v1/meetings/\(meetingId)/date-vote"
        case .fetchPlaceVote(let meetingId): return "/api/v1/meetings/\(meetingId)/place-vote"
        case .submitDateVote(let meetingId, _): return "/api/v1/meetings/\(meetingId)/date-vote/submit"
        case .confirmDateVote(let meetingId, _): return "/api/v1/meetings/\(meetingId)/date-vote/confirm"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchDateVote: return .get
        case .fetchPlaceVote: return .get
        case .submitDateVote: return .post
        case .confirmDateVote: return .patch
        }
    }

    public var task: APITask {
        switch self {
        case .fetchDateVote: return .requestPlain
        case .fetchPlaceVote: return .requestPlain
        case .submitDateVote(_, let dto): return .requestJSONEncodable(body: dto)
        case .confirmDateVote(_, let dto): return .requestJSONEncodable(body: dto)
        }
    }
}
