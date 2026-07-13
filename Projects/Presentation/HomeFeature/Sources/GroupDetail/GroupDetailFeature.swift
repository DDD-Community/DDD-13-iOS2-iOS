//
//  GroupDetailFeature.swift
//  Presentation
//

import UIKit

import ComposableArchitecture

import CoreDependencies
import Entity
import Utill

@Reducer
public struct GroupDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedTabIndex = 0
        public var home: HomeTabFeature.State
        public var myPlace = MyPlaceTabFeature.State()
        public var isInviteSheetPresented = false
        /// 발급받은 초대코드. 최초 발급 후 재사용해 중복 호출을 막는다.
        public var inviteCode: String?
        @Presents public var alert: AlertState<Action.Alert>?

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

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case tabSelected(Int)
        case inviteButtonTapped
        case inviteLinkCopyTapped
        case kakaoShareTapped
        case endGroupTapped
        case leaveGroupTapped
        case groupClosed(Result<Void, Error>)
        case inviteCodeIssued(Result<String, Error>, InviteIntent)
        case alert(PresentationAction<Alert>)
        case home(HomeTabFeature.Action)
        case myPlace(MyPlaceTabFeature.Action)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case meetingDateSelectionRequested(meetingId: Int)
            case departurePlaceStationSearchRequested
            case departurePlaceEditStationSearchRequested(id: Int)
        /// 장소 투표 후보 담기 화면으로 진입.
        case startPickPlace(isHost: Bool, meetingId: Int)
        }

        public enum Alert: Equatable {
            case confirmEndGroup
            case confirmLeaveGroup
        }
    }

    /// 초대코드 발급 후 수행할 동작.
    public enum InviteIntent: Sendable {
        case copyLink
        case kakaoShare
    }

    @Dependency(\.groupClient) private var groupClient
    @Dependency(\.groupInvitationShareClient) private var groupInvitationShareClient
    @Dependency(\.dismiss) private var dismiss

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.home, action: \.home) {
            HomeTabFeature()
        }

        Scope(state: \.myPlace, action: \.myPlace) {
            MyPlaceTabFeature()
        }

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case let .tabSelected(index):
                state.selectedTabIndex = index
                return .none

            case .inviteButtonTapped:
                state.isInviteSheetPresented = true
                return .none

            case .endGroupTapped:
                state.alert = Self.endGroupAlert(groupName: state.home.group.name)
                return .none

            case .leaveGroupTapped:
                state.alert = Self.leaveGroupAlert(groupName: state.home.group.name)
                return .none

            case .alert(.presented(.confirmEndGroup)):
                let groupId = state.home.group.id
                let groupClient = groupClient
                return .run { send in
                    await send(.groupClosed(Result {
                        try await groupClient.closeGroup(groupId)
                    }))
                }

            case .groupClosed(.success):
                return .run { _ in await dismiss() }

            case .groupClosed(.failure):
                state.alert = Self.closeGroupErrorAlert()
                return .none

            case .alert(.presented(.confirmLeaveGroup)):
                return .none

            case .alert:
                return .none

            case .inviteLinkCopyTapped:
                state.isInviteSheetPresented = false
                return handleInvite(state: &state, intent: .copyLink)

            case .kakaoShareTapped:
                state.isInviteSheetPresented = false
                return handleInvite(state: &state, intent: .kakaoShare)

            case let .inviteCodeIssued(.success(inviteCode), intent):
                state.inviteCode = inviteCode
                return runInviteIntent(
                    intent,
                    inviteCode: inviteCode,
                    groupName: state.home.group.name,
                    hostNickname: state.home.myNickname ?? Constant.defaultHostNickname
                )

            case .inviteCodeIssued(.failure, _):
                return .none

            case let .home(.delegate(.meetingDateSelectionRequested(meetingId))):
                Log.debug("약속정하기 클릭")
                return .send(.delegate(.meetingDateSelectionRequested(meetingId: meetingId)))

            case .home(.delegate(.departurePlaceStationSearchRequested)):
                return .send(.delegate(.departurePlaceStationSearchRequested))

            case let .home(.delegate(.departurePlaceEditStationSearchRequested(id))):
                return .send(.delegate(.departurePlaceEditStationSearchRequested(id: id)))

            case let .home(.delegate(.startPickPlace(isHost, meetingId))):
                return .send(.delegate(.startPickPlace(isHost: isHost, meetingId: meetingId)))

            case let .home(.delegate(.selectMyPlaceTab(place))):
                state.selectedTabIndex = Constant.myPlaceTabIndex
                return .send(.myPlace(.placeFocused(place)))

            case .home, .myPlace, .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private static func endGroupAlert(groupName: String) -> AlertState<Action.Alert> {
        AlertState {
            TextState("\(groupName)을 종료하시겠습니까?")
        } actions: {
            ButtonState(action: .confirmEndGroup) {
                TextState("종료할래요")
            }
            ButtonState(role: .cancel) {
                TextState("아니요")
            }
        }
    }

    private static func leaveGroupAlert(groupName: String) -> AlertState<Action.Alert> {
        AlertState {
            TextState("\(groupName)을 나가시겠습니까?")
        } actions: {
            ButtonState(action: .confirmLeaveGroup) {
                TextState("나갈래요")
            }
            ButtonState(role: .cancel) {
                TextState("아니요")
            }
        }
    }

    private static func closeGroupErrorAlert() -> AlertState<Action.Alert> {
        AlertState {
            TextState("그룹 종료에 실패했습니다.")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("확인")
            }
        }
    }

    private func handleInvite(state: inout State, intent: InviteIntent) -> Effect<Action> {
        if let inviteCode = state.inviteCode {
            return runInviteIntent(
                intent,
                inviteCode: inviteCode,
                groupName: state.home.group.name,
                hostNickname: state.home.myNickname ?? Constant.defaultHostNickname
            )
        }

        let groupId = state.home.group.id
        let groupClient = groupClient
        return .run { send in
            do {
                let inviteCode = try await groupClient.issueInviteCode(groupId)
                await send(.inviteCodeIssued(.success(inviteCode), intent))
            } catch {
                await send(.inviteCodeIssued(.failure(error), intent))
            }
        }
    }

    private func runInviteIntent(
        _ intent: InviteIntent,
        inviteCode: String,
        groupName: String,
        hostNickname: String
    ) -> Effect<Action> {
        let inviteLink = Constant.inviteDeepLinkPrefix + inviteCode
        switch intent {
        case .copyLink:
            return copyInviteLink(inviteLink)

        case .kakaoShare:
            return shareInviteViaKakao(
                inviteLink: inviteLink,
                groupName: groupName,
                hostNickname: hostNickname
            )
        }
    }

    private func copyInviteLink(_ inviteLink: String) -> Effect<Action> {
        .run { @MainActor _ in
            UIPasteboard.general.string = inviteLink
        }
    }

    private func shareInviteViaKakao(
        inviteLink: String,
        groupName: String,
        hostNickname: String
    ) -> Effect<Action> {
        let client = groupInvitationShareClient
        let invitation = GroupInvitation(
            inviteLink: inviteLink,
            groupName: groupName,
            hostNickname: hostNickname
        )
        return .run { _ in
            do {
                try await client.share(invitation)
            } catch {
                Log.debug("카카오 초대 메시지 전송 실패: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Constants

private enum Constant {
    /// `tabs == [.home, .myPlace]` 기준 MyPlaceTab 인덱스.
    static let myPlaceTabIndex = 1
    /// 초대코드를 붙여 초대 딥링크를 구성하는 접두사.
    static let inviteDeepLinkPrefix = "https://bangawo.onelink.me/M0TG/tu3uz1yc/"
    /// 본인 닉네임을 아직 로드하지 못했을 때 초대 메시지에 사용할 폴백.
    static let defaultHostNickname = "호스트"
}
