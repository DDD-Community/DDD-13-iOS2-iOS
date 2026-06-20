//
//  StartPlaceRecommendationUseCase.swift
//  UseCase
//

public protocol StartPlaceRecommendationUseCase: Sendable {
    func execute(meetingId: Int, radiusKm: Double) async throws
}
