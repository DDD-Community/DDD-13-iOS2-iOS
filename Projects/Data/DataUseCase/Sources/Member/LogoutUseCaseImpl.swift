import DataInterface
import UseCase

public final class LogoutUseCaseImpl: LogoutUseCase {
    private let repository: SessionRepositoryProtocol

    public init(repository: SessionRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async {
        repository.clearLocalSession()
    }
}
