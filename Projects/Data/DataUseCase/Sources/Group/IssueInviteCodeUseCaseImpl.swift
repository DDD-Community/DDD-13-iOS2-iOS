//
//  IssueInviteCodeUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import UseCase

public final class IssueInviteCodeUseCaseImpl: IssueInviteCodeUseCase {
    private let repository: GroupRepositoryProtocol

    public init(repository: GroupRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(groupId: Int) async throws -> String {
        try await repository.issueInviteCode(groupId: groupId)
    }
}
