//
//  FetchStationRecommendationsUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase

public final class FetchStationRecommendationsUseCaseImpl: FetchStationRecommendationsUseCase {
    private let midpointRepository: MidpointStationRepositoryProtocol
    private let recommendationRepository: PlaceRecommendationRepositoryProtocol

    public init(
        midpointRepository: MidpointStationRepositoryProtocol,
        recommendationRepository: PlaceRecommendationRepositoryProtocol
    ) {
        self.midpointRepository = midpointRepository
        self.recommendationRepository = recommendationRepository
    }

    public func execute(meetingId: Int) async throws -> [StationRecommendation] {
        async let stationsTask = midpointRepository.fetchMidpointStations(meetingId: meetingId)
        async let placesTask = recommendationRepository.fetchRecommendations(meetingId: meetingId)
        let (stations, places) = try await (stationsTask, placesTask)

        let sortedPlaces = places.sorted { $0.rank < $1.rank }

        return stations.sorted { $0.rank < $1.rank }.map { station in
            StationRecommendation(
                station: station,
                places: sortedPlaces.filter { $0.nearestStationId == station.stationId }
            )
        }
    }
}
