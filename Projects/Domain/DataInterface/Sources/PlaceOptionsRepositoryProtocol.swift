//
//  PlaceOptionsRepositoryProtocol.swift
//  DataInterface
//

public protocol PlaceOptionsRepositoryProtocol: Sendable {
    func fetchVibes() async throws -> [String]
}
