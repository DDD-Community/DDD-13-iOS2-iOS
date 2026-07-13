//
//  CloseGroupUseCase.swift
//  UseCase
//

public protocol CloseGroupUseCase: Sendable {
    func execute(groupId: Int) async throws
}
