//
//  SearchStationsClient.swift
//  CoreDependencies
//
//  Kakao Local 키워드 검색을 Feature에 노출하는 TCA struct-based client
//

import Foundation

import ComposableArchitecture

import Entity
import UseCase

@DependencyClient
public struct SearchStationsClient: Sendable {
    public var searchStations: @Sendable (_ keyword: String) async throws -> [Station]
}

public extension SearchStationsClient {
    static func live(useCase: SearchStationsUseCase) -> Self {
        Self(
            searchStations: { keyword in
                try await useCase.execute(keyword: keyword)
            }
        )
    }
}

extension SearchStationsClient: DependencyKey {
    public static let liveValue: SearchStationsClient = SearchStationsClient()
    public static let testValue: SearchStationsClient = SearchStationsClient()
}

public extension DependencyValues {
    var searchStationsClient: SearchStationsClient {
        get { self[SearchStationsClient.self] }
        set { self[SearchStationsClient.self] = newValue }
    }
}
