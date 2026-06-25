//
//  RecommendedPlaceMapTabFeature.swift
//  HomeFeature
//

import ComposableArchitecture
import Entity

@Reducer
public struct RecommendedPlaceMapTabFeature {
    @ObservableState
    public struct State: Equatable {
        public var nearbyPlaceList = NearbyPlaceListSheetFeature.State()
        /// 추천받은 중간지점 역과 역별 주변 추천 장소 묶음. `PickPlaceFeature`가 주입한다.
        public var stationRecommendations: [StationRecommendation] = []
        /// 시트에서 선택된 역 인덱스. `nearbyPlaceList`의 선택을 미러링한다.
        public var selectedStationIndex: Int = 0

        public init() {}

        /// 지도에 표시할 추천 중간지점 역 목록.
        public var recommendedMidpointStations: [MidpointStation] {
            stationRecommendations.map(\.station)
        }

        /// 선택된 역 주변의 추천 장소 목록. 지도 핀의 소스다.
        public var selectedStationNearbyPlaces: [RecommendedPlace] {
            guard stationRecommendations.indices.contains(selectedStationIndex) else { return [] }

            return stationRecommendations[selectedStationIndex].places
        }
    }

    public enum Action {
        case nearbyPlaceList(NearbyPlaceListSheetFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList) {
            NearbyPlaceListSheetFeature()
        }

        Reduce { state, action in
            switch action {
            case let .nearbyPlaceList(.stationSelected(index)):
                state.selectedStationIndex = index
                return .none

            case .nearbyPlaceList:
                return .none
            }
        }
    }
}
