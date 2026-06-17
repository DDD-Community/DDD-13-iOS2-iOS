//
//  DeparturePlaceDTO.swift
//  Model
//

import Entity

public struct DeparturePlaceResponseDTO: Decodable, Sendable {
    public let id: Int64
    public let label: String
    public let address: String
    public let roadAddress: String
    public let placeName: String
    public let latitude: Double
    public let longitude: Double
    public let isDefault: Bool
}

public struct UpdateDeparturePlaceRequestDTO: Encodable, Sendable {
    public let label: String
    public let address: String
    public let roadAddress: String
    public let placeName: String
    public let latitude: Double
    public let longitude: Double

    public init(
        label: String,
        address: String,
        roadAddress: String,
        placeName: String,
        latitude: Double,
        longitude: Double
    ) {
        self.label = label
        self.address = address
        self.roadAddress = roadAddress
        self.placeName = placeName
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct AddDeparturePlaceRequestDTO: Encodable, Sendable {
    public let label: String
    public let address: String
    public let roadAddress: String
    public let placeName: String
    public let latitude: Double
    public let longitude: Double
    public let isDefault: Bool

    public init(
        label: String,
        address: String,
        roadAddress: String,
        placeName: String,
        latitude: Double,
        longitude: Double,
        isDefault: Bool
    ) {
        self.label = label
        self.address = address
        self.roadAddress = roadAddress
        self.placeName = placeName
        self.latitude = latitude
        self.longitude = longitude
        self.isDefault = isDefault
    }
}

// MARK: - toEntity

public extension DeparturePlaceResponseDTO {
    func toEntity() -> DeparturePlace {
        DeparturePlace(
            id: id,
            label: label,
            address: address,
            roadAddress: roadAddress,
            placeName: placeName,
            latitude: latitude,
            longitude: longitude,
            isDefault: isDefault
        )
    }
}
