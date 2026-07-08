//
//  NearbyPlaceListSheet.swift
//  HomeFeature
//

import ComposableArchitecture
import DesignSystem
import Entity
import SwiftUI

/// 시트의 사용 용도.
/// - `default`: 모임 상세 "내 장소보기" 등 기존 역 근처 장소 보기.
/// - `pickPlace`: 장소 투표 후보 담기. 지하철역 segmented control과 row "담기" 버튼을 노출한다.
enum NearbyPlaceListSheetMode: Equatable {
    case `default`
    case pickPlace
}

/// 역근처 정보 리스트 보여줄 시트
struct NearbyPlaceListSheet: View {
    private let store: StoreOf<NearbyPlaceListSheetFeature>
    private let mode: NearbyPlaceListSheetMode

    init(store: StoreOf<NearbyPlaceListSheetFeature>, mode: NearbyPlaceListSheetMode = .default) {
        self.store = store
        self.mode = mode
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NearbyPlaceListHeader(store: store, mode: mode)

            NearbyPlaceCategoryFilter(
                selectedCategory: store.selectedCategory,
                onCategoryTapped: { store.send(.categoryTapped($0)) }
            )
            .padding(.top, Spacing.spacing250)
            .padding(.bottom, Spacing.spacing300)

            NearbyPlaceOptionFilter(
                isParkingAvailableSelected: store.isParkingAvailableSelected,
                isReservableSelected: store.isReservableSelected,
                onParkingAvailableTapped: { store.send(.parkingAvailableFilterTapped) },
                onReservableTapped: { store.send(.reservableFilterTapped) }
            )
            .padding(.horizontal, Spacing.spacing400)
            .padding(.bottom, Spacing.spacing250)

            NearbyPlaceList(store: store, mode: mode)
        }
    }
}

// MARK: - Header

private struct NearbyPlaceListHeader: View {
    let store: StoreOf<NearbyPlaceListSheetFeature>
    let mode: NearbyPlaceListSheetMode

    var body: some View {
        switch mode {
        case .default:
            if let stationName = store.stationName {
                Text(stationName)
                    .pretendardCustomFont(textStyle: .titleLarge)
                    .foregroundStyle(Colors.gray900)
                    .padding(.horizontal, Spacing.spacing400)
                    .padding(.bottom, Spacing.spacing250)
            }

        case .pickPlace:
            StationSegmentedControl(
                stations: store.stations,
                selectedIndex: store.selectedStationIndex,
                onSelect: { store.send(.stationSelected($0)) }
            )
        }
    }
}

// MARK: - Place List

private struct NearbyPlaceList: View {
    let store: StoreOf<NearbyPlaceListSheetFeature>
    let mode: NearbyPlaceListSheetMode

    var body: some View {
        switch mode {
        case .default:
            if store.visibleNearbyPlaces.isEmpty {
                Text("근처 장소가 없어요")
                    .pretendardCustomFont(textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray500)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.spacing600)
            } else {
                ForEach(store.visibleNearbyPlaces) { place in
                    PlaceRow(place: place, onTap: {
                        store.send(.placeRowTapped(place.toConfirmedPlace()))
                    })
                }
            }

        case .pickPlace:
            if store.visibleRecommendedPlaces.isEmpty {
                Text("추천 장소가 없어요")
                    .pretendardCustomFont(textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray500)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.spacing600)
            } else {
                ForEach(store.visibleRecommendedPlaces) { place in
                    PlaceRow(place: place, onTap: {
                        store.send(.placeRowTapped(place.toConfirmedPlace()))
                    }) {
                        PlaceAddButton(
                            isPicked: store.pickedPlaceIds.contains(place.placeId),
                            onTap: { store.send(.placeAddTapped(placeId: place.placeId)) }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - 지하철역 Segmented Control

private struct StationSegmentedControl: View {
    let stations: [MidpointStation]
    let selectedIndex: Int
    let onSelect: (Int) -> Void

    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(stations.enumerated()), id: \.element.id) { index, station in
                StationSegment(
                    station: station,
                    isSelected: selectedIndex == index,
                    namespace: namespace,
                    onTap: { withAnimation(.easeInOut) { onSelect(index) } }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(Spacing.spacing100)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadiusFull)
                .fill(Colors.gray200)
        )
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.spacing400)
        // 9pt: 매칭 디자인 토큰 없음
        .padding(.bottom, 9)
    }
}

private struct StationSegment: View {
    let station: MidpointStation
    let isSelected: Bool
    let namespace: Namespace.ID
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.spacing150) {
                Text("\(station.stationName)역")
                    .pretendardCustomFont(textStyle: .labelMedium)
                    .foregroundStyle(isSelected ? Colors.gray900 : Colors.gray700)

                if station.rank == 1 {
                    MiddleBadge()
                }
            }
            .padding(.horizontal, Spacing.spacing250)
            .padding(.vertical, Spacing.spacing200)
            .frame(maxWidth: .infinity)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: BorderRadius.borderRadiusFull)
                        .fill(Colors.gray00)
                        .overlay(
                            RoundedRectangle(cornerRadius: BorderRadius.borderRadiusFull)
                                .stroke(Colors.gray50, lineWidth: BorderWidth.borderWidth100)
                        )
                        .shadow(
                            color: BoxShadow.boxShadow100.color,
                            radius: BoxShadow.boxShadow100.blur / 2,
                            x: BoxShadow.boxShadow100.offsetX,
                            y: BoxShadow.boxShadow100.offsetY
                        )
                        .matchedGeometryEffect(id: "selectedTab", in: namespace)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct MiddleBadge: View {
    var body: some View {
        Text("중간")
            .pretendardFont(family: .Medium, size: 11)
            .kerning(0.2)
            .lineSpacing(15 - 11)
            .foregroundStyle(Colors.gray700)
            .padding(.horizontal, Spacing.spacing150)
            .padding(.vertical, Spacing.spacing25)
            .overlay(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadiusFull)
                    .stroke(Colors.gray400, lineWidth: BorderWidth.borderWidth100)
            )
    }
}

