//
//  NearbyPlaceListSheetFeature.swift
//  HomeFeature
//

import ComposableArchitecture
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

        public init() {}
    }

    public enum Action: Equatable {
        case categoryTapped(NearbyPlaceCategory)
        case parkingAvailableFilterTapped
        case reservableFilterTapped
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
            }
        }
    }
}
