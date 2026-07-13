//
//  MyPlaceTabFeature.swift
//  Presentation
//

import ComposableArchitecture

import CoreDependencies
import DesignSystem
import Entity
import Utill

private enum CancelID {
    case nearby
}

@Reducer
public struct MyPlaceTabFeature {
    @ObservableState
    public struct State: Equatable {
        public var nearbyPlaceList: NearbyPlaceListSheetFeature.State = .init()
        /// 포커싱 장소가 있을 때 표시할 장소 디테일 시트.
        public var selectedPlaceDetail: SelectedPlaceDetailSheetFeature.State = .mock
        /// 포커싱할 확정 장소. 설정 시 지도 중심·핀을 이 장소로 맞춘다.
        var focusedPlace: ConfirmedPlace?

        public init() {}
    }

    public enum Action {
        case placeFocused(ConfirmedPlace)
        case mapCenterChanged(MapCoordinate)
        case nearbyPlacesResponse(stationName: String?, places: [NearbyPlace])
        case nearbyPlaceList(NearbyPlaceListSheetFeature.Action)
        case selectedPlaceDetail(SelectedPlaceDetailSheetFeature.Action)
    }

    @Dependency(\.searchStationsClient) var searchStationsClient
    @Dependency(\.nearbyPlacesClient) var nearbyPlacesClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList) {
            NearbyPlaceListSheetFeature()
        }

        Scope(state: \.selectedPlaceDetail, action: \.selectedPlaceDetail) {
            SelectedPlaceDetailSheetFeature()
        }

        // TODO: 지도 핀/장소 데이터 연동 시 로직 확장 지점
        Reduce { state, action in
            switch action {
            case let .placeFocused(place):
                state.focusedPlace = place
                return .send(.selectedPlaceDetail(.placeFocused(place)))

            case let .mapCenterChanged(coordinate):
                return fetchNearbyPlaces(latitude: coordinate.latitude, longitude: coordinate.longitude)

            case let .nearbyPlacesResponse(stationName, places):
                return .send(.nearbyPlaceList(.nearbyPlacesUpdated(stationName: stationName, places: places)))

            case let .nearbyPlaceList(.delegate(.placeTapped(place))):
                return .send(.placeFocused(place))

            case .nearbyPlaceList:
                return .none

            case .selectedPlaceDetail(.closeButtonTapped):
                state.focusedPlace = nil
                return .none

            case .selectedPlaceDetail:
                return .none
            }
        }
    }

    private func fetchNearbyPlaces(latitude: Double, longitude: Double) -> Effect<Action> {
        let searchStationsClient = self.searchStationsClient
        let nearbyPlacesClient = self.nearbyPlacesClient

        return .run { send in
            do {
                guard let station = try await searchStationsClient.findNearestStation(longitude, latitude) else {
                    await send(.nearbyPlacesResponse(stationName: nil, places: []))
                    return
                }

                let places = try await nearbyPlacesClient.fetchNearbyPlaces(station.y, station.x, 1000, nil)
                await send(.nearbyPlacesResponse(stationName: station.name, places: places))
            } catch {
                Log.debug("근처 장소 조회 실패: \(error.localizedDescription)")
            }
        }
        .cancellable(id: CancelID.nearby, cancelInFlight: true)
    }
}
