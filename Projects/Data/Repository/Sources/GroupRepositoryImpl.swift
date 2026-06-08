//
//  GroupRepositoryImpl.swift
//  Repository
//

import DataInterface
import Entity
import Model
import API
import Networking

public final class GroupRepositoryImpl: GroupRepositoryProtocol {
    public init() {}

    public func fetchGroups() async throws -> [Group] {
        let response: [GroupListItemResponseDTO] = try await NetworkManager.shared.request(GroupEndpoint.fetchGroups)
        return response.map { $0.toEntity() }
    }

    public func createGroup(name: String, themeTagCode: String) async throws -> CreateGroupResult {
        let requestDTO = CreateGroupRequestDTO(name: name, themeTagCode: themeTagCode)
        let response: CreateGroupResponseDTO = try await NetworkManager.shared.request(GroupEndpoint.createGroup(requestDTO))
        return response.toEntity()
    }
}
