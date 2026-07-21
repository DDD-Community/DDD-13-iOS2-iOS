import CoreDependencies
import DataUseCase
import Repository

enum MemberProfileFactory {
    static func makeClient() -> MemberProfileClient {
        let repository = MemberProfileRepositoryImpl()
        return .live(
            fetchUseCase: FetchMemberProfileUseCaseImpl(repository: repository),
            updateNicknameUseCase: UpdateMemberNicknameUseCaseImpl(repository: repository),
            updateProfileImageUseCase: UpdateMemberProfileImageUseCaseImpl(repository: repository)
        )
    }
}
