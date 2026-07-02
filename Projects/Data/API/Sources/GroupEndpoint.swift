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
    case hostPickMeetingDate(meetingId: Int, HostPickMeetingDateRequestDTO)
    case fetchGroupDetail(meetingId: Int)
    case updateAttendance(groupId: Int, UpdateAttendanceRequestDTO)
    case issueInviteCode(groupId: Int)

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .fetchGroups: return "/api/v1/meetings"
        case .createGroup: return "/api/v1/groups/create"
        case let .hostPickMeetingDate(meetingId, _):
            return "/api/v1/meetings/\(meetingId)/date-vote/host-pick"
        case .fetchGroupDetail(let meetingId): return "/api/v1/meetings/\(meetingId)"
        case .updateAttendance(let groupId, _): return "/api/v1/groups/\(groupId)/members/me/attendance"
        case .issueInviteCode(let groupId): return "/api/v1/groups/\(groupId)/invite"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchGroups: return .get
        case .createGroup, .hostPickMeetingDate: return .post
        case .fetchGroupDetail: return .get
        case .updateAttendance: return .patch
        case .issueInviteCode: return .post
        }
    }

    public var task: APITask {
        switch self {
        case .fetchGroups: return .requestPlain
        case .createGroup(let dto): return .requestJSONEncodable(body: dto)
        case .hostPickMeetingDate(_, let dto): return .requestJSONEncodable(body: dto)
        case .fetchGroupDetail: return .requestPlain
        case .updateAttendance(_, let dto): return .requestJSONEncodable(body: dto)
        case .issueInviteCode: return .requestPlain
        }
    }
}
