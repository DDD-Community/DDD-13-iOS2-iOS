//
//  HomeTabFeature.swift
//  Presentation
//

import ComposableArchitecture

import CoreDependencies
import Entity

@Reducer
public struct HomeTabFeature {
    /// 모임 진행 단계에 따른 상단 영역 종류. `HomeTopArea`의 뷰 분기와 투표 현황 조회가 동일 기준을 공유한다.
    public enum HomeTopAreaKind: Equatable, Sendable {
        case dateVote        // (.inProgress, .before)
        case confirmedDate   // (.completed, .before) or (.completed, .recommended)
        case locationVote    // (.completed, .voting)
        case confirmedPlace  // (.completed, .confirmed)
        case `default`
    }

    @Dependency(\.groupClient) private var groupClient
    @Dependency(\.voteClient) private var voteClient
    @Dependency(\.placeRecommendationClient) private var placeRecommendationClient

    @ObservableState
    public struct State: Equatable {
        public var group: Group
        /// `onAppear`에서 `fetchGroupDetail`로 로드하는 모임 상세. 멤버 리스트의 출발지/본인 여부/참여 상태를 제공한다.
        public var groupDetail: GroupDetail?
        /// 날짜 투표 중(`inProgress`/`before`)일 때 `fetchDateVote`로 로드하는 날짜 투표 현황.
        public var dateVote: DateVote?
        /// 장소 투표 중(`completed`/`voting`)일 때 `fetchPlaceVote`로 로드하는 장소 투표 현황.
        public var placeVote: PlaceVote?
        /// 장소 확정 후(`completed`/`confirmed`)일 때 `fetchConfirmedPlaceResult`로 로드하는 확정 장소 결과.
        public var confirmedPlaceResult: ConfirmedPlaceResult?

        public init(group: Group) {
            self.group = group
        }

        public var hasMembers: Bool {
            !group.members.isEmpty
        }

        /// 날짜 후보에 표를 던진 고유 참여자 수.
        public var dateVoteParticipantCount: Int {
            guard let options = dateVote?.options else { return 0 }

            return Set(options.flatMap { $0.voters.map(\.id) }).count
        }

        /// 전체 멤버 수 대비 날짜 투표 참여 비율(0...1).
        public var dateVoteParticipationRatio: Double {
            let total = groupDetail?.members.count ?? 0
            guard total > 0 else { return 0 }

            return Double(dateVoteParticipantCount) / Double(total)
        }

        /// 현재 사용자가 모임 호스트인지 여부.
        public var isMeHost: Bool {
            groupDetail?.members.first(where: { $0.isMe })?.isHost ?? false
        }

        /// 서버 `isMyVote` 기준, 내가 투표한 날짜 후보 옵션 id 집합.
        public var myVotedDateOptionIds: Set<Int> {
            guard let options = dateVote?.options else { return [] }

            return Set(options.filter(\.isMyVote).map(\.id))
        }

        /// 서버 `isMyVote` 기준, 내가 날짜 후보 중 하나라도 투표했는지 여부.
        public var hasVotedDate: Bool {
            dateVote?.options.contains(where: \.isMyVote) ?? false
        }

        /// 서버 `isMyVote` 기준, 내가 투표한 장소 후보 id 집합.
        public var myVotedPlaceIds: Set<Int> {
            guard let candidates = placeVote?.candidates else { return [] }

            return Set(candidates.filter(\.isMyVote).map(\.id))
        }

        /// 장소 투표 진행 중이고, 내가 장소 후보 중 하나라도 투표했는지 여부.
        public var hasVotedPlace: Bool {
            let locationStatus = groupDetail?.locationStatus ?? group.locationStatus
            return locationStatus == .voting && !myVotedPlaceIds.isEmpty
        }

