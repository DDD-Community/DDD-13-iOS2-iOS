//
//  MyPlaceTab.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

import DesignSystem
import Utill

/// 모임 상세 "내 장소보기" 탭.
/// 카카오 지도 위에 `MapBottomSheet`를 ZStack으로 올린다.
struct MyPlaceTab: View {
    let store: StoreOf<GroupDetailFeature>

    // TODO: 디버깅용 임시 핀. 실제 장소 데이터 연동 시 제거한다.
    @State private var pins: [MapPin] = []

    var body: some View {
        ZStack(alignment: .bottom) {
            KakaoMap(pins: pins, initialCenter: Constant.defaultCenter)
                .onPinTapped { pin in
                    Log.debug("핀 선택: id=\(pin.id), title=\(pin.title), coordinate=(\(pin.coordinate.latitude), \(pin.coordinate.longitude))")
                }
                .onCenterChanged { viewport in
                    Log.debug("중심 좌표 변경: center=(\(viewport.center.latitude), \(viewport.center.longitude)), zoomLevel=\(viewport.zoomLevel)")
                }
                .ignoresSafeArea()

            MapBottomSheet {
                NearbyPlaceListSheet(
                    store: store.scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList)
                )
            }
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
        SamplePlace(name: "남산다이닝", coordinate: MapCoordinate(latitude: 37.5512, longitude: 126.9882), iconAsset: "ic_map_pin_restaurant"),
        SamplePlace(name: "경복궁디저트", coordinate: MapCoordinate(latitude: 37.5796, longitude: 126.9770), iconAsset: "ic_map_pin_dessert"),
        SamplePlace(name: "명동포차", coordinate: MapCoordinate(latitude: 37.5637, longitude: 126.9850), iconAsset: "ic_map_pin_bar"),
        SamplePlace(name: "광화문식당", coordinate: MapCoordinate(latitude: 37.5759, longitude: 126.9769), iconAsset: "ic_map_pin_food"),
    ]
}
