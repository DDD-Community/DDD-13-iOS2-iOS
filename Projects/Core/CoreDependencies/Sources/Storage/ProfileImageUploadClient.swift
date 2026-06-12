//
//  ProfileImageUploadClient.swift
//  CoreDependencies
//

import ComposableArchitecture
import Entity
import UseCase

@DependencyClient
public struct ProfileImageUploadClient: Sendable {
    public var upload: @Sendable (_ image: UploadableImage) async throws -> Void
}

public extension ProfileImageUploadClient {
    static func live(useCase: UploadProfileImageUseCase) -> Self {
        Self { image in
            try await useCase.execute(image)
        }
    }
}

extension ProfileImageUploadClient: DependencyKey {
    public static let liveValue = ProfileImageUploadClient()
    public static let testValue = ProfileImageUploadClient(
        upload: { _ in }
    )
}

public extension DependencyValues {
    var profileImageUploadClient: ProfileImageUploadClient {
        get { self[ProfileImageUploadClient.self] }
        set { self[ProfileImageUploadClient.self] = newValue }
    }
}
