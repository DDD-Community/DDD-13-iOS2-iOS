//
//  StorageRepositoryImpl.swift
//  Repository
//

import API
import DataInterface
import Entity
import Foundation
import Utill
import Model
import Networking

public final class StorageRepositoryImpl: StorageRepositoryProtocol {
    public init() {}

    public func getSignedUploadURL(
        imageType: String,
        contentType: String
    ) async throws -> SignedUploadURL {
        let dto = SignedUploadURLRequestDTO(
            imageType: imageType,
            contentType: contentType
        )

        let response: SignedUploadURLResponseDTO = try await NetworkManager.shared.request(
            StorageEndPoint.getSignedUploadURL(dto)
        )

        return try response.toEntity()
    }

    public func putImage(
        data: Data,
        contentType: String,
        signedUrl: URL
    ) async throws {
        var request = URLRequest(url: signedUrl)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (_, response) = try await URLSession.shared.data(for: request)
        Log.debug("put Image response: \(response)")
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode)
        else {
            throw StorageRepositoryError.uploadFailed
        }
    }
}

public enum StorageRepositoryError: Error, Sendable {
    case uploadFailed
}
