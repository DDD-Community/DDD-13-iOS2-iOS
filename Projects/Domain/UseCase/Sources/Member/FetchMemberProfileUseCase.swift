import Entity

public protocol FetchMemberProfileUseCase: Sendable {
    func execute() async throws -> MemberProfile
}
