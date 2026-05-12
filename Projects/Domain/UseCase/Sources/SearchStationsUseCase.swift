//
//  SearchStationsUseCase.swift
//  UseCase
//
//  키워드로 지하철역(출발지)을 검색하는 도메인 UseCase 인터페이스
//

import Entity
import Foundation

public protocol SearchStationsUseCase: Sendable {
    func execute(keyword: String) async throws -> [Station]
}
