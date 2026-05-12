//
//  KakaoLocalSearchResponseDTO.swift
//  Model
//
//  Kakao Local 키워드 검색 API 응답 DTO와 도메인 매핑
//

import Entity
import Foundation

public struct KakaoLocalSearchResponseDTO: Decodable, Sendable {
    public let documents: [Document]

    public struct Document: Decodable, Sendable {
        public let placeName: String
        public let addressName: String
        public let roadAddressName: String
        public let x: String
        public let y: String

        enum CodingKeys: String, CodingKey {
            case placeName = "place_name"
            case addressName = "address_name"
            case roadAddressName = "road_address_name"
            case x
            case y
        }
    }
}

public extension KakaoLocalSearchResponseDTO.Document {
    func toEntity() throws -> Station {
        guard let xCoordinate = Double(x), let yCoordinate = Double(y) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "Kakao Local 좌표 변환 실패: x=\(x), y=\(y)"
                )
            )
        }

        return Station(
            id: "\(placeName)|\(x),\(y)",
            name: placeName,
            addressName: addressName,
            roadAddressName: roadAddressName,
            x: xCoordinate,
            y: yCoordinate
        )
    }
}
