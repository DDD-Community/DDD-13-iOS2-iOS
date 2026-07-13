//
//  PlacePickClient.swift
//  CoreDependencies
//

import ComposableArchitecture

import Entity
import UseCase

@DependencyClient
public struct PlacePickClient: Sendable {
    public var togglePlacePick: @Sendable (_ meetingId: Int, _ placeId: Int, _ isCurrentlyPicked: Bool) async throws -> Void
    public var fetchPickStatus: @Sendable (_ meetingId: Int) async throws -> PlacePickStatus
}

public extension PlacePickClient {
    static func live(
        toggleUseCase: any TogglePlacePickUseCase,
        fetchUseCase: any FetchPlacePickStatusUseCase
    ) -> Self {
        Self(
            togglePlacePick: { meetingId, placeId, isCurrentlyPicked in
                try await toggleUseCase.execute(
                    meetingId: meetingId,
                    placeId: placeId,
                    isCurrentlyPicked: isCurrentlyPicked
                )
            },
            fetchPickStatus: { meetingId in
                try await fetchUseCase.execute(meetingId: meetingId)
            }
        )
    }
}

extension PlacePickClient: DependencyKey {
    public static let liveValue: PlacePickClient = PlacePickClient()
    public static let testValue: PlacePickClient = PlacePickClient()

    public static let previewValue: PlacePickClient = PlacePickClient(
        togglePlacePick: { _, _, _ in },
        fetchPickStatus: { _ in PlacePickStatus(members: [], myPicks: []) }
    )
}

public extension DependencyValues {
    var placePickClient: PlacePickClient {
        get { self[PlacePickClient.self] }
        set { self[PlacePickClient.self] = newValue }
    }
}
