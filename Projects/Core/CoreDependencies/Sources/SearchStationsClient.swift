//
//  SearchStationsClient.swift
//  CoreDependencies
//
//  Kakao Local 키워드 검색을 Feature에 노출하는 TCA struct-based client
//

import Foundation

import ComposableArchitecture

import DomainInterface
import Entity
import UseCase

@DependencyClient
public struct SearchStationsClient: Sendable {
    public var searchStations: @Sendable (_ keyword: String) async throws -> [Station]
    public var findNearestStation: @Sendable (_ longitude: Double, _ latitude: Double) async throws -> Station?
}

public extension SearchStationsClient {
    static func live(
        searchByKeyword: SearchStationsByKeywordUseCase,
        findNearest: FindNearestStationUseCase
    ) -> Self {
        Self(
            searchStations: { keyword in
                try await searchByKeyword.execute(keyword: keyword)
            },
            findNearestStation: { longitude, latitude in
                try await findNearest.execute(longitude: longitude, latitude: latitude)
            }
        )
    }
}

extension SearchStationsClient: DependencyKey {
    public static var liveValue: SearchStationsClient {
        SearchStationsClient(
            searchStations: { _ in throw SearchStationsClientError.notImplemented },
            findNearestStation: { _, _ in throw SearchStationsClientError.notImplemented }
        )
    }

    public static let testValue: SearchStationsClient = SearchStationsClient()
}

public extension DependencyValues {
    var searchStationsClient: SearchStationsClient {
        get { self[SearchStationsClient.self] }
        set { self[SearchStationsClient.self] = newValue }
    }
}
