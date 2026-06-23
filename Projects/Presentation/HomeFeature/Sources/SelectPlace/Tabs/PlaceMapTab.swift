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

    /// 중간지점 역 핀. `selectedStationIndex`로 핀 탭 시 역 선택과 연동한다.
    @State private var pins: [MapPin] = []
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
                pins: pins,
                initialCenter: Constant.defaultCenter,
                focusedCoordinate: selectedStationCoordinate,
                focusBottomInset: sheetCoveredHeight
            )
            .onPinTapped { pin in
                guard let index = Int(pin.id) else { return }

                store.send(.nearbyPlaceList(.stationSelected(index)))
            }
            .ignoresSafeArea()

            MapBottomSheet(detents: [.medium, .full], initialDetent: .medium) {
                NearbyPlaceListSheet(
                    store: store.scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList),
                    mode: .selectPlace
                )
            }
            .onVisibleHeightChanged { sheetCoveredHeight = $0 }
        }
        .task(id: stations.map(\.stationId)) {
            buildStationPins()
        }
    }

    // MARK: - 역 Pin 구성

    @MainActor
    private func buildStationPins() {
        pins = stations.enumerated().map { index, station in
            MapPinLabel(assetName: Constant.stationPinAsset, title: "\(station.stationName)역")
                .makePin(
                    id: String(index),
                    coordinate: MapCoordinate(latitude: station.latitude, longitude: station.longitude)
                )
        }
    }
}

// MARK: - Constants

private enum Constant {
    /// 좌표 정보가 없을 때 사용하는 기본 지도 중심(서울 시청).
    static let defaultCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)

    /// 중간지점 역 핀에 사용하는 아이콘 에셋.
    static let stationPinAsset = "ic_pin_24"
}
