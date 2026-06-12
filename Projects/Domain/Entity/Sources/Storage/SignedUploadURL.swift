//
//  SignedUploadURL.swift
//  Entity
//

import Foundation

public struct SignedUploadURL: Sendable, Equatable {
    public let signedUrl: URL
    public let objectKey: String
    
    public init(signedUrl: URL, objectKey: String) {
        self.signedUrl = signedUrl
        self.objectKey = objectKey
    }
}
