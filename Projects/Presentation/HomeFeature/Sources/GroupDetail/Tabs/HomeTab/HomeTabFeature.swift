//
//  HomeTabFeature.swift
//  Presentation
//

import ComposableArchitecture

import CoreDependencies
import Entity
import Utill

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
    @Dependency(\.departurePlaceClient) private var departurePlaceClient

    @ObservableState
    public struct State: Equatable {
        public var group: Group
        /// 진입 시 데이터 로드 진행 여부. 첫 프레임부터 `ProgressView`를 노출하기 위해 기본값은 `true`다.
        public var isLoading = true
        /// `onAppear`에서 `fetchGroupDetail`로 로드하는 모임 상세. 멤버 리스트의 출발지/본인 여부/참여 상태를 제공한다.
        public var groupDetail: GroupDetail?
        /// 날짜 투표 중(`inProgress`/`before`)일 때 `fetchDateVote`로 로드하는 날짜 투표 현황.
        public var dateVote: DateVote?
        /// 장소 투표 중(`completed`/`voting`)일 때 `fetchPlaceVote`로 로드하는 장소 투표 현황.
        public var placeVote: PlaceVote?
        /// 장소 확정 후(`completed`/`confirmed`)일 때 `fetchConfirmedPlaceResult`로 로드하는 확정 장소 결과.
        public var confirmedPlaceResult: ConfirmedPlaceResult?
        public var isMyDeparturePlaceEditSheetPresented = false // 출발지 수정 바텀시트 여부
        public var isMyAttendanceStatusSheetPresented = false // 참여 상태 변경 바텀시트 여부

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

        /// 현재 사용자(본인)의 닉네임. groupDetail 로드 전에는 nil.
        public var myNickname: String? {
            groupDetail?.members.first(where: { $0.isMe })?.nickname
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
        case loadCompleted
        case groupDetailResponse(Result<GroupDetail, Error>)
        case dateVoteResponse(Result<DateVote, Error>)
        case placeVoteResponse(Result<PlaceVote, Error>)
        case confirmedPlaceResultResponse(Result<ConfirmedPlaceResult, Error>)
        case myAttendanceBadgeTapped
        case myAttendanceStatusSheetDismissed
        case myAttendanceStatusSelected(AttendanceStatus)
        case myAttendanceStatusUpdateResponse(Result<AttendanceStatus, Error>)
        case myMemberCardTapped // 나 카드 영역 터치 시(참석여부 버튼 제외)
        case myDeparturePlaceEditSheetDismissed // 출발지 수정 닫혔을 때 액션
        case decidePlaceTapped
        case inviteFriendTapped
        case dateVoteTapped
        case dateVoteSubmitTapped(optionIds: [Int])
        case dateVoteSubmitResponse(Result<Void, Error>)
        case dateVoteConfirmTapped
        case dateVoteConfirmResponse(Result<Void, Error>)
        case pickPlaceTapped
        case placeRecommendationStartResponse(Result<Void, Error>)
        case placeVoteSubmitTapped(placeIds: [Int])
        case placeVoteSubmitResponse(Result<Void, Error>)
        case placeVoteParticipationTapped
        case placeDetailTapped
        case addDeparturePlaceTapped // 바텀시트에서 출발지 추가하기 버튼 클릭 시
        case departurePlaceCardTapped(id: Int) // 출발지 수정 바텀시트에서 출발지 요소 클릭 시(id 전달하기)
        case setDefaultDeparturePlaceResponse(Result<DeparturePlace, Error>)
        case editDeparturePlaceTapped(id: Int)
        case confirmedPlaceCardTapped
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
    }

    public enum Delegate: Equatable {
        case selectMyPlaceTab(place: ConfirmedPlace)
        case meetingDateSelectionRequested(meetingId: Int)
        case departurePlaceStationSearchRequested
        case departurePlaceEditStationSearchRequested(id: Int)
        /// 장소 추천 시작 성공 → 장소 투표 후보 담기 화면으로 진입.
        case startPickPlace(isHost: Bool, meetingId: Int)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // 최초 진입에만 전체 ProgressView를 노출한다.
                // 재진입(탭 전환 복귀 등)에서는 isLoading을 건드리지 않고 조용히 갱신해
                // ProgressView ↔ HomeTab 교체로 인한 재마운트 루프를 막는다.
                if state.groupDetail == nil {
                    state.isLoading = true
                }
                return .concatenate(
                    .merge(
                        fetchGroupDetailEffect(meetingId: state.group.meetingId),
                        fetchVoteEffect(meetingId: state.group.meetingId, kind: state.homeTopAreaKind)
                    ),
                    .send(.loadCompleted)
                )

            case .loadCompleted:
                state.isLoading = false
                return .none

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
                state.isMyAttendanceStatusSheetPresented = true
                return .none

            case .myAttendanceStatusSheetDismissed:
                guard state.isMyAttendanceStatusSheetPresented else { return .none }

                Log.debug("참여 상태 변경 바텀시트 닫힘")
                state.isMyAttendanceStatusSheetPresented = false
                return .none

            case let .myAttendanceStatusSelected(status):
                let groupId = state.group.id
                let client = groupClient
                Log.debug("참여 상태 선택: \(status.displayLabel)")
                state.isMyAttendanceStatusSheetPresented = false
                return .run { send in
                    await send(.myAttendanceStatusUpdateResponse(
                        Result {
                            try await client.updateAttendance(groupId, status)
                            return status
                        }
                    ))
                }

            case let .myAttendanceStatusUpdateResponse(.success(status)):
                state.updateMyAttendanceStatus(status)
                return .none

            case let .myAttendanceStatusUpdateResponse(.failure(error)):
                Log.debug("참석 여부 변경 실패: \(error)")
                return .none

            case .myMemberCardTapped:
                Log.debug("내 멤버 카드 클릭")
                state.isMyDeparturePlaceEditSheetPresented = true
                return .none

            case .myDeparturePlaceEditSheetDismissed:
                // 바텀시트 닫힐 때 이벤트 중복 발생 방지
                guard state.isMyDeparturePlaceEditSheetPresented else { return .none }

                Log.debug("바텀시트 닫힘")
                state.isMyDeparturePlaceEditSheetPresented = false
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

            case .pickPlaceTapped:
                guard state.homeTopAreaKind == .confirmedDate else { return .none }

                // 이미 장소 추천이 시작된(recommended) 상태면 API 호출 없이 화면 전환만 한다.
                let locationStatus = state.groupDetail?.locationStatus ?? state.group.locationStatus
                guard locationStatus != .recommended else {
                    return .send(.delegate(.startPickPlace(isHost: state.isMeHost, meetingId: state.group.meetingId)))
                }

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
                let meetingId = state.group.meetingId
                return .send(.delegate(.startPickPlace(isHost: isHost, meetingId: meetingId)))

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

            case .placeVoteParticipationTapped:
                guard let placeVote = state.placeVote else { return .none }

                state.destination = .placeVoteParticipation(
                    PlaceVoteParticipationFeature.State(
                        meetingId: state.group.meetingId,
                        placeVote: placeVote,
                        members: state.groupDetail?.members ?? []
                    )
                )
                return .none

            case .placeDetailTapped:
                return .none

            case .addDeparturePlaceTapped:
                Log.debug("출발지 추가하기 버튼 클릭")
                state.isMyDeparturePlaceEditSheetPresented = false
                return .send(.delegate(.departurePlaceStationSearchRequested))

            case let .departurePlaceCardTapped(id):
                Log.debug("출발지 카드 클릭: \(id)")
                let client = departurePlaceClient
                return .run { send in
                    await send(.setDefaultDeparturePlaceResponse(
                        Result { try await client.setDefaultDeparturePlace(id) }
                    ))
                }

            case let .setDefaultDeparturePlaceResponse(.success(departurePlace)):
                Log.debug("기본 출발지 설정 성공: \(departurePlace.id)")
                state.updateDefaultDeparturePlace(departurePlace)
                state.isMyDeparturePlaceEditSheetPresented = false
                return .none

            case let .setDefaultDeparturePlaceResponse(.failure(error)):
                Log.debug("기본 출발지 설정 실패: \(error)")
                return .none

            case let .editDeparturePlaceTapped(id):
                Log.debug("출발지 수정하기 버튼 클릭: \(id)")
                state.isMyDeparturePlaceEditSheetPresented = false
                return .send(.delegate(.departurePlaceEditStationSearchRequested(id: id)))

            case .confirmedPlaceCardTapped:
                guard let place = state.confirmedPlaceResult?.place else { return .none }

                return .send(.delegate(.selectMyPlaceTab(place: place)))

            // 게스트 완료: 닫고 장소 투표 현황 재동기화
            case .destination(.presented(.placeVoteParticipation(.delegate(.completed)))):
                state.destination = nil
                return .merge(
                    fetchGroupDetailEffect(meetingId: state.group.meetingId),
                    fetchPlaceVoteEffect(meetingId: state.group.meetingId)
                )

            // 호스트 확정: 닫고 모임 상태를 confirmedPlace로 전환 + 확정 결과 적재
            case .destination(.presented(.placeVoteParticipation(.delegate(.placeConfirmed)))):
                state.destination = nil
                return .merge(
                    fetchGroupDetailEffect(meetingId: state.group.meetingId),
                    fetchConfirmedPlaceResultEffect(meetingId: state.group.meetingId)
                )

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

private extension HomeTabFeature.State {
    mutating func updateDefaultDeparturePlace(_ selectedDeparturePlace: DeparturePlace) {
        guard let detail = groupDetail else { return }

        let members = detail.members.map { member in
            guard member.isMe else { return member }

            let departurePlaces = member.departurePlaces.map { departurePlace in
                if departurePlace.id == selectedDeparturePlace.id {
                    return DeparturePlace(
                        id: selectedDeparturePlace.id,
                        label: selectedDeparturePlace.label,
                        address: selectedDeparturePlace.address,
                        roadAddress: selectedDeparturePlace.roadAddress,
                        placeName: selectedDeparturePlace.placeName,
                        latitude: selectedDeparturePlace.latitude,
                        longitude: selectedDeparturePlace.longitude,
                        isDefault: true
                    )
                }

                return DeparturePlace(
                    id: departurePlace.id,
                    label: departurePlace.label,
                    address: departurePlace.address,
                    roadAddress: departurePlace.roadAddress,
                    placeName: departurePlace.placeName,
                    latitude: departurePlace.latitude,
                    longitude: departurePlace.longitude,
                    isDefault: false
                )
            }

            return GroupDetailMember(
                id: member.id,
                nickname: member.nickname,
                profileImageUrl: member.profileImageUrl,
                isHost: member.isHost,
                isMe: member.isMe,
                attendanceStatus: member.attendanceStatus,
                departurePlaces: departurePlaces
            )
        }

        groupDetail = GroupDetail(
            id: detail.id,
            name: detail.name,
            themeTagCode: detail.themeTagCode,
            themeTagDisplay: detail.themeTagDisplay,
            locationStatus: detail.locationStatus,
            dateVoteStatus: detail.dateVoteStatus,
            confirmedDate: detail.confirmedDate,
            members: members
        )
    }

    mutating func updateMyAttendanceStatus(_ status: AttendanceStatus) {
        guard let detail = groupDetail else { return }

        let members = detail.members.map { member in
            guard member.isMe else { return member }

            return GroupDetailMember(
                id: member.id,
                nickname: member.nickname,
                profileImageUrl: member.profileImageUrl,
                isHost: member.isHost,
                isMe: member.isMe,
                attendanceStatus: status,
                departurePlaces: member.departurePlaces
            )
        }

        groupDetail = GroupDetail(
            id: detail.id,
            name: detail.name,
            themeTagCode: detail.themeTagCode,
            themeTagDisplay: detail.themeTagDisplay,
            locationStatus: detail.locationStatus,
            dateVoteStatus: detail.dateVoteStatus,
            confirmedDate: detail.confirmedDate,
            members: members
        )
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
        case placeVoteParticipation(PlaceVoteParticipationFeature)
    }
}
