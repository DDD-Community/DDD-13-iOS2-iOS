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
        /// 멤버 핀 avatar 매칭에 사용할 모임 멤버 목록.
        public let members: [GroupDetailMember]
        public var mode: Mode
        /// voting 모드에서 선택한 후보 id 집합. 복수 선택을 허용한다.
        public var selectedPlaceIds: Set<Int> = []
        /// 투표 제출 진행 여부.
        public var isSubmitting = false
        /// row 탭으로 경로를 조회 중인 후보 id.
        public var focusedPlaceId: Int?
        /// 포커싱한 후보 장소 기준 멤버별 경로 부담.
        public var travelBurden: PlaceVoteTravelBurden?
        /// 투표 참여 팀원 현황 화면.
        @Presents public var participants: PlaceVoteParticipantsFeature.State?

        public init(meetingId: Int, placeVote: PlaceVote, members: [GroupDetailMember]) {
            self.meetingId = meetingId
            self.placeVote = placeVote
            self.members = members

            let myVotes = placeVote.candidates.filter(\.isMyVote)
            self.mode = myVotes.isEmpty ? .voting : .voted
            self.selectedPlaceIds = Set(myVotes.map(\.id))
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
        case placeRowTapped(Int)
        case travelBurdenResponse(Result<PlaceVoteTravelBurden, Error>)
        case voteButtonTapped
        case voteSubmitted(Result<Void, Error>)
        case placeVoteRefreshed(PlaceVote)
        case revoteButtonTapped
        case completeButtonTapped
        case participantsButtonTapped
        case participants(PresentationAction<PlaceVoteParticipantsFeature.Action>)
    }

    @Dependency(\.voteClient) private var voteClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .placeSelected(placeId):
                guard state.mode == .voting else { return .none }

                if state.selectedPlaceIds.contains(placeId) {
                    state.selectedPlaceIds.remove(placeId)
                } else {
                    state.selectedPlaceIds.insert(placeId)
                }
                return .none

            case let .placeRowTapped(placeId):
                state.focusedPlaceId = placeId
                let client = voteClient
                let meetingId = state.meetingId
                return .run { send in
                    await send(.travelBurdenResponse(Result {
                        try await client.fetchPlaceVoteTravelBurden(meetingId: meetingId, placeId: placeId)
                    }))
                }

            case let .travelBurdenResponse(.success(travelBurden)):
                state.travelBurden = travelBurden
                return .none

            case .travelBurdenResponse(.failure):
                return .none

            case .voteButtonTapped:
                guard
                    state.mode == .voting,
                    !state.selectedPlaceIds.isEmpty,
                    !state.isSubmitting
                else { return .none }

                state.isSubmitting = true
                let client = voteClient
                let meetingId = state.meetingId
                let placeIds = Array(state.selectedPlaceIds)
                return .run { send in
                    await send(.voteSubmitted(Result {
                        try await client.submitPlaceVote(meetingId: meetingId, placeIds: placeIds)
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
                state.participants = PlaceVoteParticipantsFeature.State(meetingId: state.meetingId)
                return .none

            case .participants:
                return .none
            }
        }
        .ifLet(\.$participants, action: \.participants) {
            PlaceVoteParticipantsFeature()
        }
    }
}
