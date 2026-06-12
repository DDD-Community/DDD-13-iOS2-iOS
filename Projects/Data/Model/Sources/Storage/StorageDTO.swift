//
//  StorageDTO.swift
//  Model
//

import Entity
import Foundation

public struct SignedUploadURLRequestDTO: Encodable, Sendable {
    public let imageType: String
    public let contentType: String
    
    public init(imageType: String, contentType: String) {
        self.imageType = imageType
        self.contentType = contentType
    }
}

public struct SignedUploadURLResponseDTO: Decodable, Sendable {
    public let signedUploadUrl: String
    public let objectKey: String
}

public extension SignedUploadURLResponseDTO {
    func toEntity() throws -> SignedUploadURL {
        guard let url = URL(string: signedUploadUrl) else {
            throw StorageDTOError.invalidSignedURL
        }
        
        return SignedUploadURL(
            signedUrl: url,
            objectKey: objectKey
        )
    }
}

public enum StorageDTOError: Error, Sendable {
    case invalidSignedURL
}
