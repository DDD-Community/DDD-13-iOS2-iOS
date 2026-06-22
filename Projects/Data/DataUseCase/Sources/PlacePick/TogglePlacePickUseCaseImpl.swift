//
//  TogglePlacePickUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import UseCase

public final class TogglePlacePickUseCaseImpl: TogglePlacePickUseCase {
    private let repository: PlacePickRepositoryProtocol

    public init(repository: PlacePickRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int, placeId: Int, isCurrentlyPicked: Bool) async throws {
        if isCurrentlyPicked {
            try await repository.unpickPlace(meetingId: meetingId, placeId: placeId)
        } else {
            try await repository.pickPlace(meetingId: meetingId, placeId: placeId)
        }
    }
}
