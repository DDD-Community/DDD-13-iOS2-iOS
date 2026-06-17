//
//  FetchGroupDetailUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchGroupDetailUseCaseImpl: FetchGroupDetailUseCase {
    private let repository: GroupRepositoryProtocol

    public init(repository: GroupRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int64) async throws -> GroupDetail {
        try await repository.fetchGroupDetail(meetingId: meetingId)
    }
}
