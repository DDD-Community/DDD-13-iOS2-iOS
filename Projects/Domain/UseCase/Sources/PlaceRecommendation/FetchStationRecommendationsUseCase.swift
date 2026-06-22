//
//  FetchStationRecommendationsUseCase.swift
//  UseCase
//

import Entity

public protocol FetchStationRecommendationsUseCase: Sendable {
    func execute(meetingId: Int) async throws -> [StationRecommendation]
}
