//
//  FindNearestStationUseCaseImpl.swift
//  DataUseCase
//
//  중심 좌표 기준 가장 가까운 지하철역을 Repository에서 조회한다
//

import Foundation

import DataInterface
import Entity
import UseCase

public final class FindNearestStationUseCaseImpl: FindNearestStationUseCase {
    private let repository: LocationSearchRepositoryProtocol

    public init(repository: LocationSearchRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(longitude: Double, latitude: Double) async throws -> Station? {
        try await repository.searchNearestStation(longitude: longitude, latitude: latitude)
    }
}
