//
//  RecommendedPlaceMapTab.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity
import Utill

/// 장소 투표 후보 담기 화면의 "장소보기" 탭.
/// 카카오 지도 위에 `MapBottomSheet`를 올리고, 시트는 pickPlace 용도로 노출한다.
struct RecommendedPlaceMapTab: View {
    let store: StoreOf<RecommendedPlaceMapTabFeature>

    /// 바텀시트가 화면 하단을 덮는 높이. detent에 따라 핀 포커싱 중심을 위로 보정하는 데 쓴다.
    @State private var sheetCoveredHeight: CGFloat = 0

    /// 선택된 역 주변의 추천 장소로 구성한 지도 핀. 선택 역 변경 시 `.task`에서 재구성한다.
    @State private var recommendedPlacePins: [MapPin] = []

    /// 지도에 표시할 추천 중간지점 역 목록.
    private var recommendedMidpointStations: [MidpointStation] {
        store.recommendedMidpointStations
    }

    /// 현재 선택된 중간지점 역의 좌표. 세그먼트 선택 시 지도 카메라를 이 좌표로 포커싱한다.
    private var selectedStationCoordinate: MapCoordinate? {
        let index = store.selectedStationIndex
        guard recommendedMidpointStations.indices.contains(index) else { return nil }

        let station = recommendedMidpointStations[index]
        return MapCoordinate(latitude: station.latitude, longitude: station.longitude)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            KakaoMap(
                pins: recommendedPlacePins,
                initialCenter: Constant.defaultCenter,
                focusedCoordinate: selectedStationCoordinate,
                focusBottomInset: sheetCoveredHeight
            )
            .ignoresSafeArea()

            MapBottomSheet(detents: [.ratio(0.4), .full], initialDetent: .ratio(0.4)) {
                NearbyPlaceListSheet(
                    store: store.scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList),
                    mode: .pickPlace
                )
            }
            .onVisibleHeightChanged { sheetCoveredHeight = $0 }
        }
        .task(id: store.selectedStationNearbyPlaces) {
            buildRecommendedPlacePins()
        }
    }

    /// 선택된 역 주변의 추천 장소 좌표로 핀을 구성해 `@State`에 캐싱한다.
    @MainActor
    private func buildRecommendedPlacePins() {
        recommendedPlacePins = store.selectedStationNearbyPlaces.map { place in
            MapPinLabel(image: place.categoryLabel.pinIcon, title: place.name)
                .makePin(
                    id: String(place.placeId),
                    coordinate: MapCoordinate(latitude: place.latitude, longitude: place.longitude)
                )
        }
    }
}

// MARK: - Constants

private enum Constant {
    /// 좌표 정보가 없을 때 사용하는 기본 지도 중심(서울 시청).
    static let defaultCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)
}
