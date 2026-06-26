//
//  MyPlaceTab.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity
import Utill

/// 모임 상세 "내 장소보기" 탭.
/// 카카오 지도 위에 `MapBottomSheet`를 ZStack으로 올린다.
struct MyPlaceTab: View {
    let store: StoreOf<MyPlaceTabFeature>

    // TODO: 디버깅용 임시 핀. 실제 장소 데이터 연동 시 제거한다.
    @State private var pins: [MapPin] = []
    /// 바텀시트가 화면 하단을 덮는 높이. detent에 따라 핀 포커싱 중심을 위로 보정하는 데 쓴다.
    @State private var sheetCoveredHeight: CGFloat = 0

    /// 포커싱 대상이 있으면 그 좌표, 없으면 기본 중심.
    private var mapCenter: MapCoordinate {
        guard let place = store.focusedPlace else { return Constant.defaultCenter }

        return MapCoordinate(latitude: place.latitude, longitude: place.longitude)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            KakaoMap(
                pins: pins,
                initialCenter: mapCenter,
                focusBottomInset: sheetCoveredHeight
            )
            .onPinTapped { pin in
                Log.debug("핀 선택: id=\(pin.id), title=\(pin.title), coordinate=(\(pin.coordinate.latitude), \(pin.coordinate.longitude))")
            }
            .onCenterChanged { viewport in
                Log.debug("중심 좌표 변경: center=(\(viewport.center.latitude), \(viewport.center.longitude)), zoomLevel=\(viewport.zoomLevel)")
            }
            .ignoresSafeArea()
            
            MapBottomSheet(
                detents: [.collapsed, .ratio(0.5), .full],
                initialDetent: .ratio(0.5)
            ) {
                if store.focusedPlace != nil {
                    SelectedPlaceDetailSheet(
                        store: store.scope(state: \.selectedPlaceDetail, action: \.selectedPlaceDetail)
                    )
                } else {
                    NearbyPlaceListSheet(
                        store: store.scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList)
                    )
                }
            }
            .onVisibleHeightChanged { sheetCoveredHeight = $0 }
        }
        .task(id: store.focusedPlace) {
            buildPins()
        }
    }

    // MARK: - Pin 구성

    /// 포커싱 장소가 있으면 그 핀 하나만, 없으면 디버깅용 샘플 핀을 구성한다.
    @MainActor
    private func buildPins() {
        guard let place = store.focusedPlace else {
            pins = Constant.samplePlaces.map { place in
                MapPinLabel(assetName: place.iconAsset, title: place.name)
                    .makePin(id: place.name, coordinate: place.coordinate)
            }
            return
        }

        let coordinate = MapCoordinate(latitude: place.latitude, longitude: place.longitude)
        pins = [
            MapPinLabel(image: place.categoryLabel.pinIcon, title: place.name)
                .makePin(id: String(place.placeId), coordinate: coordinate)
        ]
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
