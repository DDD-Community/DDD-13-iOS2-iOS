//
//  PlaceDetailsClient.swift
//  CoreDependencies
//
//  placeId 기반 장소 상세 조회를 Feature에 노출하는 TCA struct-based client
//

import Foundation

import ComposableArchitecture

import Entity
import UseCase

@DependencyClient
public struct PlaceDetailsClient: Sendable {
    public var fetchPlaceDetails: @Sendable (_ ids: [Int]) async throws -> [PlaceDetail]
}

public extension PlaceDetailsClient {
    static func live(useCase: FetchPlaceDetailsUseCase) -> Self {
        Self(
            fetchPlaceDetails: { ids in
                try await useCase.execute(ids: ids)
            }
        )
    }
}

extension PlaceDetailsClient: DependencyKey {
    public static var liveValue: PlaceDetailsClient {
        PlaceDetailsClient(
            fetchPlaceDetails: { _ in throw PlaceDetailsClientError.notImplemented }
        )
    }

    public static let testValue: PlaceDetailsClient = PlaceDetailsClient()
}

public extension DependencyValues {
    var placeDetailsClient: PlaceDetailsClient {
        get { self[PlaceDetailsClient.self] }
        set { self[PlaceDetailsClient.self] = newValue }
    }
}

/// PlaceDetailsClient에서 Presentation 계층이 이해할 수 있는 공통 에러 타입입니다.
public enum PlaceDetailsClientError: LocalizedError, Equatable, Sendable {
    /// 아직 live 구현이 주입되지 않은 Client를 호출했을 때 사용하는 임시 에러입니다.
    case notImplemented

    public var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "PlaceDetailsClient의 live 구현이 주입되지 않았습니다."
        }
    }
}
