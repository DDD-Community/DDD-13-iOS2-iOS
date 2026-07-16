import DataInterface
import UseCase

public final class UpdateMemberNicknameUseCaseImpl: UpdateMemberNicknameUseCase {
    private let repository: MemberProfileRepositoryProtocol

    public init(repository: MemberProfileRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(nickname: String) async throws {
        try await repository.updateNickname(nickname)
    }
}
