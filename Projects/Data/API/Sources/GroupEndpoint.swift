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

    public var baseURL: String { APIConfiguration.serverBaseURL }

    public var path: String {
        switch self {
        case .fetchGroups: return "/api/v1/meetings"
        case .createGroup: return "/api/v1/groups/create"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchGroups: return .get
        case .createGroup: return .post
        }
    }

    public var task: APITask {
        switch self {
        case .fetchGroups: return .requestPlain
        case .createGroup(let dto): return .requestJSONEncodable(body: dto)
        }
    }
}
