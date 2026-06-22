//
//  PlaceMapTab.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture

import DesignSystem
import Utill

/// 장소 투표 후보 담기 화면의 "장소보기" 탭.
/// 카카오 지도 위에 `MapBottomSheet`를 올리고, 시트는 selectPlace 용도로 노출한다.
struct PlaceMapTab: View {
    let store: StoreOf<PlaceMapTabFeature>

    // TODO: 추천 장소 API 연동(#77) 시 mock 핀을 실제 장소 데이터로 교체한다.
    @State private var pins: [MapPin] = []
    /// 바텀시트가 화면 하단을 덮는 높이. detent에 따라 핀 포커싱 중심을 위로 보정하는 데 쓴다.
    @State private var sheetCoveredHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            KakaoMap(pins: pins, initialCenter: Constant.defaultCenter, focusBottomInset: sheetCoveredHeight)
                .onPinTapped { pin in
                    Log.debug("핀 선택: id=\(pin.id), title=\(pin.title)")
                }
                .ignoresSafeArea()

            MapBottomSheet {
                // TODO: 추천 장소 DTO에 stationId가 추가되면 NearbyPlaceListSheet의 역별 장소 리스트 노출을 복구한다.
                NearbyPlaceListSheet(
                    store: store.scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList),
                    mode: .selectPlace
                )
            }
            .onVisibleHeightChanged { sheetCoveredHeight = $0 }
        }
        .task {
            buildSamplePins()
        }
    }

    // MARK: - 디버깅용 임시 Pin 구성

    @MainActor
    private func buildSamplePins() {
        pins = Constant.samplePlaces.map { place in
            MapPinLabel(assetName: place.iconAsset, title: place.name)
                .makePin(id: place.name, coordinate: place.coordinate)
        }
    }
}

// MARK: - SamplePlace

private struct SamplePlace {
    let name: String
    let coordinate: MapCoordinate
    let iconAsset: String
}

// MARK: - Constants

private enum Constant {
    /// 좌표 정보가 없을 때 사용하는 기본 지도 중심(서울 시청).
    static let defaultCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)

    /// 디버깅용 임시 샘플 장소. 실제 데이터 연동 시 제거한다.
    static let samplePlaces: [SamplePlace] = [
        SamplePlace(name: "감성카페", coordinate: MapCoordinate(latitude: 37.5665, longitude: 126.9780), iconAsset: "ic_map_pin_cafe"),
        SamplePlace(name: "남산다이닝", coordinate: MapCoordinate(latitude: 37.5512, longitude: 126.9882), iconAsset: "ic_map_pin_buffet"),
        SamplePlace(name: "경복궁디저트", coordinate: MapCoordinate(latitude: 37.5796, longitude: 126.9770), iconAsset: "ic_map_pin_dessert"),
        SamplePlace(name: "명동포차", coordinate: MapCoordinate(latitude: 37.5637, longitude: 126.9850), iconAsset: "ic_map_pin_pub"),
        SamplePlace(name: "광화문식당", coordinate: MapCoordinate(latitude: 37.5759, longitude: 126.9769), iconAsset: "ic_map_pin_restaurant"),
    ]
}
