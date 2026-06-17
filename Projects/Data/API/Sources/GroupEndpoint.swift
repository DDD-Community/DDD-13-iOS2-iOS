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
    case fetchGroupDetail(meetingId: Int64)
    case updateAttendance(groupId: Int64, UpdateAttendanceRequestDTO)

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .fetchGroups: return "/api/v1/meetings"
        case .createGroup: return "/api/v1/groups/create"
        case .fetchGroupDetail(let meetingId): return "/api/v1/meetings/\(meetingId)"
        case .updateAttendance(let groupId, _): return "/api/v1/groups/\(groupId)/members/me/attendance"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchGroups: return .get
        case .createGroup: return .post
        case .fetchGroupDetail: return .get
        case .updateAttendance: return .patch
        }
    }

    public var task: APITask {
        switch self {
        case .fetchGroups: return .requestPlain
        case .createGroup(let dto): return .requestJSONEncodable(body: dto)
        case .fetchGroupDetail: return .requestPlain
        case .updateAttendance(_, let dto): return .requestJSONEncodable(body: dto)
        }
    }
}
