//
//  StorageRepositoryProtocol.swift
//  DataInterface
//

import Entity
import Foundation

public protocol StorageRepositoryProtocol: Sendable {
    func getSignedUploadURL(imageType: String, contentType: String) async throws -> SignedUploadURL // signedUploadUrl 조회
    
    func putImage(data: Data, contentType: String, signedUrl: URL) async throws // 이미지 업로드
}
