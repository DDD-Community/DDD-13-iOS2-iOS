//
//  MyPlaceTab.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

import DesignSystem

/// 모임 상세 "내 장소보기" 탭.
/// 카카오 지도 위에 `MapBottomSheet`를 ZStack으로 올린다.
struct MyPlaceTab: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        ZStack(alignment: .bottom) {
            KakaoMap(initialCenter: Constant.defaultCenter)
                .ignoresSafeArea()

            MapBottomSheet {
                NearbyPlaceListSheet(
                    store: store.scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList)
                )
            }
        }
    }
}

// MARK: - Constants

private enum Constant {
    /// 좌표 정보가 없을 때 사용하는 기본 지도 중심(서울 시청).
    static let defaultCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)
}
