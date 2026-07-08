//
//  NearbyPlaceListSheetFeature.swift
//  HomeFeature
//

import ComposableArchitecture
import Entity
import Utill

@Reducer
public struct NearbyPlaceListSheetFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedCategory: PlaceCategory = .all // 카테고리
        public var isParkingAvailableSelected = false // 주차 가능 여부
        public var isReservableSelected = false // 예약 가능여부

        // MARK: - 역 기반 근처 장소 상태
        /// 현재 지도 중심에서 가장 가까운 역 이름. 역을 찾지 못하면 `nil`.
        public var stationName: String?
        /// 역 기준 반경 내 근처 장소 목록.
        public var nearbyPlaces: [NearbyPlace] = []

        // MARK: - 장소보기(pickPlace) 용도 전용 상태
        /// 역별 추천 장소 그룹 목록. `PickPlaceFeature.onAppear`에서 API 응답으로 채워진다.
        public var stationGroups: [StationRecommendation] = []
        /// 선택된 지하철역 인덱스.
        public var selectedStationIndex: Int = 0
        /// 후보로 담은 장소 ID 집합. 역 전환과 무관하게 담기 버튼 상태를 표현한다.
        public var pickedPlaceIds: Set<Int> = []

        public init() {}

        /// pickPlace 모드에서 segmented control에 표시할 역 목록.
        public var stations: [MidpointStation] { stationGroups.map(\.station) }

        /// pickPlace 모드에서 현재 노출할 추천 장소 목록(선택된 역 기준).
        public var visibleRecommendedPlaces: [RecommendedPlace] {
            guard stationGroups.indices.contains(selectedStationIndex) else { return [] }

            return stationGroups[selectedStationIndex].places
        }

        /// selectedCategory·주차·예약 필터를 모두 반영해 노출할 근처 장소 목록.
        /// 각 필터는 선택됐을 때만 적용되고, 여러 필터는 AND로 결합된다.
        public var visibleNearbyPlaces: [NearbyPlace] {
            nearbyPlaces.filter { place in
                let matchesCategory = selectedCategory == .all || place.categoryLabel == selectedCategory
                let matchesParking = !isParkingAvailableSelected || place.hasParking
                let matchesReservable = !isReservableSelected || place.reservable
                return matchesCategory && matchesParking && matchesReservable
            }
        }
    }

    public enum Action: Equatable {
        case categoryTapped(PlaceCategory)
        case parkingAvailableFilterTapped
        case reservableFilterTapped
        case stationSelected(Int)
        case placeAddTapped(placeId: Int)
        case placeRowTapped(ConfirmedPlace)
        case nearbyPlacesUpdated(stationName: String?, places: [NearbyPlace])
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case placeTapped(ConfirmedPlace)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .categoryTapped(let category):
                state.selectedCategory = category
                Log.debug("역근처 장소 카테고리 선택: \(category.title)")
                return .none

            case .parkingAvailableFilterTapped:
                state.isParkingAvailableSelected.toggle()
                Log.debug("역근처 장소 주차 가능 필터: \(state.isParkingAvailableSelected ? "선택" : "해제")")
                return .none

            case .reservableFilterTapped:
                state.isReservableSelected.toggle()
                Log.debug("역근처 장소 예약 가능 필터: \(state.isReservableSelected ? "선택" : "해제")")
                return .none

            case let .stationSelected(index):
                state.selectedStationIndex = index
                let stationName = state.stations.indices.contains(index) ? state.stations[index].stationName : "-"
                Log.debug("지하철역 선택: \(stationName)")
                return .none

            case .placeAddTapped:
                return .none

            case let .placeRowTapped(place):
                Log.debug("역근처 장소 선택: \(place.name)")
                return .send(.delegate(.placeTapped(place)))

            case let .nearbyPlacesUpdated(stationName, places):
                state.stationName = stationName
                state.nearbyPlaces = places
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
