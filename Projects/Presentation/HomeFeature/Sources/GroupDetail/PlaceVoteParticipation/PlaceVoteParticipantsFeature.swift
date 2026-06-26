//
//  PlaceVoteParticipantsFeature.swift
//  Presentation
//

import ComposableArchitecture

import CoreDependencies
import Entity

/// 장소 투표 참여 팀원 현황 화면.
/// 진입 시 참여 멤버 목록을 조회하고, 멤버별 투표 완료 여부를 노출한다.
@Reducer
public struct PlaceVoteParticipantsFeature {
    @ObservableState
    public struct State: Equatable {
        public let meetingId: Int
        public var participants: [PlaceVoteParticipant] = []

        public init(meetingId: Int) {
            self.meetingId = meetingId
        }
    }

    public enum Action {
        case task
        case participantsResponse(Result<[PlaceVoteParticipant], Error>)
    }

    @Dependency(\.voteClient) private var voteClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                let client = voteClient
                let meetingId = state.meetingId
                return .run { send in
                    await send(.participantsResponse(Result {
                        try await client.fetchPlaceVoteParticipants(meetingId: meetingId)
                    }))
                }

            case let .participantsResponse(.success(participants)):
                state.participants = participants
                return .none

            case .participantsResponse(.failure):
                return .none
            }
        }
    }
}
