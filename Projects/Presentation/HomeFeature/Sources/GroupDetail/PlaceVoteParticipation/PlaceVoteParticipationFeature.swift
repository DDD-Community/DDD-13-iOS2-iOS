//
//  PlaceVoteParticipationFeature.swift
//  Presentation
//

import ComposableArchitecture

import CoreDependencies
import Entity

/// 약속 장소 투표 참여 화면.
/// 투표 중(`voting`)에는 후보를 선택해 제출하고, 투표 후(`voted`)에는 현황을 보여준다.
@Reducer
public struct PlaceVoteParticipationFeature {
    /// 시트 content 의 노출 형태.
    public enum Mode: Equatable {
        /// 후보를 선택해 투표하는 상태.
        case voting
        /// 투표를 마치고 현황을 확인하는 상태.
        case voted
    }

    @ObservableState
    public struct State: Equatable {
        public let meetingId: Int
        public var placeVote: PlaceVote
        /// 투표 참여 현황 화면에 노출할 모임 멤버 목록.
        public let members: [GroupDetailMember]
        public var mode: Mode
        /// voting 모드에서 선택한 후보 id.
        public var selectedPlaceId: Int?
        /// 투표 제출 진행 여부.
        public var isSubmitting = false
        /// 투표 참여 팀원 현황 화면 노출 여부.
        public var isParticipantsPresented = false

        public init(meetingId: Int, placeVote: PlaceVote, members: [GroupDetailMember]) {
            self.meetingId = meetingId
            self.placeVote = placeVote
            self.members = members

            let myVote = placeVote.candidates.first(where: \.isMyVote)
            self.mode = myVote == nil ? .voting : .voted
            self.selectedPlaceId = myVote?.id
        }

        public var candidates: [PlaceVoteCandidate] {
            placeVote.candidates
        }

        public var deadline: String? {
            placeVote.deadline
        }

        public var votedCount: Int {
            placeVote.votedCount
        }

        /// voted 모드에서 최다 득표 후보 id. 후보가 없으면 nil.
        public var topPlaceId: Int? {
            candidates.max(by: { $0.voteCount < $1.voteCount })?.id
        }
    }

    public enum Action {
        case placeSelected(Int)
        case voteButtonTapped
        case voteSubmitted(Result<Void, Error>)
        case placeVoteRefreshed(PlaceVote)
        case revoteButtonTapped
        case completeButtonTapped
        case participantsButtonTapped
        case participantsDismissed
    }

    @Dependency(\.voteClient) private var voteClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .placeSelected(placeId):
                guard state.mode == .voting else { return .none }

                state.selectedPlaceId = placeId
                return .none

            case .voteButtonTapped:
                guard
                    state.mode == .voting,
                    let placeId = state.selectedPlaceId,
                    !state.isSubmitting
                else { return .none }

                state.isSubmitting = true
                let client = voteClient
                let meetingId = state.meetingId
                return .run { send in
                    await send(.voteSubmitted(Result {
                        try await client.submitPlaceVote(meetingId: meetingId, placeIds: [placeId])
                    }))
                }

            case .voteSubmitted(.success):
                let client = voteClient
                let meetingId = state.meetingId
                return .run { send in
                    let placeVote = try await client.fetchPlaceVote(meetingId: meetingId)
                    await send(.placeVoteRefreshed(placeVote))
                }

            case .voteSubmitted(.failure):
                state.isSubmitting = false
                return .none

            case let .placeVoteRefreshed(placeVote):
                state.placeVote = placeVote
                state.isSubmitting = false
                state.mode = .voted
                return .none

            case .revoteButtonTapped:
                state.mode = .voting
                return .none

            case .completeButtonTapped:
                // TODO: 투표 완료 API 를 별도로 호출해야 하는지, 게스트/호스트에 따라 동작이 다른지 확인 필요
                return .none

            case .participantsButtonTapped:
                state.isParticipantsPresented = true
                return .none

            case .participantsDismissed:
                state.isParticipantsPresented = false
                return .none
            }
        }
    }
}
