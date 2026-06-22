//
//  Station.swift
//  Entity
//
//  Kakao Local 검색 결과로부터 매핑되는 출발지(역) 도메인 엔티티
//

import Foundation

public struct Station: Equatable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let addressName: String
    public let roadAddressName: String
    public let x: Double
    public let y: Double

    public init(
        id: String,
        name: String,
        addressName: String,
        roadAddressName: String,
        x: Double,
        y: Double
    ) {
        self.id = id
        self.name = name
        self.addressName = addressName
        self.roadAddressName = roadAddressName
        self.x = x
        self.y = y
    }
}
