//
//  IssueInviteCodeUseCase.swift
//  UseCase
//

public protocol IssueInviteCodeUseCase: Sendable {
    func execute(groupId: Int) async throws -> String
}
