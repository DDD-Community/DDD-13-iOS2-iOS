//
//  RegisterMember.swift
//  Entity
//

public struct RegisterMember: Sendable, Equatable {
    public let nickname: String
    public let agreedTermsIds: [Int]
    public let departureLabel: String
    public let departureAddress: String
    public let latitude: Double
    public let longitude: Double

    public init(nickname: String, agreedTermsIds: [Int], departureLabel: String, departureAddress: String, latitude: Double, longitude: Double) {
        self.nickname = nickname
        self.agreedTermsIds = agreedTermsIds
        self.departureLabel = departureLabel
        self.departureAddress = departureAddress
        self.latitude = latitude
        self.longitude = longitude
    }
}
