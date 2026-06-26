//
//  ConfirmedPlaceArea.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity

// MARK: - 케이스 4: 확정 장소 (completed / confirmed)

struct ConfirmedPlaceArea: View {
    let store: StoreOf<HomeTabFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing250) {
            BangawoText("약속 장소가 확정되었어요", textStyle: .titleMedium)
                .foregroundStyle(Colors.gray900)

            Card(store: store)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.spacing400)
        .padding(.top, Spacing.spacing400)
        .padding(.bottom, Spacing.spacing500)
    }
}

// MARK: - Card

private struct Card: View {
    let store: StoreOf<HomeTabFeature>

    /// 확정 장소 핀. `place` 변경 시 `.task`에서 재구성한다.
    @State private var pins: [MapPin] = []

    private var place: ConfirmedPlace? {
        store.confirmedPlaceResult?.place
    }

    private var placeName: String {
        place?.name ?? Constant.tempPlaceName
    }

    private var placeAddress: String {
        place?.address
            ?? store.group.locationAddress
            ?? Constant.tempPlaceAddress
    }

    private var placeCategory: PlaceCategory? {
        place?.categoryLabel
    }

    /// 확정 장소 좌표. 좌표가 없으면 기본 중심을 사용한다.
    private var placeCoordinate: MapCoordinate {
        guard let place else { return Constant.defaultCenter }

        return MapCoordinate(latitude: place.latitude, longitude: place.longitude)
    }

    var body: some View {
        VStack(spacing: Spacing.spacing400) {
            PlaceRow(
                placeName: placeName,
                category: placeCategory,
                displayAddress: placeAddress
            )

            KakaoMap(
                pins: pins,
                initialCenter: placeCoordinate,
                initialZoomLevel: Constant.mapZoomLevel
            )
            .aspectRatio(Metric.mapAspectRatio, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: BorderRadius.borderRadius400))
            .allowsHitTesting(false)
        }
        .padding(Spacing.spacing300)
        .background(
            RoundedRectangle(cornerRadius: Spacing.spacing300)
                .fill(
                    RadialGradient(
                        colors: [Colors.neutralAlpha700, Colors.neutralAlpha900],
                        center: .center,
                        startRadius: 0,
                        endRadius: Metric.cardGradientRadius
                    )
                )
        )
        .task(id: place) {
            buildPins()
        }
    }

    /// 확정 장소 좌표에 카테고리 아이콘 핀 하나를 구성해 `@State`에 캐싱한다.
    @MainActor
    private func buildPins() {
        let icon = placeCategory?.pinIcon ?? Image.Asset.icPin24
        pins = [
            MapPinLabel(image: icon, title: placeName)
                .makePin(coordinate: placeCoordinate)
        ]
    }
}

// MARK: - Constants

private enum Metric {
    /// 지도 가로:세로 비율 (가로 295 / 세로 120).
    static let mapAspectRatio: CGFloat = 295.0 / 120.0
    static let cardGradientRadius: CGFloat = 300
}

private enum Constant {
    static let tempPlaceName = "확정된 장소"
    static let tempPlaceAddress = "주소 정보 없음"
    /// 단일 핀 기준 기본 줌 레벨.
    static let mapZoomLevel = 16
    /// 확정 좌표가 없을 때 사용하는 기본 지도 중심(서울 시청).
    static let defaultCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)
}
