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
}

public struct LocationSearchRepositoryImpl: LocationSearchRepositoryProtocol {
    public init() {}

    public func searchStations(keyword: String) async throws -> [Station] {
        let response: KakaoLocalSearchResponseDTO = try await NetworkManager.shared.request(
            KakaoLocalEndpoint.searchKeyword(query: keyword, categoryGroupCode: Constant.subwayCategory)
        )
        return try response.documents.map { try $0.toEntity() }
    }
}
