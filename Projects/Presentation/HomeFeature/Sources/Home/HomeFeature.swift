//
//  HomeFeature.swift
//  Presentation
//

import Foundation

import ComposableArchitecture
import CoreDependencies
import Entity
import StationSearchFeature
import Utill

@Reducer
public struct HomeFeature {
    @Dependency(\.groupClient) private var groupClient
    @Dependency(\.departurePlaceClient) private var departurePlaceClient
    @Dependency(\.withRandomNumberGenerator) private var withRandomNumberGenerator

    @Reducer(state: .equatable)
    public enum Path {
        case detail(GroupDetailFeature)
        case dateSelection(MeetingDateSelectionFeature)
        case stationSearch(StationSearchSheetFeature)
        case pickPlace(PickPlaceFeature)
    }

    public enum InviteCardDesign: Equatable, CaseIterable, Sendable {
        case design1
        case design2
    }

    enum DeparturePlaceSearchPurpose: Equatable {
        case add
        case edit(id: Int)
    }

    @ObservableState
    public struct State: Equatable {
        public var groups: [Group] = []
        public var selectedTabIndex: Int = 0
        public var hasUnreadNotifications: Bool = false
        public var inviteCardDesign: InviteCardDesign = .design1
        public var isInviteCardDismissed: Bool = false
        var departurePlaceSearchPurpose: DeparturePlaceSearchPurpose?
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
        case addDeparturePlaceResponse(Result<DeparturePlace, Error>)
        case updateDeparturePlaceResponse(Result<DeparturePlace, Error>)
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

            case .addDeparturePlaceResponse(.success):
                Log.debug("출발지 추가 성공")
                return finishDeparturePlaceSearch(state: &state)

            case let .addDeparturePlaceResponse(.failure(error)):
                Log.debug("출발지 추가 실패: \(error)")
                return .none

            case .updateDeparturePlaceResponse(.success):
                Log.debug("출발지 수정 성공")
                return finishDeparturePlaceSearch(state: &state)

            case let .updateDeparturePlaceResponse(.failure(error)):
                Log.debug("출발지 수정 실패: \(error)")
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

            case .path(.element(id: _, action: .detail(.delegate(.departurePlaceStationSearchRequested)))):
                state.departurePlaceSearchPurpose = .add
                state.path.append(.stationSearch(StationSearchSheetFeature.State()))
                return .none

            case let .path(.element(id: _, action: .detail(.delegate(.departurePlaceEditStationSearchRequested(id))))):
                state.departurePlaceSearchPurpose = .edit(id: id)
                state.path.append(.stationSearch(StationSearchSheetFeature.State()))
                return .none

            case let .path(.element(id: _, action: .stationSearch(.delegate(.stationSelected(station))))):
                Log.debug("출발지 역 선택: \(station.name)")
                let client = departurePlaceClient
                switch state.departurePlaceSearchPurpose {
                case .add:
                    return .run { send in
                        await send(.addDeparturePlaceResponse(
                            Result {
                                try await client.addDeparturePlace(
                                    station.name,
                                    station.addressName,
                                    station.roadAddressName,
                                    station.name,
                                    station.y,
                                    station.x,
                                    true
                                )
                            }
                        ))
                    }

                case let .edit(id):
                    return .run { send in
                        await send(.updateDeparturePlaceResponse(
                            Result {
                                try await client.updateDeparturePlace(
                                    id,
                                    station.name,
                                    station.addressName,
                                    station.roadAddressName,
                                    station.name,
                                    station.y,
                                    station.x
                                )
                            }
                        ))
                    }

                case nil:
                    return .none
                }

            case .path(.element(id: _, action: .stationSearch(.delegate(.dismissed)))):
                state.departurePlaceSearchPurpose = nil
                state.path.removeLast()
                return .none

            case let .path(.element(id: _, action: .dateSelection(.delegate(.dateSelectionCompleted(
                meetingId,
                dateVoteStatus
            ))))):
                let detailID = updateDateVoteStatus(state: &state, meetingId: meetingId, dateVoteStatus: dateVoteStatus)
                state.path.removeLast()

                guard let detailID else { return .none }
                return .send(.path(.element(id: detailID, action: .detail(.home(.onAppear)))))

            case let .path(.element(id: _, action: .detail(.delegate(.startPickPlace(isHost, meetingId))))):
                state.path.append(.pickPlace(PickPlaceFeature.State(isHost: isHost, meetingId: meetingId)))
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

    private func finishDeparturePlaceSearch(state: inout State) -> Effect<Action> {
        state.departurePlaceSearchPurpose = nil
        state.path.removeLast()

        guard let detailID = state.currentDetailID else { return .none }
        return .send(.path(.element(id: detailID, action: .detail(.home(.onAppear)))))
    }

    private func updateDateVoteStatus(
        state: inout State,
        meetingId: Int,
        dateVoteStatus: GroupDateVoteStatus
    ) -> StackElementID? {
        state.groups = state.groups.map { group in
            guard group.meetingId == meetingId else { return group }
            return group.updating(dateVoteStatus: dateVoteStatus)
        }

        guard let detailID = state.path.ids.last(where: { id in
            if case .detail = state.path[id: id] { return true }
            return false
        }) else {
            return nil
        }

        guard case var .detail(detailState) = state.path[id: detailID] else {
            return nil
        }

        guard detailState.home.group.meetingId == meetingId else { return nil }
        detailState.home.groupDetail = detailState.home.groupDetail?.updating(dateVoteStatus: dateVoteStatus)
        state.path[id: detailID] = .detail(detailState)
        return detailID
    }
}

private extension HomeFeature.State {
    var currentDetailID: StackElementID? {
        path.ids.last { id in
            if case .detail = path[id: id] { return true }
            return false
        }
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
private extension GroupDetail {
    func updating(dateVoteStatus: GroupDateVoteStatus) -> GroupDetail {
        GroupDetail(
            id: id,
            name: name,
            themeTagCode: themeTagCode,
            themeTagDisplay: themeTagDisplay,
            locationStatus: locationStatus,
            dateVoteStatus: dateVoteStatus,
            confirmedDate: confirmedDate,
            members: members
        )
    }
}
