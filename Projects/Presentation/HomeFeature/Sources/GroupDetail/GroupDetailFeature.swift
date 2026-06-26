//
//  GroupDetailFeature.swift
//  Presentation
//

import ComposableArchitecture

import Entity
import Utill

@Reducer
public struct GroupDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedTabIndex = 0
        public var home: HomeTabFeature.State
        public var myPlace = MyPlaceTabFeature.State()

        public init(group: Group) {
            self.home = HomeTabFeature.State(group: group)
        }

        public var tabs: [GroupDetailTab] {
            [
                .home,
                .myPlace(isPlaceVoting: home.homeTopAreaKind == .locationVote)
            ]
        }

        public var selectedTab: GroupDetailTab {
            tabs[max(0, min(selectedTabIndex, tabs.count - 1))]
        }
    }

    public enum Action {
        case tabSelected(Int)
        case home(HomeTabFeature.Action)
        case myPlace(MyPlaceTabFeature.Action)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case meetingDateSelectionRequested(meetingId: Int)
            case departurePlaceStationSearchRequested
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeTabFeature()
        }

        Scope(state: \.myPlace, action: \.myPlace) {
            MyPlaceTabFeature()
        }

        Reduce { state, action in
            switch action {
            case let .tabSelected(index):
                state.selectedTabIndex = index
                return .none

            case .home(.delegate(.selectMyPlaceTab)):
                state.selectedTabIndex = 1
                return .none

            case let .home(.delegate(.meetingDateSelectionRequested(meetingId))):
                Log.debug("약속정하기 클릭")
                return .send(.delegate(.meetingDateSelectionRequested(meetingId: meetingId)))

            case .home(.delegate(.departurePlaceStationSearchRequested)):
                return .send(.delegate(.departurePlaceStationSearchRequested))

            case .home, .myPlace:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
