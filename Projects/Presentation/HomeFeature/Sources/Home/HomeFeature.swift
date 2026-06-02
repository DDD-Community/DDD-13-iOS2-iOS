//
//  HomeFeature.swift
//  Presentation
//

import Foundation

import ComposableArchitecture
import CoreDependencies
import Entity

@Reducer
public struct HomeFeature {
    @Dependency(\.groupClient) private var groupClient

    @Reducer(state: .equatable)
    public enum Path {
        case detail(GroupDetailFeature)
    }

    @ObservableState
    public struct State: Equatable {
        public var groups: [Group] = []
        public var selectedTabIndex: Int = 0
        public var hasUnreadNotifications: Bool = false
        @Presents public var creationView: GroupCreationFeature.State?
        public var path: StackState<Path.State> = StackState<Path.State>()

        public init() {}
    }

    public enum Action {
        case onAppear
        case groupsResponse(Result<[Group], Error>)
        case tabSelected(Int)
        case notificationButtonTapped
        case myPageButtonTapped
        case createGroupRowTapped
        case fabCreateGroupTapped
        case fabJoinGroupTapped
        case groupCardTapped(Group)
        case creationView(PresentationAction<GroupCreationFeature.Action>)
        case path(StackActionOf<Path>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return fetchGroupsEffect()

            case .groupsResponse(.success(let groups)):
                state.groups = groups
                return .none

            case .groupsResponse(.failure):
                return .none

            case .tabSelected(let index):
                state.selectedTabIndex = index
                return .none

            case .notificationButtonTapped:
                return .none

            case .myPageButtonTapped:
                return .none

            case .createGroupRowTapped:
                state.creationView = GroupCreationFeature.State()
                return .none

            case .fabCreateGroupTapped:
                state.creationView = GroupCreationFeature.State()
                return .none

            case .fabJoinGroupTapped:
                return .none

            case .groupCardTapped(let group):
                state.path.append(.detail(GroupDetailFeature.State(group: group)))
                return .none

            case .creationView(.presented(.delegate(.groupCreated))):
                state.creationView = nil
                return fetchGroupsEffect()

            case .creationView(.presented(.delegate(.dismissed))):
                state.creationView = nil
                return .none

            case .creationView:
                return .none

            case .path:
                return .none
            }
        }
        .ifLet(\.$creationView, action: \.creationView) {
            GroupCreationFeature()
        }
        .forEach(\.path, action: \.path)
    }

    private func fetchGroupsEffect() -> Effect<Action> {
        let client = groupClient
        return .run { send in
            await send(.groupsResponse(
                Result { try await client.fetchGroups() }
            ))
        }
    }
}
