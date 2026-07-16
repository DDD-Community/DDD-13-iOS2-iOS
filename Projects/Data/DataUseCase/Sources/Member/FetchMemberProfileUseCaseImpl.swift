import DataInterface
import Entity
import UseCase

public final class FetchMemberProfileUseCaseImpl: FetchMemberProfileUseCase {
    private let repository: MemberProfileRepositoryProtocol

    public init(repository: MemberProfileRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> MemberProfile {
        try await repository.fetchProfile()
    }
}
