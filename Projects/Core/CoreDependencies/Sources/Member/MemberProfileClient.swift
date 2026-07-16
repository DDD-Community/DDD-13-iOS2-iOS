import ComposableArchitecture
import Entity
import UseCase

@DependencyClient
public struct MemberProfileClient: Sendable {
    public var fetchProfile: @Sendable () async throws -> MemberProfile
    public var updateNickname: @Sendable (_ nickname: String) async throws -> Void
    public var updateProfileImage: @Sendable (_ image: ProfileImageUpload) async throws -> Void
}

public extension MemberProfileClient {
    static func live(
        fetchUseCase: any FetchMemberProfileUseCase,
        updateNicknameUseCase: any UpdateMemberNicknameUseCase,
        updateProfileImageUseCase: any UpdateMemberProfileImageUseCase
    ) -> Self {
        Self(
            fetchProfile: { try await fetchUseCase.execute() },
            updateNickname: { nickname in
                try await updateNicknameUseCase.execute(nickname: nickname)
            },
            updateProfileImage: { image in
                try await updateProfileImageUseCase.execute(image: image)
            }
        )
    }
}

extension MemberProfileClient: DependencyKey {
    public static let liveValue = Self()
    public static let testValue = Self()
}

public extension DependencyValues {
    var memberProfileClient: MemberProfileClient {
        get { self[MemberProfileClient.self] }
        set { self[MemberProfileClient.self] = newValue }
    }
}
