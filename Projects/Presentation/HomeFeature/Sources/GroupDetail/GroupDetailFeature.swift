//
//  GroupDetailFeature.swift
//  Presentation
//

import ComposableArchitecture

import CoreDependencies
import Entity

@Reducer
public struct GroupDetailFeature {
    @Dependency(\.groupClient) private var groupClient

    @ObservableState
    public struct State: Equatable {
        public let group: Group
        /// `onAppear`에서 `fetchGroupDetail`로 로드하는 모임 상세. 멤버 리스트의 출발지/본인 여부/참여 상태를 제공한다.
        public var groupDetail: GroupDetail?
        public var nearbyPlaceList: NearbyPlaceListSheetFeature.State = .init()
        public var selectedTabIndex = 0
        // TODO: 투표 탭 노출 조건이 확정되면 실제 값으로 대체
        public var isVoteTabAvailable = false

        public init(group: Group) {
            self.group = group
        }

        /// 노출 순서대로 구성한 탭 목록. `isVoteTabAvailable` 에 따라 "투표" 탭이 포함된다.
        public var tabs: [GroupDetailTab] {
            isVoteTabAvailable
                ? [.home, .vote, .myPlace]
                : [.home, .myPlace]
        }

        public var selectedTab: GroupDetailTab {
            tabs[min(selectedTabIndex, tabs.count - 1)]
        }

        public var hasMembers: Bool {
            !group.members.isEmpty
        }

        @Presents public var destination: Destination.State?
    }

    public enum Action {
        case onAppear
        case groupDetailResponse(Result<GroupDetail, Error>)
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
                let meetingId = state.group.meetingId
                let client = groupClient
                return .run { send in
                    await send(.groupDetailResponse(
                        Result { try await client.fetchGroupDetail(meetingId: meetingId) }
                    ))
                }

            case let .groupDetailResponse(.success(detail)):
                state.groupDetail = detail
                return .none

            case .groupDetailResponse(.failure):
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
}

// MARK: - Destination

extension GroupDetailFeature {
    @Reducer(state: .equatable)
    public enum Destination {
        case dateVote(DateVoteFeature)
    }
}