// MARK: - 담기 버튼

private struct PlaceAddButton: View {
    let isPicked: Bool
    let onTap: () -> Void

    var body: some View {
        ToggleButton(isSelected: isPicked, action: onTap)
    }
}

private struct NearbyPlaceCategoryFilter: View {
    let selectedCategory: PlaceCategory
    let onCategoryTapped: (PlaceCategory) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.spacing200) {
                    ForEach(PlaceCategory.allCases, id: \.self) { category in
                        NearbyPlaceCategoryChip(
                            title: category.title,
                            isSelected: selectedCategory == category
                        ) {
                            onCategoryTapped(category)
                        }
                    }
                }
                .padding(.horizontal, Spacing.spacing400)
            }

            Rectangle()
                .fill(Colors.gray200)
                .frame(height: 1)
        }
    }
}

private struct NearbyPlaceOptionFilter: View {
    let isParkingAvailableSelected: Bool
    let isReservableSelected: Bool
    let onParkingAvailableTapped: () -> Void
    let onReservableTapped: () -> Void

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            NearbyPlaceOptionFilterButton(
                title: "주차 가능",
                isSelected: isParkingAvailableSelected,
                onTap: onParkingAvailableTapped
            )

            NearbyPlaceOptionFilterButton(
                title: "예약 가능",
                isSelected: isReservableSelected,
                onTap: onReservableTapped
            )
        }
    }
}

private struct NearbyPlaceCategoryChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.spacing150) {
                Text(title)
                    .pretendardCustomFont(textStyle: isSelected ? .bodyMediumEmphasized : .bodyMedium)
                    .foregroundStyle(isSelected ? Colors.gray900 : Colors.gray700)
                    .padding(.horizontal, Spacing.spacing250)

                TopRoundedRectangle(cornerRadius: 2)
                    .fill(isSelected ? Colors.gray900 : Color.clear)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct TopRoundedRectangle: Shape { // 카테고리 선택 시 underline shape
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        UnevenRoundedRectangle(
            topLeadingRadius: cornerRadius,
            topTrailingRadius: cornerRadius
        )
        .path(in: rect)
    }
}

private struct NearbyPlaceOptionFilterButton: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.spacing100) {
                Checkbox(
                    variant: .circle,
                    state: isSelected ? .enabled : .disabled,
                    size: .small
                )

                Text(title)
                    .pretendardCustomFont(textStyle: .labelSmall)
                    .foregroundStyle(Colors.gray800)
            }
            .padding(.horizontal, Spacing.spacing250)
            .padding(.vertical, Spacing.spacing150)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius400)
                    .fill(isSelected ? Colors.grayAlpha100 : Colors.gray00)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius400)
                    .stroke(Colors.gray300, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ConfirmedPlace 변환

/// row 탭을 공통 `placeRowTapped(ConfirmedPlace)`로 흘려보내기 위한 변환.
/// `ConfirmedPlace`는 두 타입의 공통 부분집합이라 무손실이다.
private extension NearbyPlace {
    func toConfirmedPlace() -> ConfirmedPlace {
        ConfirmedPlace(
            placeId: placeId,
            name: name,
            categoryLabel: categoryLabel,
            address: address,
            latitude: latitude,
            longitude: longitude
        )
    }
}

private extension RecommendedPlace {
    func toConfirmedPlace() -> ConfirmedPlace {
        ConfirmedPlace(
            placeId: placeId,
            name: name,
            categoryLabel: categoryLabel,
            address: address,
            latitude: latitude,
            longitude: longitude
        )
    }
}
