//
//  DeleteDeparturePlaceUseCase.swift
//  UseCase
//

import Entity

public protocol DeleteDeparturePlaceUseCase: Sendable {
    func execute(id: Int) async throws
}
