import Entity

public protocol UpdateMemberProfileImageUseCase: Sendable {
    func execute(image: ProfileImageUpload) async throws
}
