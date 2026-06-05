//
//  NearbyPlaceListSheet.swift
//  HomeFeature
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

/// 역근처 정보 리스트 보여줄 시트
struct NearbyPlaceListSheet: View {
    private let store: StoreOf<NearbyPlaceListSheetFeature>

    init(store: StoreOf<NearbyPlaceListSheetFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing200) {
            Text("신사역")
                .pretendardCustomFont(textStyle: .headingSmall)
                .foregroundStyle(Colors.gray900)

            NearbyPlaceCategoryFilter(
                selectedCategory: store.selectedCategory,
                onCategoryTapped: { store.send(.categoryTapped($0)) }
            )

            NearbyPlaceOptionFilter(
                isParkingAvailableSelected: store.isParkingAvailableSelected,
                isReservableSelected: store.isReservableSelected,
                onParkingAvailableTapped: { store.send(.parkingAvailableFilterTapped) },
                onReservableTapped: { store.send(.reservableFilterTapped) }
            )

            NearbyPlaceRow()
            NearbyPlaceRow()
            NearbyPlaceRow()
            NearbyPlaceRow()
            NearbyPlaceRow()
        }
        .padding(.horizontal, Spacing.spacing400)
    }
}

private struct NearbyPlaceCategoryFilter: View {
    let selectedCategory: NearbyPlaceCategory
    let onCategoryTapped: (NearbyPlaceCategory) -> Void

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            ForEach(NearbyPlaceCategory.allCases, id: \.self) { category in
                NearbyPlaceCategoryChip(
                    title: category.title,
                    isSelected: selectedCategory == category
                ) {
                    onCategoryTapped(category)
                }
            }
        }
    }
}

private struct NearbyPlaceOptionFilter: View {
    let isParkingAvailableSelected: Bool
    let isReservableSelected: Bool
    let onParkingAvailableTapped: () -> Void
    let onReservableTapped: () -> Void

    var body: some View {
        HStack(spacing: Spacing.spacing300) {
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
            Text(title)
                .pretendardCustomFont(textStyle: .bodyMedium)
                .foregroundStyle(isSelected ? Colors.gray00 : Colors.gray700)
                .padding(.horizontal, Spacing.spacing250)
                .padding(.vertical, Spacing.spacing150)
                .background(
                    Capsule()
                        .fill(isSelected ? Colors.red500 : Colors.gray100)
                )
        }
        .buttonStyle(.plain)
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
                    variant: .ghost,
                    state: isSelected ? .enabled : .disabled,
                    size: .small
                )

                Text(title)
                    .pretendardCustomFont(textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray700)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
