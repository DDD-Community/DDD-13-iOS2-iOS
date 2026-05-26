//
//  LocationSearchRepositoryProtocol.swift
//  DataInterface
//
//  외부 위치 검색(Kakao Local 등) 추상화
//

import Foundation

import Entity

public protocol LocationSearchRepositoryProtocol: Sendable {
    func searchStations(keyword: String) async throws -> [Station]
}
