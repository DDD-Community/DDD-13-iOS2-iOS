//
//  PlaceRecommendationFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Repository

enum PlaceRecommendationFactory {
    static func makeClient() -> PlaceRecommendationClient {
        let repository = PlaceRecommendationRepositoryImpl()
        let startPlaceRecommendationUseCase = StartPlaceRecommendationUseCaseImpl(repository: repository)
        let midpointRepository = MidpointStationRepositoryImpl()
        let fetchUseCase = FetchStationRecommendationsUseCaseImpl(
            midpointRepository: midpointRepository,
            recommendationRepository: repository
        )
        return .live(
            startPlaceRecommendationUseCase: startPlaceRecommendationUseCase,
            fetchUseCase: fetchUseCase
        )
    }
}
