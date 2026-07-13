//
//  PlaceOptionsRepositoryImpl.swift
//  Repository
//

import API
import DataInterface
import Model
import Networking

public final class PlaceOptionsRepositoryImpl: PlaceOptionsRepositoryProtocol {
    public init() {}

    public func fetchVibes() async throws -> [String] {
        let response: PlaceOptionsResponseDTO = try await NetworkManager.shared.request(PlaceOptionsEndpoint.fetch)
        return response.vibes
    }
}
