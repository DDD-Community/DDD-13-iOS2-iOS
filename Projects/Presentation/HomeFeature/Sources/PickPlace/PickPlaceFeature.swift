//
//  PickPlaceFeature.swift
//  HomeFeature
//

import ComposableArchitecture
import CoreDependencies
import Entity
import Utill

/// 장소 투표 후보 담기 화면.
///
/// 추천받은 장소를 지도에서 담고(장소보기 탭), 모임원이 담은 후보를 모아 보며(담은 장소 탭)
/// 호스트가 투표를 생성하는 진입 전 단계 화면이다. 현재는 mock 기반 UI 골격이다.
@Reducer
public struct PickPlaceFeature {
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.placePickClient) private var placePickClient
    @Dependency(\.placeRecommendationClient) private var placeRecommendationClient
    @Dependency(\.voteClient) private var voteClient

    @ObservableState
    public struct State: Equatable {
        public var selectedSubTabIndex = 0
        public var recommendedPlaceMap = RecommendedPlaceMapTabFeature.State()
        public var pickedPlace: PickedPlaceTabFeature.State
        /// 추천 장소 화면 진입 시 전달받는 모임 ID.
        public let meetingId: Int
        /// `onAppear` 시 역/추천 장소 API를 1회만 호출하기 위한 가드 플래그.
        public var hasLoadedRecommendations = false

        public init(
            members: [PickPlaceMember] = [],
            pickedPlaces: [PickedPlace] = [],
            isHost: Bool = false,
            meetingId: Int = 0
        ) {
            self.pickedPlace = PickedPlaceTabFeature.State(
                members: members,
                pickedPlaces: pickedPlaces,
                isHost: isHost
            )
            self.meetingId = meetingId
        }

        public var subTabs: [PickPlaceTab] { [.recommendedPlaceMap, .pickedPlace] }

        public var selectedSubTab: PickPlaceTab {
            subTabs[max(0, min(selectedSubTabIndex, subTabs.count - 1))]
        }
    }

    public enum Action {
        case onAppear
        case tabSelected(Int)
        case recommendedPlaceMap(RecommendedPlaceMapTabFeature.Action)
        case pickedPlace(PickedPlaceTabFeature.Action)
        case backButtonTapped
        case stationRecommendationsResponse(Result<[StationRecommendation], Error>)
        case placePickStatusResponse(Result<PlacePickStatus, Error>)
        case placePickToggleResponse(placeId: Int, wasPicked: Bool, Result<Void, Error>)
        case startPlaceVoteResponse(Result<Void, Error>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.recommendedPlaceMap, action: \.recommendedPlaceMap) {
            RecommendedPlaceMapTabFeature()
        }

        Scope(state: \.pickedPlace, action: \.pickedPlace) {
            PickedPlaceTabFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.hasLoadedRecommendations else { return .none }

                state.hasLoadedRecommendations = true
                let placeRecommendationClient = placeRecommendationClient
                let placePickClient = placePickClient
                let meetingId = state.meetingId
                return .merge(
                    .run { send in
                        await send(.stationRecommendationsResponse(
                            Result { try await placeRecommendationClient.fetchStationRecommendations(meetingId) }
                        ))
                    },
                    .run { send in
                        await send(.placePickStatusResponse(
                            Result { try await placePickClient.fetchPickStatus(meetingId) }
                        ))
                    }
                )

            case let .stationRecommendationsResponse(.success(groups)):
                state.recommendedPlaceMap.stationRecommendations = groups
                state.recommendedPlaceMap.selectedStationIndex = 0
                state.recommendedPlaceMap.nearbyPlaceList.stationGroups = groups
                state.recommendedPlaceMap.nearbyPlaceList.selectedStationIndex = 0
                return .none

            case let .stationRecommendationsResponse(.failure(error)):
                Log.error("역 추천 장소 조회 실패: \(error)")
                return .none

            case let .placePickStatusResponse(.success(status)):
                state.pickedPlace.members = status.members.map { PickPlaceMember(member: $0) }
                state.pickedPlace.pickedPlaces = status.myPicks.map { PickedPlace(summary: $0) }
                state.recommendedPlaceMap.nearbyPlaceList.pickedPlaceIds = Set(status.myPicks.map(\.placeId))
                return .none

            case let .placePickStatusResponse(.failure(error)):
                Log.error("장소 담기 현황 조회 실패: \(error)")
                return .none

            case let .tabSelected(index):
                state.selectedSubTabIndex = index
                return .none

            // 빈 상태에서 "투표 후보 담으러가기" → 장소보기 탭으로 전환.
            case .pickedPlace(.delegate(.goPickPlaceTapped)):
                state.selectedSubTabIndex = 0
                return .none

            case .pickedPlace(.delegate(.createVoteTapped)):
                let meetingId = state.meetingId
                let voteClient = voteClient
                return .run { send in
                    await send(.startPlaceVoteResponse(
                        Result {
                            try await voteClient.startPlaceVote(
                                meetingId,
                                Constant.defaultPlaceVoteDurationDays
                            )
                        }
                    ))
                }

            case .startPlaceVoteResponse(.success):
                let dismiss = self.dismiss
                return .run { _ in await dismiss() }

            case let .startPlaceVoteResponse(.failure(error)):
                Log.error("장소 투표 시작 실패: \(error)")
                return .none

            case .backButtonTapped:
                let dismiss = self.dismiss
                return .run { _ in await dismiss() }

            case let .recommendedPlaceMap(.nearbyPlaceList(.placeAddTapped(placeId: placeId))):
                let wasPicked = state.recommendedPlaceMap.nearbyPlaceList.pickedPlaceIds.contains(placeId)
                let meetingId = state.meetingId
                let client = placePickClient
                return .run { send in
                    await send(.placePickToggleResponse(
                        placeId: placeId,
                        wasPicked: wasPicked,
                        Result {
                            try await client.togglePlacePick(
                                meetingId: meetingId,
                                placeId: placeId,
                                isCurrentlyPicked: wasPicked
                            )
                        }
                    ))
                }

            case let .placePickToggleResponse(placeId, wasPicked, .success):
                updatePickedPlaceState(placeId: placeId, wasPicked: wasPicked, state: &state)
                return .none

            case let .placePickToggleResponse(placeId, _, .failure(error)):
                Log.error("장소 담기 상태 변경 실패(placeId: \(placeId)): \(error)")
                return .none

            case .recommendedPlaceMap, .pickedPlace:
                return .none
            }
        }
    }
}

private enum Constant {
    static let defaultPlaceVoteDurationDays = 3
}

private extension PickPlaceFeature {
    func updatePickedPlaceState(placeId: Int, wasPicked: Bool, state: inout State) {
        if wasPicked {
            state.recommendedPlaceMap.nearbyPlaceList.pickedPlaceIds.remove(placeId)
            state.pickedPlace.pickedPlaces.removeAll { $0.id == placeId }
        } else {
            state.recommendedPlaceMap.nearbyPlaceList.pickedPlaceIds.insert(placeId)
            appendPickedPlaceIfNeeded(placeId: placeId, state: &state)
        }
    }

    func appendPickedPlaceIfNeeded(placeId: Int, state: inout State) {
        guard !state.pickedPlace.pickedPlaces.contains(where: { $0.id == placeId }) else { return }

        let recommendedPlace = state.recommendedPlaceMap.nearbyPlaceList.stationGroups
            .reduce(into: [RecommendedPlace]()) { result, group in
                result.append(contentsOf: group.places)
            }
            .first { $0.placeId == placeId }

        guard let recommendedPlace else { return }

        state.pickedPlace.pickedPlaces.append(PickedPlace(place: recommendedPlace))
    }
}
