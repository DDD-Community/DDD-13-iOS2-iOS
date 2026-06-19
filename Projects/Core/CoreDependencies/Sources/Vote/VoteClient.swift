//
//  VoteClient.swift
//  CoreDependencies
//

import ComposableArchitecture

import DomainInterface
import Entity
import UseCase

@DependencyClient
public struct VoteClient: Sendable {
    public var fetchDateVote: @Sendable (_ meetingId: Int64) async throws -> DateVote
    public var fetchPlaceVote: @Sendable (_ meetingId: Int64) async throws -> PlaceVote
}

public extension VoteClient {
    static func live(
        fetchDateVoteUseCase: any FetchDateVoteUseCase,
        fetchPlaceVoteUseCase: any FetchPlaceVoteUseCase
    ) -> Self {
        Self(
            fetchDateVote: { meetingId in
                try await fetchDateVoteUseCase.execute(meetingId: meetingId)
            },
            fetchPlaceVote: { meetingId in
                try await fetchPlaceVoteUseCase.execute(meetingId: meetingId)
            }
        )
    }
}

extension VoteClient: DependencyKey {
    public static var liveValue: VoteClient {
        VoteClient(
            fetchDateVote: { _ in throw VoteClientError.notImplemented },
            fetchPlaceVote: { _ in throw VoteClientError.notImplemented }
        )
    }

    public static let testValue: VoteClient = VoteClient()

    public static let previewValue: VoteClient = VoteClient(
        fetchDateVote: { _ in previewDateVote },
        fetchPlaceVote: { _ in previewPlaceVote }
    )
}

// MARK: - Preview Sample

public extension VoteClient {
    /// 프리뷰/디자인 확인용 샘플 날짜 투표 현황.
    static let previewDateVote: DateVote = DateVote(
        dateVoteStatus: .inProgress,
        sessionStatus: .active,
        deadline: "2026-06-25",
        options: [
            DateVoteOption(
                id: 1,
                candidateDate: "2026-06-25",
                voteCount: 2,
                isMyVote: true,
                voters: [
                    DateVoteVoter(id: 1, nickname: "지혜", profileImageUrl: nil),
                    DateVoteVoter(id: 2, nickname: "민수", profileImageUrl: nil)
                ]
            ),
            DateVoteOption(
                id: 2,
                candidateDate: "2026-06-26",
                voteCount: 1,
                isMyVote: false,
                voters: [
                    DateVoteVoter(id: 3, nickname: "수진", profileImageUrl: nil)
                ]
            )
        ]
    )

    /// 프리뷰/디자인 확인용 샘플 장소 투표 현황.
    static let previewPlaceVote: PlaceVote = PlaceVote(
        deadline: "2026-06-25T15:00:00.000Z",
        sessionStatus: .active,
        totalParticipants: 3,
        votedCount: 2,
        candidates: [
            PlaceVoteCandidate(
                id: 1,
                voteCount: 2,
                isMyVote: true,
                travelBurdens: [
                    PlaceTravelBurden(id: 1, seconds: 1800, transfers: 1, isLongest: false),
                    PlaceTravelBurden(id: 2, seconds: 3600, transfers: 2, isLongest: true)
                ]
            )
        ]
    )
}

public extension DependencyValues {
    var voteClient: VoteClient {
        get { self[VoteClient.self] }
        set { self[VoteClient.self] = newValue }
    }
}
