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
    public var fetchDateVote: @Sendable (_ meetingId: Int) async throws -> DateVote
    public var fetchPlaceVote: @Sendable (_ meetingId: Int) async throws -> PlaceVote
    public var fetchConfirmedPlaceResult: @Sendable (_ meetingId: Int) async throws -> ConfirmedPlaceResult
    public var startDateVote: @Sendable (_ meetingId: Int, _ candidateDates: [String], _ durationDays: Int) async throws -> Void
    public var submitDateVote: @Sendable (_ meetingId: Int, _ optionIds: [Int]) async throws -> Void
    public var confirmDateVote: @Sendable (_ meetingId: Int, _ optionId: Int) async throws -> Void
    public var startPlaceVote: @Sendable (_ meetingId: Int, _ durationDays: Int) async throws -> Void
    public var submitPlaceVote: @Sendable (_ meetingId: Int, _ placeIds: [Int]) async throws -> Void
    public var fetchPlaceVoteTravelBurden: @Sendable (_ meetingId: Int, _ placeId: Int) async throws -> PlaceVoteTravelBurden
    public var fetchPlaceVoteParticipants: @Sendable (_ meetingId: Int) async throws -> [PlaceVoteParticipant]
}

public extension VoteClient {
    static func live(
        fetchDateVoteUseCase: any FetchDateVoteUseCase,
        fetchPlaceVoteUseCase: any FetchPlaceVoteUseCase,
        fetchConfirmedPlaceResultUseCase: any FetchConfirmedPlaceResultUseCase,
        startDateVoteUseCase: any StartDateVoteUseCase,
        submitDateVoteUseCase: any SubmitDateVoteUseCase,
        confirmDateVoteUseCase: any ConfirmDateVoteUseCase,
        startPlaceVoteUseCase: any StartPlaceVoteUseCase,
        submitPlaceVoteUseCase: any SubmitPlaceVoteUseCase,
        fetchPlaceVoteTravelBurdenUseCase: any FetchPlaceVoteTravelBurdenUseCase,
        fetchPlaceVoteParticipantsUseCase: any FetchPlaceVoteParticipantsUseCase
    ) -> Self {
        Self(
            fetchDateVote: { meetingId in
                try await fetchDateVoteUseCase.execute(meetingId: meetingId)
            },
            fetchPlaceVote: { meetingId in
                try await fetchPlaceVoteUseCase.execute(meetingId: meetingId)
            },
            fetchConfirmedPlaceResult: { meetingId in
                try await fetchConfirmedPlaceResultUseCase.execute(meetingId: meetingId)
            },
            startDateVote: { meetingId, candidateDates, durationDays in
                try await startDateVoteUseCase.execute(
                    meetingId: meetingId,
                    candidateDates: candidateDates,
                    durationDays: durationDays
                )
            },
            submitDateVote: { meetingId, optionIds in
                try await submitDateVoteUseCase.execute(meetingId: meetingId, optionIds: optionIds)
            },
            confirmDateVote: { meetingId, optionId in
                try await confirmDateVoteUseCase.execute(meetingId: meetingId, optionId: optionId)
            },
            startPlaceVote: { meetingId, durationDays in
                try await startPlaceVoteUseCase.execute(meetingId: meetingId, durationDays: durationDays)
            },
            submitPlaceVote: { meetingId, placeIds in
                try await submitPlaceVoteUseCase.execute(meetingId: meetingId, placeIds: placeIds)
            },
            fetchPlaceVoteTravelBurden: { meetingId, placeId in
                try await fetchPlaceVoteTravelBurdenUseCase.execute(meetingId: meetingId, placeId: placeId)
            },
            fetchPlaceVoteParticipants: { meetingId in
                try await fetchPlaceVoteParticipantsUseCase.execute(meetingId: meetingId)
            }
        )
    }
}

extension VoteClient: DependencyKey {
    public static var liveValue: VoteClient {
        VoteClient(
            fetchDateVote: { _ in throw VoteClientError.notImplemented },
            fetchPlaceVote: { _ in throw VoteClientError.notImplemented },
            fetchConfirmedPlaceResult: { _ in throw VoteClientError.notImplemented },
            startDateVote: { _, _, _ in throw VoteClientError.notImplemented },
            submitDateVote: { _, _ in throw VoteClientError.notImplemented },
            confirmDateVote: { _, _ in throw VoteClientError.notImplemented },
            startPlaceVote: { _, _ in throw VoteClientError.notImplemented },
            submitPlaceVote: { _, _ in throw VoteClientError.notImplemented },
            fetchPlaceVoteTravelBurden: { _, _ in throw VoteClientError.notImplemented },
            fetchPlaceVoteParticipants: { _ in throw VoteClientError.notImplemented }
        )
    }

    public static let testValue: VoteClient = VoteClient()

