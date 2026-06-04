//
//  ThemeTagRepositoryProtocol.swift
//  DataInterface
//

import Entity

public protocol ThemeTagRepositoryProtocol: Sendable {
    func fetchThemeTags() async throws -> [ThemeTag]
}
