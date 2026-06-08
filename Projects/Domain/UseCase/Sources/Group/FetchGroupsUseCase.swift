//
//  FetchGroupsUseCase.swift
//  UseCase
//

import Entity

public protocol FetchGroupsUseCase: Sendable {
    func execute() async throws -> [Group]
}
