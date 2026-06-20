//
//  GroupEndpoint.swift
//  API
//

import Alamofire
import Foundation
import Foundations
import Model

public enum GroupEndpoint: EndPoint {
    case fetchGroups
    case createGroup(CreateGroupRequestDTO)
    case hostPickMeetingDate(meetingId: Int64, HostPickMeetingDateRequestDTO)

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .fetchGroups: return "/api/v1/meetings"
        case .createGroup: return "/api/v1/groups/create"
        case let .hostPickMeetingDate(meetingId, _):
            return "/api/v1/meetings/\(meetingId)/date-vote/host-pick"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchGroups: return .get
        case .createGroup, .hostPickMeetingDate: return .post
        }
    }

    public var task: APITask {
        switch self {
        case .fetchGroups: return .requestPlain
        case .createGroup(let dto): return .requestJSONEncodable(body: dto)
        case .hostPickMeetingDate(_, let dto): return .requestJSONEncodable(body: dto)
        }
    }
}
