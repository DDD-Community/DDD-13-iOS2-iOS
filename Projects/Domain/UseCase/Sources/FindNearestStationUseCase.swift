//
//  FindNearestStationUseCase.swift
//  UseCase
//
//  중심 좌표 기준 가장 가까운 지하철역을 찾는 도메인 UseCase 인터페이스
//

import Foundation

import Entity

public protocol FindNearestStationUseCase: Sendable {
    func execute(longitude: Double, latitude: Double) async throws -> Station?
}