        /// 모임 진행 단계(`dateVoteStatus` × `locationStatus`)에 따른 상단 영역 종류.
        /// 투표 확정 등으로 상태가 갱신되면 `groupDetail`을 우선 반영하고, 로드 전에는 `group`으로 폴백한다.
        public var homeTopAreaKind: HomeTopAreaKind {
            let dateVoteStatus = groupDetail?.dateVoteStatus ?? group.dateVoteStatus
            let locationStatus = groupDetail?.locationStatus ?? group.locationStatus

            switch (dateVoteStatus, locationStatus) {
            case (.inProgress, .before): return .dateVote
            case (.completed, .before), (.completed, .recommended): return .confirmedDate
            case (.completed, .voting): return .locationVote
            case (.completed, .confirmed): return .confirmedPlace
            default: return .default
            }
        }

        @Presents public var destination: Destination.State?
    }

    public enum Action {
        case onAppear
        case groupDetailResponse(Result<GroupDetail, Error>)
        case dateVoteResponse(Result<DateVote, Error>)
        case placeVoteResponse(Result<PlaceVote, Error>)
        case confirmedPlaceResultResponse(Result<ConfirmedPlaceResult, Error>)
        case myAttendanceBadgeTapped
        case decidePlaceTapped
        case inviteFriendTapped
        case dateVoteTapped
        case dateVoteSubmitTapped(optionIds: [Int])
        case dateVoteSubmitResponse(Result<Void, Error>)
        case dateVoteConfirmTapped
        case dateVoteConfirmResponse(Result<Void, Error>)
        case selectPlaceTapped
        case placeRecommendationStartResponse(Result<Void, Error>)
        case placeVoteSubmitTapped(placeIds: [Int])
        case placeVoteSubmitResponse(Result<Void, Error>)
        case placeDetailTapped
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
    }

    public enum Delegate: Equatable {
        case selectMyPlaceTab
        case meetingDateSelectionRequested(meetingId: Int)
        /// 장소 추천 시작 성공 → 장소 투표 후보 담기 화면으로 진입.
        case startSelectPlace(isHost: Bool)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    fetchGroupDetailEffect(meetingId: state.group.meetingId),
                    fetchVoteEffect(meetingId: state.group.meetingId, kind: state.homeTopAreaKind)
                )

            case let .groupDetailResponse(.success(detail)):
                state.groupDetail = detail
                return .none

            case .groupDetailResponse(.failure):
                return .none

            case let .dateVoteResponse(.success(dateVote)):
                state.dateVote = dateVote
                return .none

            case .dateVoteResponse(.failure):
                return .none

            case let .placeVoteResponse(.success(placeVote)):
                state.placeVote = placeVote
                return .none

            case .placeVoteResponse(.failure):
                return .none

            case let .confirmedPlaceResultResponse(.success(result)):
                state.confirmedPlaceResult = result
                return .none

            case .confirmedPlaceResultResponse(.failure):
                return .none

            // TODO: 나 영역 참여 상태 변경 시트/플로우 연동
            case .myAttendanceBadgeTapped:
                return .none

            case .decidePlaceTapped:
                guard state.homeTopAreaKind == .default, state.isMeHost else { return .none }
                return .send(.delegate(.meetingDateSelectionRequested(meetingId: state.group.meetingId)))

            case .inviteFriendTapped:
                return .none

            case .dateVoteTapped:
                state.destination = .dateVote(DateVoteFeature.State())
                return .none

            case let .dateVoteSubmitTapped(optionIds):
                let client = voteClient
                let meetingId = state.group.meetingId
                return .run { send in
                    await send(.dateVoteSubmitResponse(
                        Result { try await client.submitDateVote(meetingId: meetingId, optionIds: optionIds) }
                    ))
                }

            // 투표 참여 성공 시 dateVote만 재조회한다. isMyVote/득표수가 갱신되어 View의 hasVoted가 동기화된다.
            case .dateVoteSubmitResponse(.success):
                return fetchDateVoteEffect(meetingId: state.group.meetingId)

            case .dateVoteSubmitResponse(.failure):
                return .none

            case .dateVoteConfirmTapped:
                guard
                    let options = state.dateVote?.options,
                    let maxCount = options.map(\.voteCount).max(),
                    let winnerId = options.first(where: { $0.voteCount == maxCount })?.id
                else { return .none }

