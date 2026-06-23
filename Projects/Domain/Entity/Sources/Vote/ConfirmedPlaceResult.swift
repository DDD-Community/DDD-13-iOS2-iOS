//
//  ConfirmedPlaceResult.swift
//  Entity
//

import Foundation

public struct ConfirmedPlaceResult: Equatable, Sendable {
    public let placeId: Int
    public let placeName: String
    public let address: String
    // TODO: 서버에 확정 장소 좌표 응답이 추가되면 non-optional로 전환
    public let latitude: Double?
    public let longitude: Double?
    public let confirmedAt: String
    public let candidates: [ConfirmedPlaceCandidate]

    public init(
        placeId: Int,
        placeName: String,
        address: String,
        latitude: Double?,
        longitude: Double?,
        confirmedAt: String,
        candidates: [ConfirmedPlaceCandidate]
    ) {
        self.placeId = placeId
        self.placeName = placeName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.confirmedAt = confirmedAt
        self.candidates = candidates
    }
}

public struct ConfirmedPlaceCandidate: Equatable, Sendable {
    public let placeId: Int
    public let voteCount: Int
    public let totalSeconds: Int
    public let totalTransfers: Int

    public init(
        placeId: Int,
        voteCount: Int,
        totalSeconds: Int,
        totalTransfers: Int
    ) {
        self.placeId = placeId
        self.voteCount = voteCount
        self.totalSeconds = totalSeconds
        self.totalTransfers = totalTransfers
    }
}
