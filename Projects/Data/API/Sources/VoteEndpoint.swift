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
    case startDateVote(meetingId: Int, StartDateVoteRequestDTO)
    case submitDateVote(meetingId: Int, SubmitDateVoteRequestDTO)
    case confirmDateVote(meetingId: Int, ConfirmDateVoteRequestDTO)
    case startPlaceVote(meetingId: Int, StartPlaceVoteRequestDTO)
    case submitPlaceVote(meetingId: Int, SubmitPlaceVoteRequestDTO)
    case confirmPlaceVote(meetingId: Int)
    case fetchPlaceVoteTravelBurden(meetingId: Int, placeId: Int)
    case fetchPlaceVoteParticipants(meetingId: Int)

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .fetchDateVote(let meetingId): return "/api/v1/meetings/\(meetingId)/date-vote"
        case .fetchPlaceVote(let meetingId): return "/api/v1/meetings/\(meetingId)/place-vote"
        case .fetchConfirmedPlaceResult(let meetingId): return "/api/v1/meetings/\(meetingId)/place-result"
        case .startDateVote(let meetingId, _): return "/api/v1/meetings/\(meetingId)/date-vote"
        case .submitDateVote(let meetingId, _): return "/api/v1/meetings/\(meetingId)/date-vote/submit"
        case .confirmDateVote(let meetingId, _): return "/api/v1/meetings/\(meetingId)/date-vote/confirm"
        case .startPlaceVote(let meetingId, _): return "/api/v1/meetings/\(meetingId)/place-vote"
        case .submitPlaceVote(let meetingId, _): return "/api/v1/meetings/\(meetingId)/place-vote/submit"
        case .confirmPlaceVote(let meetingId): return "/api/v1/meetings/\(meetingId)/place-confirm"
        case .fetchPlaceVoteTravelBurden(let meetingId, let placeId):
            return "/api/v1/meetings/\(meetingId)/place-vote/\(placeId)/travel-burden"
        case .fetchPlaceVoteParticipants(let meetingId):
            return "/api/v1/meetings/\(meetingId)/place-vote/participants"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchDateVote: return .get
        case .fetchPlaceVote: return .get
        case .fetchConfirmedPlaceResult: return .get
        case .startDateVote: return .post
        case .submitDateVote: return .post
        case .confirmDateVote: return .patch
        case .startPlaceVote: return .post
        case .submitPlaceVote: return .post
        case .confirmPlaceVote: return .post
        case .fetchPlaceVoteTravelBurden: return .get
        case .fetchPlaceVoteParticipants: return .get
        }
    }

    public var task: APITask {
        switch self {
        case .fetchDateVote: return .requestPlain
        case .fetchPlaceVote: return .requestPlain
        case .fetchConfirmedPlaceResult: return .requestPlain
        case .startDateVote(_, let dto): return .requestJSONEncodable(body: dto)
        case .submitDateVote(_, let dto): return .requestJSONEncodable(body: dto)
        case .confirmDateVote(_, let dto): return .requestJSONEncodable(body: dto)
        case .startPlaceVote(_, let dto): return .requestJSONEncodable(body: dto)
        case .submitPlaceVote(_, let dto): return .requestJSONEncodable(body: dto)
        case .confirmPlaceVote: return .requestPlain
        case .fetchPlaceVoteTravelBurden: return .requestPlain
        case .fetchPlaceVoteParticipants: return .requestPlain
        }
    }
}
