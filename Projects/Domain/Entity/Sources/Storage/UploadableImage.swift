//
//  UploadableImage.swift
//  Entity
//

import Foundation

public struct UploadableImage: Sendable, Equatable {
    public let data: Data // 실제 업로드할 이미지 바이너리 
    public let contentType: String

    public init(data: Data, contentType: String) {
        self.data = data
        self.contentType = contentType
    }
}