    public static let previewValue: VoteClient = VoteClient(
        fetchDateVote: { _ in previewDateVote },
        fetchPlaceVote: { _ in previewPlaceVote },
        fetchConfirmedPlaceResult: { _ in previewConfirmedPlaceResult },
        startDateVote: { _, _, _ in },
        submitDateVote: { _, _ in },
        confirmDateVote: { _, _ in },
        startPlaceVote: { _, _ in },
        submitPlaceVote: { _, _ in },
        fetchPlaceVoteTravelBurden: { _, _ in previewPlaceVoteTravelBurden },
        fetchPlaceVoteParticipants: { _ in previewPlaceVoteParticipants }
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
        memberStatuses: [
            PlaceVoteMemberStatus(id: 1, name: "지혜", completed: true),
            PlaceVoteMemberStatus(id: 2, name: "민수", completed: true),
            PlaceVoteMemberStatus(id: 3, name: "수진", completed: false)
        ],
        candidates: [
            PlaceVoteCandidate(
                id: 1,
                name: "감성카페",
                categoryLabel: .cafe,
                address: "서울 강남구 테헤란로 1",
                latitude: 37.4979,
                longitude: 127.0276,
                voteCount: 2,
                isMyVote: true
            ),
            PlaceVoteCandidate(
                id: 2,
                name: "강남역 맛집",
                categoryLabel: .unknown("음식점"),
                address: "서울 강남구 강남대로 396",
                latitude: 37.4980,
                longitude: 127.0276,
                voteCount: 1,
                isMyVote: false
            ),
            PlaceVoteCandidate(
                id: 3,
                name: "역삼 브런치",
                categoryLabel: .cafe,
                address: "서울 강남구 역삼로 120",
                latitude: 37.5006,
                longitude: 127.0364,
                voteCount: 0,
                isMyVote: false
            )
        ]
    )

    /// 프리뷰/디자인 확인용 샘플 확정 장소 결과.
    static let previewConfirmedPlaceResult: ConfirmedPlaceResult = ConfirmedPlaceResult(
        placeId: 1,
        placeName: "감성카페",
        address: "서울 강남구 테헤란로 1",
        latitude: 37.5012,
        longitude: 127.0396,
        confirmedAt: "2026-06-25T15:00:00.000Z",
        candidates: [
            ConfirmedPlaceCandidate(
                placeId: 1,
                voteCount: 2,
                totalSeconds: 5400,
                totalTransfers: 3
            )
        ]
    )

    /// 프리뷰/디자인 확인용 샘플 멤버별 경로 부담.
    static let previewPlaceVoteTravelBurden: PlaceVoteTravelBurden = PlaceVoteTravelBurden(
        place: TravelBurdenPlace(
            placeId: 1,
            name: "감성카페",
            categoryLabel: .cafe,
            address: "서울 강남구 테헤란로 1",
            latitude: 37.4979,
            longitude: 127.0276
        ),
        burdens: [
            MemberTravelBurden(
                memberId: 1,
                name: "지혜",
                departureName: "왕십리역",
                isMe: true,
                seconds: 2400,
                transfers: 1,
                isLongest: false,
                path: [
                    TravelPathPoint(stationId: 1, latitude: 37.5614, longitude: 127.0379),
                    TravelPathPoint(stationId: 2, latitude: 37.5345, longitude: 127.0946),
                    TravelPathPoint(stationId: 3, latitude: 37.4979, longitude: 127.0276)
                ]
            ),
            MemberTravelBurden(
                memberId: 2,
                name: "민수",
                departureName: "홍대입구역",
                isMe: false,
                seconds: 3600,
                transfers: 2,
                isLongest: true,
                path: [
                    TravelPathPoint(stationId: 4, latitude: 37.5572, longitude: 126.9245),
                    TravelPathPoint(stationId: 5, latitude: 37.5045, longitude: 126.9560),
                    TravelPathPoint(stationId: 3, latitude: 37.4979, longitude: 127.0276)
                ]
            )
        ]
    )

    /// 프리뷰/디자인 확인용 샘플 장소 투표 참여 멤버.
    static let previewPlaceVoteParticipants: [PlaceVoteParticipant] = [
        PlaceVoteParticipant(
            memberId: 1,
            name: "지혜",
            profileImageUrl: nil,
            departureName: "왕십리역",
            isMe: true,
            voted: true
        ),
        PlaceVoteParticipant(
            memberId: 2,
            name: "민수",
            profileImageUrl: nil,
            departureName: "홍대입구역",
            isMe: false,
            voted: true
        ),
        PlaceVoteParticipant(
            memberId: 3,
            name: "수진",
            profileImageUrl: nil,
            departureName: nil,
            isMe: false,
            voted: false
        )
    ]
}

public extension DependencyValues {
    var voteClient: VoteClient {
        get { self[VoteClient.self] }
        set { self[VoteClient.self] = newValue }
    }
}
