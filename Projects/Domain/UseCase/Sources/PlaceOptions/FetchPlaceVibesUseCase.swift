//
//  FetchPlaceVibesUseCase.swift
//  UseCase
//

public protocol FetchPlaceVibesUseCase: Sendable {
    func execute() async throws -> [String]
}
