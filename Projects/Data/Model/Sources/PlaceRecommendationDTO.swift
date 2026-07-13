//
//  PlaceRecommendationDTO.swift
//  Model
//

public struct StartPlaceRecommendationRequestDTO: Encodable, Sendable {
    public let radiusKm: Double

    public init(radiusKm: Double) {
        self.radiusKm = radiusKm
    }
}
