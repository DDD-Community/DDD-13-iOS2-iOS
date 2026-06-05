//
//  NearbyPlaceListSheet.swift
//  HomeFeature
//

import ComposableArchitecture
import DesignSystem
import SwiftUI

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
                .padding(.horizontal, Spacing.spacing400)

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
            .padding(.horizontal, Spacing.spacing400)
            
            Group {
                NearbyPlaceRow()
                NearbyPlaceRow()
                NearbyPlaceRow()
                NearbyPlaceRow()
                NearbyPlaceRow()
            }
            .padding(.horizontal, Spacing.spacing400)
        }
    }
}

private struct NearbyPlaceCategoryFilter: View {
    let selectedCategory: NearbyPlaceCategory
    let onCategoryTapped: (NearbyPlaceCategory) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
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
                    variant: .ghost,
                    state: isSelected ? .enabled : .disabled,
                    size: .small
                )

                Text(title)
                    .pretendardCustomFont(textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray700)
            }
            .padding(.horizontal, Spacing.spacing250)
            .padding(.vertical, Spacing.spacing150)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius400)
                    .fill(Colors.gray100)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius400)
                    .stroke(Colors.gray200, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
