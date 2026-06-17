//
//  DeparturePlace.swift
//  Entity
//

import Foundation

public struct DeparturePlace: Identifiable, Equatable, Sendable {
    public let id: Int
    public let label: String
    public let address: String
    public let roadAddress: String
    public let placeName: String
    public let latitude: Double
    public let longitude: Double
    public let isDefault: Bool

    public init(
        id: Int,
        label: String,
        address: String,
        roadAddress: String,
        placeName: String,
        latitude: Double,
        longitude: Double,
        isDefault: Bool
    ) {
        self.id = id
        self.label = label
        self.address = address
        self.roadAddress = roadAddress
        self.placeName = placeName
        self.latitude = latitude
        self.longitude = longitude
        self.isDefault = isDefault
    }
}
