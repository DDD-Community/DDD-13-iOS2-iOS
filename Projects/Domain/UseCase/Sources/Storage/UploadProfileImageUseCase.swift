//
//  UploadProfileImageUseCase.swift
//  UseCase
//

import Entity

public protocol UploadProfileImageUseCase: Sendable {
    func execute(_ image: UploadableImage) async throws
}
