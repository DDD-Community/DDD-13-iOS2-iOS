//
//  PlaceMapTab.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity
import Utill

/// 장소 투표 후보 담기 화면의 "장소보기" 탭.
/// 카카오 지도 위에 `MapBottomSheet`를 올리고, 시트는 selectPlace 용도로 노출한다.
struct PlaceMapTab: View {
    let store: StoreOf<PlaceMapTabFeature>

    /// 바텀시트가 화면 하단을 덮는 높이. detent에 따라 핀 포커싱 중심을 위로 보정하는 데 쓴다.
    @State private var sheetCoveredHeight: CGFloat = 0

    /// 지도에 표시할 중간지점 역 목록.
    private var stations: [MidpointStation] {
        store.nearbyPlaceList.stations
    }

    /// 현재 선택된 역의 좌표. 세그먼트 선택 시 지도 카메라를 이 좌표로 포커싱한다.
    private var selectedStationCoordinate: MapCoordinate? {
        let index = store.nearbyPlaceList.selectedStationIndex
        guard stations.indices.contains(index) else { return nil }

        let station = stations[index]
        return MapCoordinate(latitude: station.latitude, longitude: station.longitude)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            KakaoMap(
                initialCenter: Constant.defaultCenter,
                focusedCoordinate: selectedStationCoordinate,
                focusBottomInset: sheetCoveredHeight
            )
            .ignoresSafeArea()

            MapBottomSheet(detents: [.medium, .full], initialDetent: .medium) {
                NearbyPlaceListSheet(
                    store: store.scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList),
                    mode: .selectPlace
                )
            }
            .onVisibleHeightChanged { sheetCoveredHeight = $0 }
        }
    }
}

// MARK: - Constants

private enum Constant {
    /// 좌표 정보가 없을 때 사용하는 기본 지도 중심(서울 시청).
    static let defaultCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)
}
