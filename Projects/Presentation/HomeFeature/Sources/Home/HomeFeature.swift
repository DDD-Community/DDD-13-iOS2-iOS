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
        public var selectedFilter: GroupFilter = .all
        @Presents public var creationSheet: GroupCreationSheetFeature.State?
        public var path: StackState<Path.State> = StackState<Path.State>()

        public var filteredGroups: [Group] {
            switch selectedFilter {
            case .all: return groups
            case .inProgress: return groups.filter { $0.listStatus == .inProgress }
            case .confirmed: return groups.filter { $0.listStatus == .confirmed }
            case .ended: return groups.filter { $0.listStatus == .ended }
            }
        }

        public init() {}
    }

    public enum Action {
        case onAppear
        case groupsResponse(Result<[Group], Error>)
        case filterTapped(GroupFilter)
        case createGroupRowTapped
        case fabCreateGroupTapped
        case fabJoinGroupTapped
        case groupCardTapped(Group)
        case creationSheet(PresentationAction<GroupCreationSheetFeature.Action>)
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

            case .filterTapped(let filter):
                state.selectedFilter = filter
                return .none

            case .createGroupRowTapped:
                state.creationSheet = GroupCreationSheetFeature.State()
                return .none

            case .fabCreateGroupTapped:
                state.creationSheet = GroupCreationSheetFeature.State()
                return .none

            case .fabJoinGroupTapped:
                return .none

            case .groupCardTapped(let group):
                state.path.append(.detail(GroupDetailFeature.State(group: group)))
                return .none

            case .creationSheet(.presented(.delegate(.groupCreated))):
                state.creationSheet = nil
                return fetchGroupsEffect()

            case .creationSheet(.presented(.delegate(.dismissed))):
                state.creationSheet = nil
                return .none

            case .creationSheet:
                return .none

            case .path:
                return .none
            }
        }
        .ifLet(\.$creationSheet, action: \.creationSheet) {
            GroupCreationSheetFeature()
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
