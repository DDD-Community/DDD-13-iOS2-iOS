//
//  PlaceMapTabFeature.swift
//  HomeFeature
//

import ComposableArchitecture
import Entity

@Reducer
public struct PlaceMapTabFeature {
    @ObservableState
    public struct State: Equatable {
        public var nearbyPlaceList = NearbyPlaceListSheetFeature.State()
        /// 지도 핀의 소스가 되는 역별 추천 장소 그룹. `SelectPlaceFeature`가 주입한다.
        public var stationGroups: [StationRecommendation] = []
        /// 시트에서 선택된 역 인덱스. `nearbyPlaceList`의 선택을 미러링한다.
        public var selectedStationIndex: Int = 0

        public init() {}

        /// 지도에 표시할 중간지점 역 목록.
        public var stations: [MidpointStation] { stationGroups.map(\.station) }

        /// 현재 선택된 역의 추천 장소 목록. 지도 핀의 소스다.
        public var selectedStationPlaces: [RecommendedPlace] {
            guard stationGroups.indices.contains(selectedStationIndex) else { return [] }

            return stationGroups[selectedStationIndex].places
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
