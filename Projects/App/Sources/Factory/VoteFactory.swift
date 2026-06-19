//
//  VoteFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Repository

enum VoteFactory {
    static func makeClient() -> VoteClient {
        let repository = VoteRepositoryImpl()
        let fetchDateVoteUseCase = FetchDateVoteUseCaseImpl(repository: repository)
        let fetchPlaceVoteUseCase = FetchPlaceVoteUseCaseImpl(repository: repository)
        let submitDateVoteUseCase = SubmitDateVoteUseCaseImpl(repository: repository)
        let confirmDateVoteUseCase = ConfirmDateVoteUseCaseImpl(repository: repository)
        return .live(
            fetchDateVoteUseCase: fetchDateVoteUseCase,
            fetchPlaceVoteUseCase: fetchPlaceVoteUseCase,
            submitDateVoteUseCase: submitDateVoteUseCase,
            confirmDateVoteUseCase: confirmDateVoteUseCase
        )
    }
}
