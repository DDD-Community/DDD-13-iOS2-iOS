//
//  Selected.swift
//  HomeFeature
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

/// 특정 장소 핀 선택시 보여줄 디테일 시트
struct SelectedPlaceDetailSheet: View {
    private let store: StoreOf<SelectedPlaceDetailSheetFeature>

    init(store: StoreOf<SelectedPlaceDetailSheetFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SelectedPlaceDetailHeaderView(
                name: store.name,
                distanceText: store.distanceText,
                categoryName: store.categoryName,
                onClose: {
                    store.send(.closeButtonTapped)
                }
            )
                .padding(.bottom, Spacing.spacing350)
            SelectedPlaceBusinessHoursView(
                closedDayText: store.closedDayText,
                businessHoursText: store.businessHoursText
            )
                .padding(.bottom, Spacing.spacing350)
            SelectedPlaceAddressView(
                roadAddress: store.roadAddress,
                lotAddress: store.lotAddress
            )
                .padding(.bottom, Spacing.spacing500)
            SelectedPlaceNaverMapButton {
                store.send(.naverMapButtonTapped)
            }
        }
        .padding(.horizontal, Spacing.spacing400)
    }
}
// MARK: - 장소 디테일 헤더 뷰
private struct SelectedPlaceDetailHeaderView: View {
    let name: String
    let distanceText: String
    let categoryName: String
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text(name)
                    .pretendardCustomFont(textStyle: .titleLarge)
                    .foregroundStyle(Color.gray800)

                Spacer()

                Button(action: onClose) {
                    Image.Asset.icClose24
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Colors.gray500)
                }
            }
            .padding(.bottom, 4)

            HStack(spacing: Spacing.spacing150) {
                Text(distanceText)
                    .pretendardCustomFont(textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray600)

                SelectedPlaceMetadataDivider()

                Text(categoryName)
                    .pretendardCustomFont(textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray700)
            }
            .padding(.top, Spacing.spacing100)
        }
    }
}
// MARK: - 장소 영업 시간 뷰
private struct SelectedPlaceBusinessHoursView: View {
    let closedDayText: String
    let businessHoursText: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing100) {
            Text("영업 시간")
                .pretendardCustomFont(textStyle: .bodySmall)
                .foregroundStyle(Color.gray900)

            Group {
                Text(closedDayText)
                Text(businessHoursText)
            }
            .pretendardCustomFont(textStyle: .bodySmall)
            .foregroundStyle(Color.gray700)
        }
    }
}
// MARK: - 장소 주소 뷰
private struct SelectedPlaceAddressView: View {
    let roadAddress: String
    let lotAddress: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing200) {
            Text("주소")
                .pretendardCustomFont(textStyle: .bodySmall)
                .foregroundStyle(Color.gray900)

            VStack(alignment: .leading, spacing: Spacing.spacing200) {
                PlaceAddressRow(title: "도로명", address: roadAddress)
                PlaceAddressRow(title: "지번", address: lotAddress)
            }
        }
    }
}
// MARK: - 네이버 지도 이동 버튼
private struct SelectedPlaceNaverMapButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("네이버 지도로 보기")
                .pretendardCustomFont(textStyle: .labelLarge)
                .foregroundStyle(Colors.gray00)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                        .fill(Colors.gray800)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct SelectedPlaceMetadataDivider: View {
    var body: some View {
        Circle()
            .fill(Colors.gray300)
            .frame(width: 2, height: 2)
    }
}

#Preview {
    SelectedPlaceDetailSheet(
        store: Store(initialState: .mock) {
            SelectedPlaceDetailSheetFeature()
        }
    )
        .padding(.vertical, Spacing.spacing300)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Colors.gray00)
}
