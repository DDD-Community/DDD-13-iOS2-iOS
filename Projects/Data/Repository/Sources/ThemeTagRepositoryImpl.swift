//
//  ThemeTagRepositoryImpl.swift
//  Repository
//
//  Created by khyeji98 on 2026-06-04.
//

import API
import DataInterface
import Entity
import Model
import Networking

/// 모임 목적(테마) Repository 구현체.
/// 세션 캐시를 먼저 확인하고, 캐시에 없을 때만 네트워크로 조회한 뒤 캐시에 저장한다.
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
