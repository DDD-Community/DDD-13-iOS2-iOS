//
//  GroupDetailFeature.swift
//  Presentation
//

import ComposableArchitecture

import CoreDependencies
import Entity

@Reducer
public struct GroupDetailFeature {
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

    @ObservableState
    public struct State: Equatable {
        public let group: Group
        /// `onAppear`에서 `fetchGroupDetail`로 로드하는 모임 상세. 멤버 리스트의 출발지/본인 여부/참여 상태를 제공한다.
        public var groupDetail: GroupDetail?
        /// 날짜 투표 중(`inProgress`/`before`)일 때 `fetchDateVote`로 로드하는 날짜 투표 현황.
        public var dateVote: DateVote?
        /// 장소 투표 중(`completed`/`voting`)일 때 `fetchPlaceVote`로 로드하는 장소 투표 현황.
        public var placeVote: PlaceVote?
        public var nearbyPlaceList: NearbyPlaceListSheetFeature.State = .init()
        public var selectedTabIndex = 0

        public init(group: Group) {
            self.group = group
        }

        public var selectedTab: GroupDetailTab {
            let tabs = GroupDetailTab.allCases
            return tabs[min(selectedTabIndex, tabs.count - 1)]
        }

        public var hasMembers: Bool {
            !group.members.isEmpty
        }

        /// 모임 진행 단계(`dateVoteStatus` × `locationStatus`)에 따른 상단 영역 종류.
        public var homeTopAreaKind: HomeTopAreaKind {
            switch (group.dateVoteStatus, group.locationStatus) {
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
        case myAttendanceBadgeTapped
        case tabSelected(Int)
        case decidePlaceTapped
        case inviteFriendTapped
        case dateVoteTapped
        case selectPlaceTapped
        case voteForLocationTapped
        case placeDetailTapped
        case nearbyPlaceList(NearbyPlaceListSheetFeature.Action)
        case destination(PresentationAction<Destination.Action>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList) {
            NearbyPlaceListSheetFeature()
        }

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

            // TODO: 나 영역 참여 상태 변경 시트/플로우 연동
            case .myAttendanceBadgeTapped:
                return .none

            case let .tabSelected(index):
                state.selectedTabIndex = index
                return .none

            case .decidePlaceTapped:
                return .none

            case .inviteFriendTapped:
                return .none

            case .dateVoteTapped:
                state.destination = .dateVote(DateVoteFeature.State())
                return .none

            // TODO: 케이스 2~4 버튼 네비게이션 연동 시 구현
            case .selectPlaceTapped:
                return .none

            case .voteForLocationTapped:
                return .none

            case .placeDetailTapped:
                return .none

            case .nearbyPlaceList:
                return .none

            case .destination:
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
        let client = voteClient

        switch kind {
        case .dateVote:
            return .run { send in
                await send(.dateVoteResponse(
                    Result { try await client.fetchDateVote(meetingId: meetingId) }
                ))
            }

        case .locationVote:
            return .run { send in
                await send(.placeVoteResponse(
                    Result { try await client.fetchPlaceVote(meetingId: meetingId) }
                ))
            }

        default:
            return .none
        }
    }
}

// MARK: - Destination

extension GroupDetailFeature {
    @Reducer(state: .equatable)
    public enum Destination {
        case dateVote(DateVoteFeature)
    }
}
