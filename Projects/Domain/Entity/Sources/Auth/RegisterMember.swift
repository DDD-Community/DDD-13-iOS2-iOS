//
//  RegisterMember.swift
//  Entity
//

public struct RegisterMember: Sendable, Equatable {
    public let nickname: String
    public let agreedTermsIds: [Int]
    public let departureLabel: String // 출발지 라벨 (태그같은 느낌)
    public let departureAddress: String
    public let departureRoadAddress: String
    public let departurePlaceName: String
    public let latitude: Double
    public let longitude: Double

    public init(nickname: String, agreedTermsIds: [Int], departureLabel: String, departureAddress: String, departureRoadAddress: String, departurePlaceName: String, latitude: Double, longitude: Double) {
        self.nickname = nickname
        self.agreedTermsIds = agreedTermsIds
        self.departureLabel = departureLabel
        self.departureAddress = departureAddress
        self.departureRoadAddress = departureRoadAddress
        self.departurePlaceName = departurePlaceName
        self.latitude = latitude
        self.longitude = longitude
    }
}
