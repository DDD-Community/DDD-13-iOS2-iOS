//
//  NearbyPlaceListSheetFeature.swift
//  HomeFeature
//

import ComposableArchitecture
import Entity
import Utill

public enum NearbyPlaceCategory: String, CaseIterable, Equatable, Sendable {
    case all = "전체"
    case cafe = "카페"
    case desert = "디저트"
    case koreaFood = "한식"
    case japaneseFood = "일식"
    case snackBar = "분식"
    case asianFood = "아시아 음식"
    case buffet = "뷔페"
    case bar = "주점"
    case etc = "기타"

    var title: String { rawValue }
}

@Reducer
public struct NearbyPlaceListSheetFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedCategory: NearbyPlaceCategory = .all // 카테고리
        public var isParkingAvailableSelected = false // 주차 가능 여부
        public var isReservableSelected = false // 예약 가능여부
        public var selectedPlaceDetail: SelectedPlaceDetailSheetFeature.State = .mock

        // MARK: - 장소보기(selectPlace) 용도 전용 상태
        /// 역별 추천 장소 그룹 목록. `SelectPlaceFeature.onAppear`에서 API 응답으로 채워진다.
        public var stationGroups: [StationRecommendation] = []
        /// 선택된 지하철역 인덱스.
        public var selectedStationIndex: Int = 0
        /// 후보로 담은 장소 인덱스 집합. 담기 버튼 토글 상태를 표현한다.
        public var pickedPlaceIndices: Set<Int> = []

        // MARK: - default 모드 전용
        /// default(모임 상세) 모드에서 리스트에 표시할 mock 장소 개수.
        public var placeCount: Int = 5

        public init() {}

        /// selectPlace 모드에서 segmented control에 표시할 역 목록.
        public var stations: [MidpointStation] { stationGroups.map(\.station) }

        /// 현재 선택된 역의 추천 장소 목록.
        public var selectedStationPlaces: [RecommendedPlace] {
            stationGroups.indices.contains(selectedStationIndex)
                ? stationGroups[selectedStationIndex].places
                : []
        }
    }

    public enum Action: Equatable {
        case categoryTapped(NearbyPlaceCategory)
        case parkingAvailableFilterTapped
        case reservableFilterTapped
        case stationSelected(Int)
        case placeAddTapped(Int)
        case selectedPlaceDetail(SelectedPlaceDetailSheetFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.selectedPlaceDetail, action: \.selectedPlaceDetail) {
            SelectedPlaceDetailSheetFeature()
        }

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
                // 역마다 추천 장소 목록이 달라지므로, 인덱스 기반 담기 상태는 역 전환 시 초기화한다.
                // TODO: 담기 API 연동(#77) 시 placeId 기반 상태로 교체하면 이 초기화는 불필요해진다.
                state.pickedPlaceIndices.removeAll()
                let stationName = state.stations.indices.contains(index) ? state.stations[index].stationName : "-"
                Log.debug("지하철역 선택: \(stationName)")
                return .none

            // TODO: 장소 담기/취소 API 연동(#77) 시 실제 담기 요청으로 교체한다.
            case let .placeAddTapped(index):
                if state.pickedPlaceIndices.contains(index) {
                    state.pickedPlaceIndices.remove(index)
                } else {
                    state.pickedPlaceIndices.insert(index)
                }
                return .none

            case .selectedPlaceDetail:
                return .none
            }
        }
    }
}
