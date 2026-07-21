import DataInterface
import Entity
import UseCase

public final class UpdateMemberProfileImageUseCaseImpl: UpdateMemberProfileImageUseCase {
    private let repository: MemberProfileRepositoryProtocol

    public init(repository: MemberProfileRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(image: ProfileImageUpload) async throws {
        try await repository.updateProfileImage(image)
    }
}
