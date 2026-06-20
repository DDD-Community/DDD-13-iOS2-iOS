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
    case fetchConfirmedPlaceResult(meetingId: Int)
    case submitDateVote(meetingId: Int, SubmitDateVoteRequestDTO)
    case confirmDateVote(meetingId: Int, ConfirmDateVoteRequestDTO)
    case submitPlaceVote(meetingId: Int, SubmitPlaceVoteRequestDTO)

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .fetchDateVote(let meetingId): return "/api/v1/meetings/\(meetingId)/date-vote"
        case .fetchPlaceVote(let meetingId): return "/api/v1/meetings/\(meetingId)/place-vote"
        case .fetchConfirmedPlaceResult(let meetingId): return "/api/v1/meetings/\(meetingId)/place-result"
        case .submitDateVote(let meetingId, _): return "/api/v1/meetings/\(meetingId)/date-vote/submit"
        case .confirmDateVote(let meetingId, _): return "/api/v1/meetings/\(meetingId)/date-vote/confirm"
        case .submitPlaceVote(let meetingId, _): return "/api/v1/meetings/\(meetingId)/place-vote/submit"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchDateVote: return .get
        case .fetchPlaceVote: return .get
        case .fetchConfirmedPlaceResult: return .get
        case .submitDateVote: return .post
        case .confirmDateVote: return .patch
        case .submitPlaceVote: return .post
        }
    }

    public var task: APITask {
        switch self {
        case .fetchDateVote: return .requestPlain
        case .fetchPlaceVote: return .requestPlain
        case .fetchConfirmedPlaceResult: return .requestPlain
        case .submitDateVote(_, let dto): return .requestJSONEncodable(body: dto)
        case .confirmDateVote(_, let dto): return .requestJSONEncodable(body: dto)
        case .submitPlaceVote(_, let dto): return .requestJSONEncodable(body: dto)
        }
    }
}
