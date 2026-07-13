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

    /// 지도에 표시할 핀. 포커싱 장소 또는 역 기반 근처 장소 목록으로 구성한다.
    @State private var pins: [MapPin] = []
    /// 바텀시트가 화면 하단을 덮는 높이. detent에 따라 핀 포커싱 중심을 위로 보정하는 데 쓴다.
    @State private var sheetCoveredHeight: CGFloat = 0

    /// 핀 재구성 트리거. 포커싱 장소 또는 근처 장소 목록이 바뀌면 핀을 다시 만든다.
    private var pinInput: PinInput {
        PinInput(focusedPlace: store.focusedPlace, nearbyPlaces: store.nearbyPlaceList.visibleNearbyPlaces)
    }

    /// 포커싱 대상이 있으면 그 좌표, 없으면 기본 중심.
    private var mapCenter: MapCoordinate {
        guard let place = store.focusedPlace else { return Constant.defaultCenter }

        return MapCoordinate(latitude: place.latitude, longitude: place.longitude)
    }

    /// 포커싱 장소가 있으면 그 좌표. 이미 살아있는 지도의 카메라를 애니메이션 이동시키는 데 쓴다.
    private var focusedCoordinate: MapCoordinate? {
        guard let place = store.focusedPlace else { return nil }

        return MapCoordinate(latitude: place.latitude, longitude: place.longitude)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            KakaoMap(
                pins: pins,
                initialCenter: mapCenter,
                focusedCoordinate: focusedCoordinate,
                focusBottomInset: sheetCoveredHeight
            )
            .onPinTapped { pin in
                Log.debug("핀 선택: id=\(pin.id), title=\(pin.title), coordinate=(\(pin.coordinate.latitude), \(pin.coordinate.longitude))")
            }
            .onCenterChanged { viewport in
                store.send(.mapCenterChanged(
                    MapCoordinate(latitude: viewport.center.latitude, longitude: viewport.center.longitude)
                ))
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
        .task(id: pinInput) {
            buildPins()
        }
    }

    // MARK: - Pin 구성

    /// 포커싱 장소가 있으면 그 핀 하나만, 없으면 역 기반 근처 장소 핀을 구성한다.
    @MainActor
    private func buildPins() {
        guard let place = store.focusedPlace else {
            pins = store.nearbyPlaceList.visibleNearbyPlaces.map { place in
                MapPinLabel(image: place.categoryLabel.pinIcon, title: place.name)
                    .makePin(
                        id: String(place.placeId),
                        coordinate: MapCoordinate(latitude: place.latitude, longitude: place.longitude)
                    )
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

// MARK: - PinInput

/// `.task(id:)` 트리거 키. 두 값 중 하나라도 바뀌면 핀을 재구성한다.
private struct PinInput: Equatable {
    let focusedPlace: ConfirmedPlace?
    let nearbyPlaces: [NearbyPlace]
}

// MARK: - Constants

private enum Constant {
    /// 좌표 정보가 없을 때 사용하는 기본 지도 중심(서울 시청).
    static let defaultCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)
}
