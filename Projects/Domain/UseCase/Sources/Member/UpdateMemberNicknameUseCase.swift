public protocol UpdateMemberNicknameUseCase: Sendable {
    func execute(nickname: String) async throws
}
