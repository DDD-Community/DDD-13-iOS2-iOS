//
//  StartPlaceRecommendationUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import UseCase

public final class StartPlaceRecommendationUseCaseImpl: StartPlaceRecommendationUseCase {
    private let repository: PlaceRecommendationRepositoryProtocol

    public init(repository: PlaceRecommendationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(meetingId: Int, radiusKm: Double) async throws {
        try await repository.startPlaceRecommendation(meetingId: meetingId, radiusKm: radiusKm)
    }
}
