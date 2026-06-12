//
//  UploadProfileImageUseCaseImpl.swift
//  DataUseCase
//

import DataInterface
import Entity
import UseCase
import Utill

public final class UploadProfileImageUseCaseImpl: UploadProfileImageUseCase {
    private let repository: StorageRepositoryProtocol

    public init(repository: StorageRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ image: UploadableImage) async throws {
        Log.debug("업로드 이미지 정보: \(image)")
        let signed = try await repository.getSignedUploadURL( // signedUrl get
            imageType: "PROFILE",
            contentType: image.contentType
        )

        try await repository.putImage( // signedUrl로 put 요청
            data: image.data,
            contentType: image.contentType,
            signedUrl: signed.signedUrl
        )
    }
}
