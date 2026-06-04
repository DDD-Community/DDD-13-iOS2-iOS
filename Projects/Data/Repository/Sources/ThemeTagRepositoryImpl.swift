//
//  ThemeTagRepositoryImpl.swift
//  Repository
//

import API
import DataInterface
import Entity
import Model
import Networking

public final class ThemeTagRepositoryImpl: ThemeTagRepositoryProtocol {
    public init() {}

    public func fetchThemeTags() async throws -> [ThemeTag] {
        if let cached = await ThemeTagCacheStore.shared.read() {
            return cached
        }

        let response: [ThemeTagResponseDTO] = try await NetworkManager.shared.request(ThemeTagEndpoint.fetchThemeTags)
        let tags = response.map { $0.toEntity() }
        await ThemeTagCacheStore.shared.store(tags)
        return tags
    }
}
