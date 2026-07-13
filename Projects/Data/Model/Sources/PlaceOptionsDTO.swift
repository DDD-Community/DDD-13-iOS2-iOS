//
//  PlaceOptionsDTO.swift
//  Model
//

/// 장소 선택 옵션 API 응답 DTO.
public struct PlaceOptionsResponseDTO: Decodable, Sendable {
    public let categories: [String]
    public let vibes: [String]
}