                let client = voteClient
                let meetingId = state.group.meetingId
                return .run { send in
                    await send(.dateVoteConfirmResponse(
                        Result { try await client.confirmDateVote(meetingId: meetingId, optionId: winnerId) }
                    ))
                }

            // 확정 성공 시 groupDetail을 재조회해 상단 영역을 confirmedDate로 전환한다.
            case .dateVoteConfirmResponse(.success):
                return fetchGroupDetailEffect(meetingId: state.group.meetingId)

            case .dateVoteConfirmResponse(.failure):
                return .none

            case .selectPlaceTapped:
                guard state.homeTopAreaKind == .confirmedDate else { return .none }

                let client = placeRecommendationClient
                let meetingId = state.group.meetingId
                return .run { send in
                    await send(.placeRecommendationStartResponse(
                        Result {
                            try await client.startPlaceRecommendation(
                                meetingId: meetingId,
                                radiusKm: Constant.placeRecommendationRadiusKm
                            )
                        }
                    ))
                }

            case .placeRecommendationStartResponse(.success):
                let isHost = state.isMeHost
                return .send(.delegate(.startSelectPlace(isHost: isHost)))

            case .placeRecommendationStartResponse(.failure):
                return .none

            case let .placeVoteSubmitTapped(placeIds):
                let client = voteClient
                let meetingId = state.group.meetingId
                return .run { send in
                    await send(.placeVoteSubmitResponse(
                        Result { try await client.submitPlaceVote(meetingId: meetingId, placeIds: placeIds) }
                    ))
                }

            case .placeVoteSubmitResponse(.success):
                return fetchPlaceVoteEffect(meetingId: state.group.meetingId)

            case .placeVoteSubmitResponse(.failure):
                return .none

            case .placeDetailTapped:
                return .none

            case .delegate, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    private func fetchGroupDetailEffect(meetingId: Int) -> Effect<Action> {
        let client = groupClient
        return .run { send in
            await send(.groupDetailResponse(
                Result { try await client.fetchGroupDetail(meetingId: meetingId) }
            ))
        }
    }

    /// 상단 영역 종류에 따라 날짜/장소 투표 현황을 조회한다.
    /// `HomeTopArea`가 `DateVoteTopPage`/`LocationVoteArea`를 노출하는 케이스에서만 호출된다.
    private func fetchVoteEffect(meetingId: Int, kind: HomeTopAreaKind) -> Effect<Action> {
        switch kind {
        case .dateVote: return fetchDateVoteEffect(meetingId: meetingId)
        case .locationVote: return fetchPlaceVoteEffect(meetingId: meetingId)
        case .confirmedPlace: return fetchConfirmedPlaceResultEffect(meetingId: meetingId)
        default: return .none
        }
    }

    private func fetchDateVoteEffect(meetingId: Int) -> Effect<Action> {
        let client = voteClient
        return .run { send in
            await send(.dateVoteResponse(
                Result { try await client.fetchDateVote(meetingId: meetingId) }
            ))
        }
    }

    private func fetchPlaceVoteEffect(meetingId: Int) -> Effect<Action> {
        let client = voteClient
        return .run { send in
            await send(.placeVoteResponse(
                Result { try await client.fetchPlaceVote(meetingId: meetingId) }
            ))
        }
    }

    private func fetchConfirmedPlaceResultEffect(meetingId: Int) -> Effect<Action> {
        let client = voteClient
        return .run { send in
            await send(.confirmedPlaceResultResponse(
                Result { try await client.fetchConfirmedPlaceResult(meetingId: meetingId) }
            ))
        }
    }
}

// MARK: - Constants

private enum Constant {
    static let placeRecommendationRadiusKm = 1.0
}

// MARK: - Destination

extension HomeTabFeature {
    @Reducer(state: .equatable)
    public enum Destination {
        case dateVote(DateVoteFeature)
    }
}
