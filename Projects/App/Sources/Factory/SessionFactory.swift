import CoreDependencies
import DataUseCase
import Repository

enum SessionFactory {
    static func makeClient() -> SessionClient {
        let repository = SessionRepositoryImpl()
        let useCase = LogoutUseCaseImpl(repository: repository)
        return .live(useCase: useCase)
    }
}
