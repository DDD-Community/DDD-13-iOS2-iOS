//
//  GroupDetailFeature.swift
//  Presentation
//

import ComposableArchitecture
import Entity

@Reducer
public struct GroupDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public let group: Group
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
    }

    public enum Action {
        case tabSelected(Int)
        case decidePlaceTapped
        case inviteFriendTapped
        case nearbyPlaceList(NearbyPlaceListSheetFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList) {
            NearbyPlaceListSheetFeature()
        }

        Reduce { state, action in
            switch action {
            case let .tabSelected(index):
                state.selectedTabIndex = index
                return .none

            case .decidePlaceTapped:
                return .none

            case .inviteFriendTapped:
                return .none

            case .nearbyPlaceList:
                return .none
            }
        }
    }
}
