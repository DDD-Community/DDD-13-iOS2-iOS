//
//  NearbyPlacesClient.swift
//  CoreDependencies
//
//  역 기반 근처 장소 조회를 Feature에 노출하는 TCA struct-based client
//

import Foundation

import ComposableArchitecture

import Entity
import UseCase

@DependencyClient
public struct NearbyPlacesClient: Sendable {
    public var fetchNearbyPlaces: @Sendable (
        _ latitude: Double,
        _ longitude: Double,
        _ radiusMeters: Double,
        _ category: String?
    ) async throws -> [NearbyPlace]
}

public extension NearbyPlacesClient {
    static func live(useCase: FetchNearbyPlacesUseCase) -> Self {
        Self(
            fetchNearbyPlaces: { latitude, longitude, radiusMeters, category in
                try await useCase.execute(
                    latitude: latitude,
                    longitude: longitude,
                    radiusMeters: radiusMeters,
                    category: category
                )
            }
        )
    }
}

extension NearbyPlacesClient: DependencyKey {
    public static var liveValue: NearbyPlacesClient {
        NearbyPlacesClient(
            fetchNearbyPlaces: { _, _, _, _ in throw NearbyPlacesClientError.notImplemented }
        )
    }

    public static let testValue: NearbyPlacesClient = NearbyPlacesClient()
}

public extension DependencyValues {
    var nearbyPlacesClient: NearbyPlacesClient {
        get { self[NearbyPlacesClient.self] }
        set { self[NearbyPlacesClient.self] = newValue }
    }
}

/// NearbyPlacesClient에서 Presentation 계층이 이해할 수 있는 공통 에러 타입입니다.
public enum NearbyPlacesClientError: LocalizedError, Equatable, Sendable {
    /// 아직 live 구현이 주입되지 않은 Client를 호출했을 때 사용하는 임시 에러입니다.
    case notImplemented

    public var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "NearbyPlacesClient의 live 구현이 주입되지 않았습니다."
        }
    }
}
