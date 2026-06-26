//
//  PlaceVoteTravelBurden.swift
//  Entity
//

import Foundation

/// 특정 후보 장소를 기준으로 한 멤버별 경로 부담 현황.
/// 후보 장소 정보와 멤버별 출발지·소요 시간·경로를 함께 제공한다.
public struct PlaceVoteTravelBurden: Equatable, Sendable {
    public let place: TravelBurdenPlace
    public let burdens: [MemberTravelBurden]

    public init(
        place: TravelBurdenPlace,
        burdens: [MemberTravelBurden]
    ) {
        self.place = place
        self.burdens = burdens
    }
}

/// 경로 부담 조회 기준이 되는 후보 장소.
public struct TravelBurdenPlace: Equatable, Sendable {
    public let placeId: Int
    public let name: String
    public let categoryLabel: PlaceCategory
    public let address: String
    public let latitude: Double?
    public let longitude: Double?

    public init(
        placeId: Int,
        name: String,
        categoryLabel: PlaceCategory,
        address: String,
        latitude: Double?,
        longitude: Double?
    ) {
        self.placeId = placeId
        self.name = name
        self.categoryLabel = categoryLabel
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// 멤버 한 명의 출발지부터 후보 장소까지의 경로 부담.
public struct MemberTravelBurden: Identifiable, Equatable, Sendable {
    public let memberId: Int
    public let name: String
    public let departureName: String
    public let isMe: Bool
    /// 소요 시간(초).
    public let seconds: Int
    /// 환승 횟수.
    public let transfers: Int
    /// 멤버 중 가장 오래 걸리는 경로인지 여부.
    public let isLongest: Bool
    public let path: [TravelPathPoint]

    public var id: Int { memberId }

    public init(
        memberId: Int,
        name: String,
        departureName: String,
        isMe: Bool,
        seconds: Int,
        transfers: Int,
        isLongest: Bool,
        path: [TravelPathPoint]
    ) {
        self.memberId = memberId
        self.name = name
        self.departureName = departureName
        self.isMe = isMe
        self.seconds = seconds
        self.transfers = transfers
        self.isLongest = isLongest
        self.path = path
    }
}

/// 경로를 구성하는 지점(지하철역) 좌표.
public struct TravelPathPoint: Identifiable, Equatable, Sendable {
    public let stationId: Int
    public let latitude: Double
    public let longitude: Double

    public var id: Int { stationId }

    public init(
        stationId: Int,
        latitude: Double,
        longitude: Double
    ) {
        self.stationId = stationId
        self.latitude = latitude
        self.longitude = longitude
    }
}
