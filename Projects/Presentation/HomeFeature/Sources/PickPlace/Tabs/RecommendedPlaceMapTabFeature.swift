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
        /// 포커싱할 장소. 설정 시 지도 카메라를 이 장소로 맞추고 상세 시트로 전환한다.
        public var focusedPlace: ConfirmedPlace?
        /// 포커싱 장소가 있을 때 표시할 장소 상세 시트.
        public var selectedPlaceDetail: SelectedPlaceDetailSheetFeature.State = .mock

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
        case placeFocused(ConfirmedPlace)
        case nearbyPlaceList(NearbyPlaceListSheetFeature.Action)
        case selectedPlaceDetail(SelectedPlaceDetailSheetFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList) {
            NearbyPlaceListSheetFeature()
        }

        Scope(state: \.selectedPlaceDetail, action: \.selectedPlaceDetail) {
            SelectedPlaceDetailSheetFeature()
        }

        Reduce { state, action in
            switch action {
            case let .nearbyPlaceList(.stationSelected(index)):
                state.selectedStationIndex = index
                return .none

            case let .nearbyPlaceList(.delegate(.placeTapped(place))):
                return .send(.placeFocused(place))

            case .nearbyPlaceList:
                return .none

            case let .placeFocused(place):
                state.focusedPlace = place
                return .send(.selectedPlaceDetail(.placeFocused(place)))

            case .selectedPlaceDetail(.closeButtonTapped):
                state.focusedPlace = nil
                return .none

            case .selectedPlaceDetail:
                return .none
            }
        }
    }
}
