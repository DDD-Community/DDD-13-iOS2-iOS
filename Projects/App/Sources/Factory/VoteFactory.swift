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
        let fetchConfirmedPlaceResultUseCase = FetchConfirmedPlaceResultUseCaseImpl(repository: repository)
        let startDateVoteUseCase = StartDateVoteUseCaseImpl(repository: repository)
        let submitDateVoteUseCase = SubmitDateVoteUseCaseImpl(repository: repository)
        let confirmDateVoteUseCase = ConfirmDateVoteUseCaseImpl(repository: repository)
        let startPlaceVoteUseCase = StartPlaceVoteUseCaseImpl(repository: repository)
        let submitPlaceVoteUseCase = SubmitPlaceVoteUseCaseImpl(repository: repository)
        let confirmPlaceVoteUseCase = ConfirmPlaceVoteUseCaseImpl(repository: repository)
        let fetchPlaceVoteTravelBurdenUseCase = FetchPlaceVoteTravelBurdenUseCaseImpl(repository: repository)
        let fetchPlaceVoteParticipantsUseCase = FetchPlaceVoteParticipantsUseCaseImpl(repository: repository)
        return .live(
            fetchDateVoteUseCase: fetchDateVoteUseCase,
            fetchPlaceVoteUseCase: fetchPlaceVoteUseCase,
            fetchConfirmedPlaceResultUseCase: fetchConfirmedPlaceResultUseCase,
            startDateVoteUseCase: startDateVoteUseCase,
            submitDateVoteUseCase: submitDateVoteUseCase,
            confirmDateVoteUseCase: confirmDateVoteUseCase,
            startPlaceVoteUseCase: startPlaceVoteUseCase,
            submitPlaceVoteUseCase: submitPlaceVoteUseCase,
            confirmPlaceVoteUseCase: confirmPlaceVoteUseCase,
            fetchPlaceVoteTravelBurdenUseCase: fetchPlaceVoteTravelBurdenUseCase,
            fetchPlaceVoteParticipantsUseCase: fetchPlaceVoteParticipantsUseCase
        )
    }
}
