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
        return .live(startPlaceRecommendationUseCase: startPlaceRecommendationUseCase)
    }
}
