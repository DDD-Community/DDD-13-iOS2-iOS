//
//  CreateGroupUseCase.swift
//  UseCase
//

import Entity

public protocol CreateGroupUseCase: Sendable {
    func execute(name: String, themeTagCode: String) async throws -> CreateGroupResult
}
