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
    @Dependency(\.withRandomNumberGenerator) private var withRandomNumberGenerator

    @Reducer(state: .equatable)
    public enum Path {
        case detail(GroupDetailFeature)
        case dateSelection(MeetingDateSelectionFeature)
        case datePicker(MeetingDatePickerFeature)
    }

    public enum InviteCardDesign: Equatable, CaseIterable, Sendable {
        case design1
        case design2
    }

    @ObservableState
    public struct State: Equatable {
        public var groups: [Group] = []
        public var selectedTabIndex: Int = 0
        public var hasUnreadNotifications: Bool = false
        public var inviteCardDesign: InviteCardDesign = .design1
        public var isInviteCardDismissed: Bool = false
        @Presents public var creationView: GroupCreationFeature.State?
        public var path: StackState<Path.State> = StackState<Path.State>()

        // 모임이 1~2개이고 아직 닫지 않았을 때만 친구 초대 카드를 노출한다
        public var isInviteCardVisible: Bool {
            (1...2).contains(groups.count) && !isInviteCardDismissed
        }

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
        case inviteCardCloseButtonTapped
        case inviteButtonTapped
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
                if (1...2).contains(groups.count) {
                    state.inviteCardDesign = withRandomNumberGenerator {
                        Bool.random(using: &$0) ? .design1 : .design2
                    }
                }
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

            case .inviteCardCloseButtonTapped:
                state.isInviteCardDismissed = true
                return .none

            case .inviteButtonTapped:
                // TODO: 친구 초대/링크 공유 플로우 연결
                return .none

            case let .creationView(.presented(.delegate(.groupCreated(group)))):
                state.creationView = nil
                state.path.append(.detail(GroupDetailFeature.State(group: group)))
                return fetchGroupsEffect()

            case .creationView(.presented(.delegate(.dismissed))):
                state.creationView = nil
                return .none

            case .creationView:
                return .none

            case let .path(.element(id: _, action: .detail(.delegate(.meetingDateSelectionRequested(meetingId))))):
                state.path.append(.dateSelection(MeetingDateSelectionFeature.State(meetingId: meetingId)))
                return .none

            case let .path(.element(id: _, action: .dateSelection(.delegate(.datePickerRequested(mode, meetingId))))):
                state.path.append(.datePicker(MeetingDatePickerFeature.State(meetingId: meetingId, mode: mode)))
                return .none

            case let .path(.element(id: _, action: .dateSelection(.delegate(.dateSelectionCompleted(meetingId))))):
                updateDateVoteStatus(state: &state, meetingId: meetingId)
                state.path.removeLast()
                return .none

            case let .path(.element(id: _, action: .datePicker(.delegate(.selectionCompleted(mode, text, requestDate))))):
                updateDateSelectionText(state: &state, mode: mode, text: text, requestDate: requestDate)
                state.path.removeLast()
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

    private func updateDateSelectionText(
        state: inout State,
        mode: MeetingDatePickerMode,
        text: String,
        requestDate: String?
    ) {
        guard let dateSelectionID = state.path.ids.last(where: { id in
            if case .dateSelection = state.path[id: id] { return true }
            return false
        }) else {
            return
        }

        guard case var .dateSelection(dateSelectionState) = state.path[id: dateSelectionID] else {
            return
        }

        switch mode {
        case .single:
            dateSelectionState.dateDesignation.selectedDateText = text
            dateSelectionState.dateDesignation.selectedDateRequestText = requestDate

        case .range:
            dateSelectionState.periodVote.selectedDateText = text
        }

        state.path[id: dateSelectionID] = .dateSelection(dateSelectionState)
    }

    private func updateDateVoteStatus(state: inout State, meetingId: Int64) {
        state.groups = state.groups.map { group in
            guard group.meetingId == meetingId else { return group }
            return group.updating(dateVoteStatus: .completed)
        }

        guard let detailID = state.path.ids.last(where: { id in
            if case .detail = state.path[id: id] { return true }
            return false
        }) else {
            return
        }

        guard case var .detail(detailState) = state.path[id: detailID] else {
            return
        }

        guard detailState.group.meetingId == meetingId else { return }
        detailState.group = detailState.group.updating(dateVoteStatus: .completed)
        state.path[id: detailID] = .detail(detailState)
    }
}

private extension Group {
    func updating(dateVoteStatus: GroupDateVoteStatus) -> Group {
        Group(
            id: id,
            meetingId: meetingId,
            name: name,
            themeTagCode: themeTagCode,
            themeTagDisplay: themeTagDisplay,
            listStatus: listStatus,
            locationStatus: locationStatus,
            dateVoteStatus: dateVoteStatus,
            locationAddress: locationAddress,
            memberCount: memberCount,
            members: members
        )
    }
}
