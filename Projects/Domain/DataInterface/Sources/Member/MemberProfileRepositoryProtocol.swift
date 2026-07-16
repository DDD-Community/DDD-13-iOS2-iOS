import Entity

public protocol MemberProfileRepositoryProtocol: Sendable {
    func fetchProfile() async throws -> MemberProfile
    func updateNickname(_ nickname: String) async throws
    func updateProfileImage(_ image: ProfileImageUpload) async throws
}
