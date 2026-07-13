//
//  LocationSearchRepositoryImpl.swift
//  Repository
//
//  LocationSearchRepositoryProtocol 구현체. Kakao Local 키워드 검색 호출
//

import Foundation

import API
import DataInterface
import Entity
import Model
import Networking

private enum Constant {
    static let subwayCategory = "SW8"
    static let nearestSearchRadius = 20000
    static let sortByDistance = "distance"
}

public struct LocationSearchRepositoryImpl: LocationSearchRepositoryProtocol {
    public init() {}

    public func searchStations(keyword: String) async throws -> [Station] {
        let response: KakaoLocalSearchResponseDTO = try await NetworkManager.shared.request(
            KakaoLocalEndpoint.searchKeyword(query: keyword, categoryGroupCode: Constant.subwayCategory)
        )
        return try response.documents.map { try $0.toEntity() }
    }

    public func searchNearestStation(longitude: Double, latitude: Double) async throws -> Station? {
        let response: KakaoLocalSearchResponseDTO = try await NetworkManager.shared.request(
            KakaoLocalEndpoint.searchCategory(
                x: String(longitude),
                y: String(latitude),
                radius: Constant.nearestSearchRadius,
                categoryGroupCode: Constant.subwayCategory,
                sort: Constant.sortByDistance
            )
        )
        return try response.documents.first?.toEntity()
    }
}
