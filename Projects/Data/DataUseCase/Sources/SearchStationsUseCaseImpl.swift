//
//  SearchStationsUseCaseImpl.swift
//  DataUseCase
//
//  Repository에서 받은 원본 결과에 서울 한정 필터/역명 prefix 필터/anchor 거리 정렬을 적용한다
//

import DataInterface
import Entity
import Foundation
import UseCase

public final class SearchStationsUseCaseImpl: SearchStationsUseCase {
    private let repository: LocationSearchRepositoryProtocol

    public init(repository: LocationSearchRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(keyword: String) async throws -> [Station] {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let raw = try await repository.searchStations(keyword: trimmed)
        return StationResultProcessor.process(raw, keyword: trimmed)
    }
}
