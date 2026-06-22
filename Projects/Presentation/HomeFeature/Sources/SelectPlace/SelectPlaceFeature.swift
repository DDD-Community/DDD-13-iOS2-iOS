//
//  SelectPlaceFeature.swift
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
public struct SelectPlaceFeature {
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.placeRecommendationClient) private var placeRecommendationClient

    @ObservableState
    public struct State: Equatable {
        public var selectedSubTabIndex = 0
        public var nearbyPlaceList = NearbyPlaceListSheetFeature.State()
        public var members: [SelectPlaceMember]
        public var pickedPlaces: [PickedPlace]
        public var selectedFilterCategory: NearbyPlaceCategory = .all
        /// 현재 사용자가 호스트인지 여부. 하단 "투표 생성" 버튼 노출 분기에 사용한다.
        public let isHost: Bool
        /// 추천 장소 화면 진입 시 전달받는 모임 ID.
        public let meetingId: Int
        /// `onAppear` 시 역/추천 장소 API를 1회만 호출하기 위한 가드 플래그.
        public var hasLoadedRecommendations = false

        public init(
            members: [SelectPlaceMember] = SelectPlaceMember.mock,
            pickedPlaces: [PickedPlace] = PickedPlace.mock,
            isHost: Bool = false,
            meetingId: Int = 0
        ) {
            self.members = members
            self.pickedPlaces = pickedPlaces
            self.isHost = isHost
            self.meetingId = meetingId
        }

        public var subTabs: [SelectPlaceTab] { [.placeMap, .pickedPlace] }

        public var selectedSubTab: SelectPlaceTab {
            subTabs[max(0, min(selectedSubTabIndex, subTabs.count - 1))]
        }

        public var isPickedPlaceEmpty: Bool { pickedPlaces.isEmpty }

        /// 선택된 카테고리 필터로 거른 담은 장소 리스트.
        public var filteredPickedPlaces: [PickedPlace] {
            guard selectedFilterCategory != .all else { return pickedPlaces }

            return pickedPlaces.filter { $0.category == selectedFilterCategory }
        }

        /// "전체"부터 시작해, 담은 장소에 실제 등장하는 카테고리만 개수와 함께 나열한 필터 목록.
        public var categoryFilters: [CategoryFilter] {
            let all = CategoryFilter(category: .all, count: pickedPlaces.count)
            let present = NearbyPlaceCategory.allCases
                .filter { $0 != .all }
                .compactMap { category -> CategoryFilter? in
                    let count = pickedPlaces.filter { $0.category == category }.count
                    return count > 0 ? CategoryFilter(category: category, count: count) : nil
                }
            return [all] + present
        }
    }

    /// 담은 장소 탭 카테고리 필터 칩 한 개.
    public struct CategoryFilter: Equatable, Identifiable, Sendable {
        public let category: NearbyPlaceCategory
        public let count: Int

        public var id: NearbyPlaceCategory { category }
        public var label: String { "\(category.title) \(count)" }
    }

    public enum Action {
        case onAppear
        case subTabSelected(Int)
        case nearbyPlaceList(NearbyPlaceListSheetFeature.Action)
        case categoryFilterSelected(NearbyPlaceCategory)
        case goPickPlaceTapped
        case createVoteTapped
        case backButtonTapped
        case stationRecommendationsResponse(Result<[StationRecommendation], Error>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList) {
            NearbyPlaceListSheetFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.hasLoadedRecommendations else { return .none }

                state.hasLoadedRecommendations = true
                let client = placeRecommendationClient
                let meetingId = state.meetingId
                return .run { send in
                    await send(.stationRecommendationsResponse(
                        Result { try await client.fetchStationRecommendations(meetingId) }
                    ))
                }

            case let .stationRecommendationsResponse(.success(groups)):
                state.nearbyPlaceList.stationGroups = groups
                state.nearbyPlaceList.selectedStationIndex = 0
                return .none

            case let .stationRecommendationsResponse(.failure(error)):
                Log.error("역 추천 장소 조회 실패: \(error)")
                return .none

            case let .subTabSelected(index):
                state.selectedSubTabIndex = index
                return .none

            case let .categoryFilterSelected(category):
                state.selectedFilterCategory = category
                return .none

            // 빈 상태에서 "투표 후보 담으러가기" → 장소보기 탭으로 전환.
            case .goPickPlaceTapped:
                state.selectedSubTabIndex = 0
                return .none

            // TODO: 담은 장소 기반 투표 생성 API 연동(#77). 현재는 no-op.
            case .createVoteTapped:
                return .none

            case .backButtonTapped:
                let dismiss = self.dismiss
                return .run { _ in await dismiss() }

            case .nearbyPlaceList:
                return .none
            }
        }
    }
}
