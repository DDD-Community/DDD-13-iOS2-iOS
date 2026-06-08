//
//  ThemeTagRepositoryProtocol.swift
//  DataInterface
//
//  Created by khyeji98 on 2026-06-04.
//

import Entity

/// 모임 목적(테마) 데이터에 접근하는 Repository 인터페이스.
public protocol ThemeTagRepositoryProtocol: Sendable {
    func fetchThemeTags() async throws -> [ThemeTag]
}
